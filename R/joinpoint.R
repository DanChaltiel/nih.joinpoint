
#' API to run a joinpoint model
#'
#' Use the Command-Line version of "Joinpoint Regression Software" provided by the NIH to run a regression.
#' The software must be downloaded at https://surveillance.cancer.gov/joinpoint/callable/ and installed on a **Windows** computer. I am not aware of a version of this software for Linux or MacOS.
#'
#' This function will generate the `.ini` files, run the software, and then parse the result files as an plain old R list.
#'
#'
#' @param data A data frame
#' @param x `<tidy-select>` the independent variable (for instance the year)
#' @param y `<tidy-select>` the dependent variable
#' @param by `<tidy-select>` one or several stratification variable (for instance sex)
#' @param se `<tidy-select>` the standard error of the dependent variable. Can be left as `NULL` at the cost of a longer computation. See https://seer.cancer.gov/seerstat/WebHelp/Rate_Algorithms.htm for calculation formulas.
#' @param export_opts the result of [export_options()]
#' @param run_opts the result of [run_options()]
#' @param cmd_path the path to the executable. Can usually be left default to `"C:/Program Files (x86)/Joinpoint Command/jpCommand.exe"`. Can also be set through `options(joinpoint_path="my/path/to/jp.exe")`.
#' @param dir The temporary directory where all the temporary files will be written
#' @param verbose Logical indicating whether or not to print out progress
#'
#' @import cli
#' @import purrr
#' @importFrom dplyr across arrange %>%
#' @importFrom glue glue glue_collapse
#' @importFrom readr write_delim read_file
#' @importFrom rlang enquo sym
#' @importFrom tidyselect eval_select
#' @importFrom utils packageVersion
#' @export
#' @return the list of the output tables
joinpoint = function(data, x, y, by=NULL, se=NULL,
                     export_opts=export_options(), run_opts=run_options(),
                     cmd_path=getOption("joinpoint_path", "C:/Program Files (x86)/Joinpoint Command/jpCommand.exe"),
                     dir=get_tempdir(), verbose=FALSE){
  check_cmd_path(cmd_path)
  start_time = Sys.time()
  wd_bak = getwd()
  setwd(dir) #Necessary for `system()` to write to the temp directory.
  on.exit({
    setwd(wd_bak)
  })
  dir.create("ini", showWarnings = FALSE)
  cat(export_opts, file="ini/export_opt_ini.ini")
  cat(run_opts, file="ini/run_opt_ini.ini")
  session = paste(sep="\n",
                  "[Joinpoint Input Files]",
                  "Session File=ini/session_ini.ini",
                  "Export Options File=ini/export_opt_ini.ini",
                  "Run Options File=ini/run_opt_ini.ini",
                  "Output File File=jp_result.jpo")
  cat(session, file="session_run.ini")

  x=tidyselect::eval_select(enquo(x), data)
  y=tidyselect::eval_select(enquo(y), data)
  by=tidyselect::eval_select(enquo(by), data, strict=FALSE)
  se=tidyselect::eval_select(enquo(se), data, strict=FALSE)
  stopifnot(length(x)==1)
  stopifnot(length(y)==1)
  stopifnot(length(by)>=0)
  stopifnot(length(se)>=0)
  data = arrange(data, across(any_of(names(x))))

  by_txt = NULL
  if(length(by)>0){
    data = arrange(data, across(any_of(names(by))))
    by_txt = purrr::pmap_chr(
      list(by, names(by), seq(length(by))),
      function(.x, .n, .i){
        glue("by-var{.i}={.n}", "by-var{.i} location={.x}", .sep="\n")
      }
    ) %>% glue_collapse("\n")
  }

  se_txt = NULL
  if(length(se)>0){
    se_txt = glue("standard error={names(se)}",
                  "standard error location={se}",
                  .sep="\n")
  }

  session_ini = get_session_ini(x, y, by_txt, se_txt)
  cat(session_ini, file="ini/session_ini.ini")
  write_delim(data, "dataset.txt", delim="\t", na=".", col_names=FALSE)

  suppressWarnings(file.remove("session_run.ErrorFile.txt"))
  output=system(paste0('"', cmd_path, '" ', "session_run.ini"), intern=isFALSE(verbose))
  #TODO check that x is always 0?
  if(file.exists("session_run.ErrorFile.txt")){
    file.copy("session_run.ErrorFile.txt", glue("{wd_bak}/joinpoint_error.txt"))
    error=read_bin("session_run.ErrorFile.txt") %>% str_split("\\n") %>% .[[1]]
    cli_abort(c("Error when running the JoinPoint command-line program.
                A `joinpoint_error.txt` file has been created.",
                "", error))
  }

  aapc = r("session_run.aapcexport.txt")
  apc = r("session_run.apcexport.txt")
  data_export = r("session_run.dataexport.txt")
  selected_model = r("session_run.finalselectedmodelexport.txt")
  perm_test = r("session_run.permtestexport.txt")
  report = r("session_run.report.txt")
  run_summary = readr::read_file("session_run.RunSummary.txt")
  parameters = list(x=names(x), y=names(y), by=names(by), se=names(se))

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
    report = report
  ) %>%
    map(set_attrs, variables=parameters)


  attr(rtn, "execution_time") = Sys.time() - start_time
  attr(rtn, "options") = list(run_opts=run_opts, export_opts=export_opts)
  attr(rtn, "run_summary") = run_summary
  attr(rtn, "parameters") = parameters
  attr(rtn, "directory") = dir
  attr(rtn, "version") = packageVersion("nih.joinpoint")
  class(rtn) = "nih.joinpoint"
  rtn
}


#' @noRd
#' @keywords internal
get_session_ini = function(x, y, by_txt, se_txt) {
  session_ini = glue(
    .sep="\n", .null=NULL,
    "[Datafile options]",
    "Datafile name=dataset.txt",
    "File format=DOS/Windows",
    "Field delimiter=tab",
    "Missing character=period",
    "Fields with delimiter in quotes=false",
    "Variable names include=false",
    "",
    "[Joinpoint Session Parameters]",
    "Crude rate={names(y)}",
    "Crude rate location={y}",
    "independent variable={names(x)}",
    "independent variable location={x}",
    by_txt,
    se_txt
  )
}


#' @importFrom tibble is_tibble
#' @export
print.nih.joinpoint = function(x, ...){
  xx = keep(x, is_tibble) %>% imap_chr(~glue("{.y} ({ncol(.x)}x{nrow(.x)})"))
  v = attr(x, "parameters") %>% paste(names(.), ., sep="=")
  et = attr(x, "execution_time") %>% format(digits=3)


  cli_inform(c(
    "A {.pkg nih.joinpoint} model ({.pkg v{attr(x, 'version')}})",
    "i"="Parameters: {.code {v}}",
    "i"="Execution time: {et}",
    "*"="Browse the object as a list of {length(xx)} table{?s}: {.code {xx}}",
    "*"="Read the run summary using {.fn summary}",
    "*"="Plot the result using {.fn jp_plot}"
  ),
  class="joinpoint_print")
}

#' @export
summary.nih.joinpoint = function(object, ...){
  opts=attr(object, "options")
  cat(opts$run_opts, "\n\n")
  # cat(opts$export_opts, "\n\n")
  cat(attr(object, "run_summary"))
}
