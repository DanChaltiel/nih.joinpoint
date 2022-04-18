
utils::globalVariables(c(".", ".data"))


#' Format helper
#' @noRd
#' @keywords internal
f = function(key, val, m){
  if(isFALSE(m)) paste0(key, "=", val)
  else NULL
}


#' Format helper
#' @noRd
#' @keywords internal
tf = function(x) tolower(as.character(x))


#' Read helper
#' @importFrom readr read_delim
#' @importFrom janitor clean_names
#' @importFrom tibble as_tibble
#' @importFrom dplyr  %>%
#' @noRd
#' @keywords internal
r = function(x){
  #TODO read, detect rows that are exactly colnames, type.convert(as.is=TRUE)
  if(file.exists(x)){
    readr::read_delim(x, delim="\t", na=".",
                      show_col_types=FALSE, progress=FALSE) %>%
      as_tibble() %>% janitor::clean_names()
  } else{
    NULL
  }
}


#' Pipeable attribute setter
#' @importFrom rlang dots_list
#' @noRd
#' @keywords internal
#' @source rlang:::set_attrs_impl
set_attrs = function(.x, ...){
  attrs <- rlang::dots_list(...)
  attributes(.x) <- c(attributes(.x), attrs)
  .x
}


#' Temporary directory for joinpoint files
#'
#' Creates a timestamped directory in Local/Temp
#'
#' @export
#' @example
#' dir = get_tempdir()
#' print(dir)
#' #browseURL(dir)
get_tempdir = function(){
  dirname = paste0(tempdir(), "\\joinpoint ", format(Sys.time(), "%Y-%m-%d %Hh%Mm%Ss"))
  dir.create(dirname, showWarnings = FALSE)
  dirname
}






