
#' API to run a joinpoint model
#'
#' Use the Command-Line version of "Joinpoint Regression Software" provided by the NIH to run a regression.
#' The software must be downloaded at https://surveillance.cancer.gov/joinpoint/callable/ and installed on a **Windows** computer. I am not aware of a version of this software for Linux or MacOS.
#'
#' This function will generate the `.ini` files, run the software, and then parse the result files as an plain old R list.
#'
#'
#' @param data A data frame
#' @param x `<tidy-select>` the independant variable (for instance the year)
#' @param y `<tidy-select>` the dependant variable of type `y_type`
#' @param by `<tidy-select>` one or several stratification variable (for instance sex)
#' @param se `<tidy-select>` the standard error of the dependant variable. Can be left as `NULL` at the cost of a longer computation. See https://seer.cancer.gov/seerstat/WebHelp/Rate_Algorithms.htm for calculation formulas.
#' @param y_type the type of dependant variable. Must be one of `c("Age-Adjusted Rate", "Crude rate", "Percent", "Proportion", "Count")`.
#' @param export_opt_ini the result of [export_options()]
#' @param run_opt_ini the result of [run_options()]
#' @param cmd_path the path to the executable. Can usualy be left default to `"C:/Program Files (x86)/Joinpoint Command/jpCommand.exe"`. Can also be set through `options(joinpoint_path="my/path/to/jp.exe")`.
#' @param dir The temporary directory where all the temporary files will be written
#' @param verbose Logical indicating whether or not to print out progress
#'
#' @importFrom dplyr arrange %>%
#' @importFrom glue glue glue_collapse
#' @importFrom tidyselect eval_select
#' @importFrom purrr map imap_chr
#' @importFrom readr write_delim read_file
#' @importFrom rlang enquo sym
#' @export
#' @return the list of the output tables
joinpoint = function(data, x, y, by=NULL, se=NULL,
                     y_type=c("Age-Adjusted Rate", "Crude rate", "Percent", "Proportion", "Count"),
                     export_opt_ini=export_options(), run_opt_ini=run_options(),
                     cmd_path=getOption("joinpoint_path", "C:/Program Files (x86)/Joinpoint Command/jpCommand.exe"),
                     dir=get_tempdir(), verbose=FALSE){
  wd_bak = getwd()
  setwd(dir) #This is necessary for `system()` to write to the temp directory.
  on.exit({
    setwd(wd_bak)
  })
  dir.create("ini", showWarnings = FALSE)
  cat(export_opt_ini, file="ini/export_opt_ini.ini")
  cat(run_opt_ini, file="ini/run_opt_ini.ini")
  session = paste(sep="\n",
                  "[Joinpoint Input Files]",
                  "Session File=ini/session_ini.ini",
                  "Export Options File=ini/export_opt_ini.ini",
                  "Run Options File=ini/run_opt_ini.ini",
                  "Output File File=jp_result.jpo")
  cat(session, file="session_run.ini")

  y_type = match.arg(y_type) %>% tolower()
  x=tidyselect::eval_select(enquo(x), data)
  y=tidyselect::eval_select(enquo(y), data)
  se=tidyselect::eval_select(enquo(se), data, strict=FALSE)
  by=tidyselect::eval_select(enquo(by), data, strict=FALSE)
  data = arrange(data, !!sym(names(x)))

  by_txt = NULL
  if(length(by)>0){
    data = arrange(data, !!sym(names(by)))
    i=1
    by_txt = imap_chr(by, ~{
      rtn = glue("by-var{i}={.y}", "by-var{i} location={.x}", .sep="\n")
      i<<-i+1
      rtn
    }) %>% glue_collapse("\n")
  }

  se_txt = NULL
  if(length(se)>0){
    se_txt = glue("standard error={names(se)}",
                  "standard error location={se}",
                  .sep="\n")
  }

  #TODO faire les formats avec les variables factor ?
  session_ini = glue(.sep="\n", .null=NULL,
                     "[Datafile options]",
                     "Datafile name=dataset.txt",
                     "File format=DOS/Windows",
                     "Field delimiter=tab",
                     "Missing character=period",
                     "Fields with delimiter in quotes=false",
                     "Variable names include=false",

                     "[Joinpoint Session Parameters]",
                     "{y_type}={names(y)}",
                     "{y_type} location={y}",
                     "independent variable={names(x)}",
                     "independent variable location={x}",
                     by_txt,
                     se_txt
                     )
  cat(session_ini, file="ini/session_ini.ini")
  write_delim(data, "dataset.txt", delim="\t", na=".", col_names=FALSE)

  #TODO messages d'erreur si 127, si cmd_path est mauvais...
  suppressWarnings(file.remove("session_run.ErrorFile.txt"))
  system(paste0('"', cmd_path, '" ', "session_run.ini"), intern=isFALSE(verbose))

  if(file.exists("session_run.ErrorFile.txt")){
    # readr::read_file("session_run.ErrorFile.txt") %>% suppressWarnings() %>% stringi::stri_flatten()
    # readLines("session_run.ErrorFile.txt") %>% suppressWarnings() %>% .[. != ""]
    # read.delim("session_run.ErrorFile.txt", sep="_____", encoding="UTF-16LE")
    # readChar("session_run.ErrorFile.txt", file.info("session_run.ErrorFile.txt")$size)

    file.copy("session_run.ErrorFile.txt", glue("{wd_bak}/joinpoint_error.txt"))
    setwd(wd_bak)
    stop("Error, see `joinpoint_error.txt` for the details")

  }

  aapc = r("session_run.aapcexport.txt")
  apc = r("session_run.apcexport.txt")
  data_export = r("session_run.dataexport.txt")
  selected_model = r("session_run.finalselectedmodelexport.txt")
  perm_test = r("session_run.permtestexport.txt")
  report = r("session_run.report.txt")
  run_summary = readr::read_file("session_run.RunSummary.txt")
  variables = list(x=names(x), y=names(y), by=names(by), se=names(se))

  if(isTRUE(verbose)){
    cat("\n",
        "***********************************",
        "*           RUN SUMMARY           *",
        "***********************************",
        "",
        run_summary, sep="\n")
  }

  rtn = list(
    aapc = aapc,
    apc = apc,
    data_export = data_export,
    selected_model = selected_model,
    perm_test = perm_test,
    report = report,
    run_summary = run_summary
  ) %>%
    map(set_attrs, variables=variables)


  setwd(wd_bak)
  rtn
}





#' Format helper
#' @noRd
#' @keywords internal
generate_input_ini = function(session_ini, export_ini, run_ini,
                              result="jp_result.txt"){
  txt = glue(.sep="\n", .null=NULL,
             "[Joinpoint Input Files]",
             "Session File={session_ini}",
             "Export Options File={export_ini}",
             "Run Options File={run_ini}",
             "Output File File={result}")
  txt
}
