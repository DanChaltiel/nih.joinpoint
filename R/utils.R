
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
