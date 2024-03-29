
#' Plot the output of a joinpoint analysis.
#'
#' @param jp A list generated using [joinpoint()].
#' @param by_level One or several stratification levels. Works only if `jp` was made using one single stratification variable.
#' @param legend_pattern [glue::glue()] pattern for the legend. Can use variables `slope`, `xmin`, and `xmax`. Can be set through options, e.g. `options(jp_plot_legend_pattern="-{slope}-")`.
#' @param title_pattern [glue::glue()] pattern for the title. Can use variables `key` (grouping variable) and `val` (current group). Can be set through options, e.g. `options(jp_plot_title_pattern="-{val}-")`.
#' @param ... passed on to [patchwork::wrap_plots()]
#'
#' @return a `patchwork` if `return_patchwork==TRUE`, a list of `ggplots` otherwise
#' @export
#' @importFrom dplyr select filter mutate group_by na_if %>%
#' @importFrom forcats as_factor
#' @importFrom ggplot2 ggplot aes geom_point geom_line ylim ggtitle labs
#' @importFrom glue glue
#' @importFrom patchwork wrap_plots
#' @importFrom rlang sym enquo :=
#' @importFrom tidyselect eval_select any_of
#' @importFrom zoo na.locf
jp_plot = function(jp,
                   by_level=NULL,
                   legend_pattern=getOption("jp_plot_legend_pattern", "{xmin}-{xmax}: {slope}"),
                   title_pattern=getOption("jp_plot_title_pattern", "{key}={val}"),
                   ncol=1,
                   return_patchwork=TRUE,
                   ...){

  variables = attr(jp$data_export, "variables")
  x = sym(variables$x)
  y = sym(variables$y)
  by = variables$by

  if(length(by)>1){
    cli::cli_abort(c("{.fn jp_plot} cannot be used when more than 1 stratification variable is set.",
                     x="The current joinpoint object has {length(by)} stratification variable{?s}: {by}."),
                   class="jp_plot_many_stratif_error")
  }

  v = intersect(c("apc", "slope"), names(jp$data_export))
  if(length(v) !=1) stop("This should not happen, contact the developper of {joinpoint}.")
  if(all(is.na(jp$data_export[[v]]))){
    warning("Cannot plot the joinpoint model as all values of `", v, "` are NA. Please check the model source.")
    return(NULL)
  }
  if(v=="apc"){
    v_label = "Annual Percent Change"
  } else {
    v_label = "Slope"
  }
  v=sym(v)

  byname = names(select(jp$data_export, {{by}}))
  data = jp$data_export %>%
    mutate(slope0 = na_if(!!v, ".") %>% zoo::na.locf(fromLast=TRUE) %>% as_factor()) %>%
    group_by(.data$slope0) %>%
    mutate(slope = .data$slope0[1],
           xmin = min({{x}}), xmax=max({{x}}),
           !!v := glue(legend_pattern))

  if(!is.null(by_level)){
    if(length(byname)!=1){
      warning("`by_level` can only be used when a single stratification variable is set.")
    } else if(!all(by_level %in% data[[byname]])){
      warning("`by_level` (=[", paste(by_level, collapse=","), "]) is not a value contained in column ", byname)
    } else {
      data = data %>%
        filter(!!sym(by) %in% by_level) %>%
        mutate(across(!!sym(by), ~factor(.x, levels=by_level)))
    }
  }


  if(length(byname)>0){
    p = data %>%
      split(.[[byname]]) %>%
      imap(~{
        ggplot(.x, aes(x={{x}}, y={{y}})) +
          geom_point() +
          geom_line(aes(y=.data$model, color=!!v, group=FALSE), linewidth=1) +
          labs(color=v_label) +
          ylim(0, NA) +
          ggtitle(glue(title_pattern, key=byname, val=.y))
      })
  } else {
    p = data %>%
      ggplot(aes(x={{x}}, y={{y}})) +
      geom_point() +
      labs(color=v_label) +
      geom_line(aes(y=.data$model, color=!!v, group=.data$slope), linewidth=1) +
      ylim(0, NA)
    p = list(p)
  }
  if(isFALSE(return_patchwork)) return(p)
  patchwork::wrap_plots(p, ncol=ncol, ...)
}
