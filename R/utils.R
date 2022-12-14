
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

#' Read text file that contains NUL characters
#' @importFrom stringr str_remove_all
#' @source https://stackoverflow.com/a/74795549/3888000
#' @noRd
#' @keywords internal
read_bin = function(filename){
  n = file.size(filename)
  buffer = readBin(filename, 'raw', n=n)
  # Unfortunately the above has a race condition, so check that the size hasn’t changed!
  stopifnot(n == file.size(filename))
  buffer = buffer[buffer != 0L]
  rawToChar(buffer) %>% str_remove_all("\\r")
}


#' Pipeable attribute setter
#' @importFrom rlang dots_list
#' @noRd
#' @keywords internal
#' @source rlang:::set_attrs_impl
set_attrs = function(.x, ...){
  attrs <- dots_list(...)
  attributes(.x) <- c(attributes(.x), attrs)
  .x
}


#' Temporary directory for joinpoint files
#'
#' Creates a timestamped directory in Local/Temp
#'
#' @export
#' @examples
#' dir = get_tempdir()
#' print(dir)
#' #browseURL(dir)
get_tempdir = function(){
  dirname = paste0(tempdir(), "\\joinpoint ", format(Sys.time(), "%Y-%m-%d %Hh%Mm%Ss"))
  dir.create(dirname, showWarnings = FALSE)
  dirname
}

#' Browse the joinpoint files
#'
#' Open the directory in temporary files where joinpoint files are stored
#'
#' @param jp the joinpoint analysis to browse
#'
#' @export
#' @examples
#' jp = joinpoint_example()
#' print(dir)
#' #browseURL(dir)
browse = function(jp){
  path=attr(jp,"directory")
  stopifnot(dir.exists(path))
  browseURL(path)
}




