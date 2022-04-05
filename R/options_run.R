



#' Modelisation options
#'
#' Create a character representation of the `.ini` file needed for run options.
#'
#' @param model one of `c("linear", "ln")`
#' @param data_shift data_shift
#' @param min_joinpoints min_joinpoints
#' @param max_joinpoints max_joinpoints
#' @param pairwise pairwise
#' @param pairwise_signif_lvl pairwise_signif_lvl
#' @param pairwise_n_permut pairwise_n_permut
#' @param method method
#' @param min_obs_end min_obs_end
#' @param min_obs_between min_obs_between
#' @param n_obs_between n_obs_between
#' @param model_selection_method model_selection_method
#' @param permutation_signif_lvl permutation_signif_lvl
#' @param n_permutations n_permutations
#' @param early_stopping early_stopping
#' @param run_type run_type
#' @param rates_per_n rates_per_n
#' @param dependant_variable_type dependant_variable_type
#' @param het_error het_error
#' @param het_error_var_location het_error_var_location
#' @param ci_method ci_method
#' @param n_cores n_cores
#' @param delay_type delay_type
#' @param autocorr_errors autocorr_errors
#' @param jump_model jump_model
#' @param comparability_ratio comparability_ratio
#' @param include_std_analysis include_std_analysis
#' @param jump_location jump_location
#' @param comparability_ratio_calue comparability_ratio_calue
#' @param cr_variance cr_variance
#' @param joinpoint_alpha_lvl joinpoint_alpha_lvl
#' @param apc_alpha_lvl apc_alpha_lvl
#' @param aapc_alpha_lvl aapc_alpha_lvl
#' @param jump_cr_alpha_lvl jump_cr_alpha_lvl
#' @param random_seed random_seed
#' @param empirical_quantile_seed empirical_quantile_seed
#' @param empirical_quantile_seed_type empirical_quantile_seed_type
#' @param n_resample n_resample
#' @param madwd madwd
#' @param madwd_psi madwd_psi
#'
#' @importFrom glue glue
#' @export
#' @return a string (character of length 1) representing the .ini file
run_options = function(model=c("linear", "ln"), data_shift=0, min_joinpoints=0, max_joinpoints=4,
                       pairwise=NULL, pairwise_signif_lvl=0.05, pairwise_n_permut=4499,
                       method=c("grid", "hudsons"), min_obs_end=2, min_obs_between=2, n_obs_between=0,
                       model_selection_method=c("permutation test", "bic", "mbic",
                                                "data dependent selection", "wbic", "wbic-alt"),
                       permutation_signif_lvl=0.05, n_permutations=4499,
                       early_stopping=c("b-value", "curtailed", "fixed"),
                       run_type=c("calculated", "provided"), rates_per_n=100000,
                       dependant_variable_type=c("count", "crude rate", "age-adjusted rate",
                                                 "proportion", "percent"),
                       het_error = c("constant variance", "standard error",
                                     "poisson rate", "poisson count"),
                       het_error_var_location = NULL,
                       ci_method=c("parametric", "empirical quantile method 1",
                                   "empirical quantile method 2"),
                       n_cores=1,
                       delay_type=c("delay", "non-delay", "both"),
                       autocorr_errors=c("number", "estimated"),
                       jump_model=FALSE, comparability_ratio=FALSE, include_std_analysis=FALSE,
                       jump_location=9999,
                       comparability_ratio_calue=0, cr_variance=0, joinpoint_alpha_lvl=0.05,
                       apc_alpha_lvl=0.05, aapc_alpha_lvl=0.05, jump_cr_alpha_lvl=0.05,
                       random_seed=7160, empirical_quantile_seed=10000,
                       empirical_quantile_seed_type=c("constant", "varying"),
                       n_resample=1000, madwd=FALSE, madwd_psi=0
) {
  txt = glue(.sep="\n", .null=NULL,
             "[Session Options]",
             f("Model", match.arg(model), missing(model)),
             f("Data shift", data_shift, missing(data_shift)),
             f("Minimum joinpoints", min_joinpoints, missing(min_joinpoints)),
             "Maximum joinpoints={max_joinpoints}",
             f("Pairwise", pairwise, missing(pairwise)),
             f("Pairwise significance level", pairwise_signif_lvl, missing(pairwise_signif_lvl)),
             f("Pairwise number of permutations", pairwise_n_permut, missing(pairwise_n_permut)),
             f("Method", match.arg(method), missing(method)),
             f("Min obs end", min_obs_end, missing(min_obs_end)),
             f("Min obs between", min_obs_between, missing(min_obs_between)),
             f("Num obs between", n_obs_between, missing(n_obs_between)),
             f("Model selection method", match.arg(model_selection_method), missing(model_selection_method)),
             f("Permutations significance level", permutation_signif_lvl, missing(permutation_signif_lvl)),
             f("Num permutations", n_permutations, missing(n_permutations)),
             f("Early stopping", match.arg(early_stopping), missing(early_stopping)),
             f("Run type", match.arg(run_type), missing(run_type)),
             f("Rates per N", rates_per_n, missing(rates_per_n)),
             f("Dependent variable type", match.arg(dependant_variable_type), missing(dependant_variable_type)),
             f("Het error", match.arg(het_error), missing(het_error)),
             f("Het error variable location", het_error_var_location, missing(het_error_var_location)),
             f("CI method", match.arg(ci_method), missing(ci_method)),
             "Num cores={n_cores}",
             f("Delay type", match.arg(delay_type), missing(delay_type)),
             f("Autocorr errors", match.arg(autocorr_errors), missing(autocorr_errors)),
             f("Jump model", tf(jump_model), missing(jump_model)),
             f("Comparability ratio", tf(comparability_ratio), missing(comparability_ratio)),
             f("Include standard analysis", tf(include_std_analysis), missing(include_std_analysis)),
             f("Jump location", jump_location, missing(jump_location)),
             f("Comparability ratio value", comparability_ratio_calue, missing(comparability_ratio_calue)),
             f("CR variance", cr_variance, missing(cr_variance)),
             f("Joinpoint alpha level", joinpoint_alpha_lvl, missing(joinpoint_alpha_lvl)),
             f("APC alpha level", apc_alpha_lvl, missing(apc_alpha_lvl)),
             f("AAPC alpha level", aapc_alpha_lvl, missing(aapc_alpha_lvl)),
             f("Jump CR alpha level", jump_cr_alpha_lvl, missing(jump_cr_alpha_lvl)),
             f("Random number generator seed", random_seed, missing(random_seed)),
             f("empirical quantile seed", empirical_quantile_seed, missing(empirical_quantile_seed)),
             f("empirical quantile seed type", match.arg(empirical_quantile_seed_type),
               missing(empirical_quantile_seed_type)),
             f("number of resamples", n_resample, missing(n_resample)),
             f("madwd", madwd, missing(madwd)),
             f("madwd psi value", madwd_psi, missing(madwd_psi))
  )
  txt
}
