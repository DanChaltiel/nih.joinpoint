

test_that("joinpoint: default", {
    skip_on_cran()

    run_opt = run_options(model="ln", max_joinpoints=2, n_cores=3)
    export_opt = export_options()

    #by, SE
    jp = joinpoint(nih_sample_data, x=year, y=rate, by=sex, se=se,
                   run_opts=run_opt, export_opts=export_opt)
    expect_type(jp, "list")

    p = jp_plot(jp, ncol=1)
    expect_type(p, "list")
    expect_s3_class(p, "patchwork")
})


test_that("joinpoint: linear, no BY, no SE", {
    skip_on_cran()

    run_opt = run_options(model="lin", max_joinpoints=2, n_cores=3)
    export_opt = export_options()

    #no by, no SE
    jp = joinpoint(nih_sample_data, x=year, y=rate,
                   run_opts=run_opt, export_opts=export_opt)
    expect_type(jp, "list")

    p = jp_plot(jp)
    expect_type(p, "list")
    expect_s3_class(p, "patchwork")
})
