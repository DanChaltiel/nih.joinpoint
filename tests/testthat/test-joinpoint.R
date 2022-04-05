

test_that("joinpoint", {
    skip_on_cran()

    run_opt = run_options(model="ln", max_joinpoints=2, n_cores=3)
    export_opt = export_options()

    #by, SE
    jp = joinpoint(sample_data, x=year, y=rate, by=sex, se=se,
                   run_opt_ini=run_opt, export_opt_ini=export_opt)
    expect_type(jp, "list")
})


test_that("joinpoint no BY, no SE", {
    skip_on_cran()

    run_opt = run_options(model="ln", max_joinpoints=2, n_cores=3)
    export_opt = export_options()

    #no by, no SE
    jp = joinpoint(sample_data, x=year, y=rate,
                   run_opt_ini=run_opt, export_opt_ini=export_opt)
    expect_type(jp, "list")
})
