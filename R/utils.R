
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
#' @noRd
#' @keywords internal
r = function(x){
  if(file.exists(x)){
    readr::read_delim(x, delim="\t", show_col_types=FALSE) %>%
      # read.table(x, header= TRUE) %>%
      as_tibble() %>% janitor::clean_names()
  } else{
    NULL
  }
}


#' Pipeable attribute setter
#' @source rlang:::set_attrs_impl
#' @noRd
#' @keywords internal
set_attrs = function(.x, ...){
  attrs <- rlang::dots_list(...)
  attributes(.x) <- c(attributes(.x), attrs)
  .x
}
