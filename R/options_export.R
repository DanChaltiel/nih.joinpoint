
#' Export options
#'
#' Create a character representation of the `.ini` file needed for export options.
#'
#' @param models one of `c("best fit", "all")`. Using `all` might be insightful but rather messes with the output.
#' @param remove_best_fit_flags removes the `final_selected_model` column
#' @param output_bygroup_headers should only be used if `models==best`. If `FALSE`, result table has `model`, `apc`, `joinpoints`. If `TRUE`, result table has `jp2`, `apc2` (if selected model is with 2 joinpoints) but rather messes with the output.
#' @param remove_jp_flags remove_jp_flags
#' @param all_models_in_same_column all_models_in_same_column
#' @param include_jp_estimates include_jp_estimates
#' @param include_apcs include_apcs
#' @param x_precision x_precision
#' @param y_precision y_precision
#' @param model_precision model_precision
#' @param estimated_joinpoint_precision estimated_joinpoint_precision
#' @param regression_coefficients_precision regression_coefficients_precision
#' @param covariance_matrix_precision covariance_matrix_precision
#' @param correlation_matrix_precision correlation_matrix_precision
#' @param apc_precision apc_precision
#' @param aapc_precision aapc_precision
#' @param aapc_segemnt_ranges_precision aapc_segemnt_ranges_precision
#' @param pvalue_precision pvalue_precision
#' @param aapc_full_range aapc_full_range
#' @param aapc_start_range1 aapc_start_range1
#' @param aapc_end_range1 aapc_end_range1
#' @param aapc_start_range2 aapc_start_range2
#' @param aapc_end_range2 aapc_end_range2
#' @param aapc_start_range3 aapc_start_range3
#' @param aapc_end_range3 aapc_end_range3
#' @param aapc_last_obs aapc_last_obs
#' @param export_bad_cohorts export_bad_cohorts
#' @param export_report export_report
#' @param export_data export_data
#' @param export_apc export_apc
#' @param export_aapc export_aapc
#' @param export_ftest export_ftest
#' @param export_pairwise export_pairwise
#' @param export_jump_cr export_jump_cr
#'
#' @source [https://surveillance.cancer.gov/joinpoint/Joinpoint_Help_4.8.0.1.pdf]
#'
#' @importFrom glue glue
#' @export
#' @return a string (character of length 1) representing the .ini file
export_options = function(models=c("best fit", "all"),
                          remove_jp_flags=TRUE,
                          remove_best_fit_flags=FALSE,
                          output_bygroup_headers=FALSE,
                          all_models_in_same_column=FALSE, include_jp_estimates=FALSE,
                          include_apcs=TRUE, x_precision=9, y_precision=9, model_precision=3,
                          estimated_joinpoint_precision=3, regression_coefficients_precision=3,
                          covariance_matrix_precision=3, correlation_matrix_precision=3,
                          apc_precision=3,aapc_precision=3, aapc_segemnt_ranges_precision=3,
                          pvalue_precision=3,
                          aapc_full_range=FALSE,
                          aapc_start_range1 = NULL, aapc_end_range1 = NULL,
                          aapc_start_range2 = NULL, aapc_end_range2 = NULL,
                          aapc_start_range3 = NULL, aapc_end_range3 = NULL,
                          aapc_last_obs=FALSE,
                          export_bad_cohorts=TRUE, export_report=TRUE, export_data=TRUE,
                          export_apc=TRUE, export_aapc=TRUE, export_ftest=TRUE,
                          export_pairwise=TRUE, export_jump_cr=TRUE
){
  models = match.arg(models)
  # if(models=="all" && missing(output_bygroup_headers)){
  #   output_bygroup_headers = FALSE
  #   # print("error ?")
  #   # stop("")
  # }

  txt = glue(.sep="\n", .null=NULL,
             "[Export Options]",
             "Models={models}",
             "Line delimiter=unix",
             "Missing character=period",
             "Field delimiter=tab",
             "By-var format=quoted labels",
             # "Export type=table",
             "Output by-group headers={output_bygroup_headers}",
             f("Remove JP flags", remove_jp_flags, missing(remove_jp_flags)),
             f("Remove best fit flags", remove_best_fit_flags, missing(remove_best_fit_flags)),
             f("All models in same column", all_models_in_same_column, missing(all_models_in_same_column)),
             f("Include JP estimates", include_jp_estimates, missing(include_jp_estimates)),
             f("Include apcs in data export", include_apcs, missing(include_apcs)),
             f("X Values Precision", x_precision, missing(x_precision)),
             f("Y Values Precision", y_precision, missing(y_precision)),
             f("Model Statistics Precision", model_precision, missing(model_precision)),
             f("Estimated Joinpoints Precision", estimated_joinpoint_precision,
               missing(estimated_joinpoint_precision)),
             f("Regression Coefficients Precision", regression_coefficients_precision,
               missing(regression_coefficients_precision)),
             f("Covariance Matrix Precision", covariance_matrix_precision, missing(covariance_matrix_precision)),
             f("Correlation Matrix Precision", correlation_matrix_precision, missing(correlation_matrix_precision)),
             f("APC Precision", apc_precision, missing(apc_precision)),
             f("AAPC Precision", aapc_precision, missing(aapc_precision)),
             f("AAPC Segment Ranges Precision", aapc_segemnt_ranges_precision, missing(aapc_segemnt_ranges_precision)),
             f("P-Value Precision", pvalue_precision, missing(pvalue_precision)),
             f("AAPC Full Range", aapc_full_range, missing(aapc_full_range)),
             f("AAPC Start Range1", aapc_start_range1, missing(aapc_start_range1)),
             f("AAPC End Range1", aapc_end_range1, missing(aapc_end_range1)),
             f("AAPC Start Range2", aapc_start_range2, missing(aapc_start_range2)),
             f("AAPC End Range2", aapc_end_range2, missing(aapc_end_range2)),
             f("AAPC Start Range3", aapc_start_range3, missing(aapc_start_range3)),
             f("AAPC End Range3", aapc_end_range3, missing(aapc_end_range3)),
             f("AAPC Last Obs", aapc_last_obs, missing(aapc_last_obs)),
             f("Export Bad Cohorts", export_bad_cohorts, missing(export_bad_cohorts)),
             f("Export Report", export_report, missing(export_report)),
             f("Export data", export_data, missing(export_data)),
             f("Export apc", export_apc, missing(export_apc)),
             f("Export aapc", export_aapc, missing(export_aapc)),
             f("Export ftest", export_ftest, missing(export_ftest)),
             f("Export pairwise", export_pairwise, missing(export_pairwise)),
             f("Export jump_cr", export_jump_cr, missing(export_jump_cr)),
  )
  txt
}
