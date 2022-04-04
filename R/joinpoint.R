
#' API to run a joinpoint model
#'
#' Use the Joinpoint Regression Software provided by the NIH to run a regression.
#' The software must be downloaded at https://surveillance.cancer.gov/joinpoint/callable/ and installed on a **Windows** computer. I am not aware of a version of this software for Linux or MacOS.
#'
#' This function will generate the .ini files, run the software, and then parse the result files as an plain old R list.
#'
#'
#' @param data A data frame
#' @param x `<tidy-select>` the independant variable (for instance the year)
#' @param y `<tidy-select>` the dependant variable of type `y_type`
#' @param by `<tidy-select>` one or several stratification variable (for instance sex)
#' @param se `<tidy-select>` the standard error of the dependant variable. Can be left as `NULL` at the cost of a longer computation. See https://seer.cancer.gov/seerstat/WebHelp/Rate_Algorithms.htm for calculation formulas.
#' @param y_type the type of dependant variable. Must be one of `c("Age-Adjusted Rate", "Crude rate", "Percent", "Proportion", "Count")`.
#' @param export_opt_ini the result of [generate_export_opt_ini()]
#' @param run_opt_ini the result of [generate_run_opt_ini()]
#' @param cmd_path the path to the executable. Can usualy be left default to `"C:/Program Files (x86)/Joinpoint Command/jpCommand.exe"`. Can also be set through `options(joinpoint_path="my/path/to/jp.exe")`.
#' @param dir The
#' @param verbose
#'
#' @export
#' @return the list of the output tables
joinpoint = function(data, x, y, by=NULL, se=NULL,
                     y_type=c("Age-Adjusted Rate", "Crude rate", "Percent", "Proportion", "Count"),
                     export_opt_ini, run_opt_ini,
                     cmd_path=getOption("joinpoint_path", "C:/Program Files (x86)/Joinpoint Command/jpCommand.exe"),
                     dir=tempdir(), verbose=TRUE){
  wd = getwd()
  setwd(dir)
  unlink("joinpoint", recursive=TRUE, force=TRUE)
  dir.create("joinpoint", showWarnings = FALSE)
  setwd("joinpoint")
  on.exit({
    setwd(wd)
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

  # browser()

  y_type = match.arg(y_type) %>% tolower()
  x=tidyselect::eval_select(enquo(x), data)
  y=tidyselect::eval_select(enquo(y), data)
  se=tidyselect::eval_select(enquo(se), data, strict=FALSE)
  by=tidyselect::eval_select(enquo(by), data, strict=FALSE)

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
                  "standard error location={se}")
  }

  #TODO faire les formats avec les variables factor ?
  session_ini = glue(.sep="\n", .null=NULL,
                     "[Datafile options]",
                     "Datafile name=dataset.txt",
                     "File format=DOS/Windows",
                     "Field delimiter=tab",
                     "Missing character=space",
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
  write_delim(data, "dataset.txt", delim="\t", na=" ", col_names=FALSE)

  #TODO verbose ?
  #TODO messages d'erreur si 127, si cmd_path ets mauvais...
  run = system(paste0('"', cmd_path, '" ', "session_run.ini"), intern=TRUE)
  # browser()
  if(file.exists("session_run.ErrorFile.txt")){
    # readr::read_file("session_run.ErrorFile.txt") %>% suppressWarnings() %>% stringi::stri_flatten()
    # readLines("session_run.ErrorFile.txt") %>% suppressWarnings() %>% .[. != ""]
    # read.delim("session_run.ErrorFile.txt", sep="_____", encoding="UTF-16LE")
    # readChar("session_run.ErrorFile.txt", file.info("session_run.ErrorFile.txt")$size)

    file.copy("session_run.ErrorFile.txt", glue("{wd}/joinpoint_error.txt"))
    setwd(wd)
    stop("Error, see `joinpoint_error.txt` for the details")

  } else {

    aapc = r("session_run.aapcexport.txt")
    apc = r("session_run.apcexport.txt")
    data_export = r("session_run.dataexport.txt")
    selected_model = r("session_run.finalselectedmodelexport.txt")
    perm_test = r("session_run.permtestexport.txt")
    report = r("session_run.report.txt")
    run_summary = readr::read_file("session_run.RunSummary.txt")
    variables = list(x=names(x), y=names(y), by=names(by), se=names(se))

    print(data_export)


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

    setwd(wd)
    rtn
  }
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
