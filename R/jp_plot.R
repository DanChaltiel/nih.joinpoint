
#' Title
#'
#' @param .data A data frame. Usually the member `data_export` of the result of [joinpoint()].
#' @param x <`optional`> override the `x` column
#' @param y <`optional`> override the `y` column
#' @param by <`optional`> override the `by` columns
#' @param legend_pattern [glue::glue()] pattern for the legend. Can use variables `slope`, `xmin`, and `xmax`. Can be set through options, e.g. `options(jp_plot_pattern="-{slope}-")`.
#'
#' @return a `ggplot` object if by==NULL, or a `patchwork` otherwise
#' @export
#' @import dplyr tidyselect rlang purrr glue readr
#' @importFrom tidyselect eval_select
#' @importFrom rlang enquo
#' @importFrom purrr imap_chr
#'
#' @examples
#' \dontrun{
#'  jp = 1
#' }
jp_plot = function(.data, x, y, by,
                   legend_pattern=getOption("jp_plot_pattern", "{xmin}-{xmax}: {slope}")){
  v = sym(names(select(.data, any_of(c("apc", "slope")))))

  variables = attr(.data, "variables")
  if(missing(x)) x = sym(variables$x)
  if(missing(y)) y = sym(variables$y)
  if(missing(by)) by = variables$by

  byname = names(select(.data, {{by}}))

  .data = .data %>%
    mutate(slope0:=na_if(!!v, ".") %>% zoo::na.locf(fromLast=TRUE) %>% as_factor()) %>%
    group_by(slope0) %>%
    mutate(slope = slope0[1],
           xmin = min({{x}}), xmax=max({{x}}),
           !!v := glue(legend_pattern))

  if(length(byname)>0){
    .data %>%
      split(.[[byname]]) %>%
      imap(~{
        ggplot(.x, aes(x={{x}}, y={{y}})) +
          geom_point() +
          geom_line(aes(y=model, color=!!v, group=FALSE), size=1) +
          ylim(0, NA) +
          ggtitle(glue('{byname}={.y}'))
      }) %>%
      patchwork::wrap_plots()
  } else {
    .data %>%
      ggplot(aes(x={{x}}, y={{y}})) +
      geom_point() +
      geom_line(aes(y=model, color=!!v, group=slope), size=1) +
      ylim(0, NA)
  }
}
