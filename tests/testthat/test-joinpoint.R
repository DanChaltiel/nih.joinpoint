

test_that("joinpoint: default", {
  skip_on_cran()

  run_opt = run_options(model="ln", max_joinpoints=2, n_cores=3)

  #by, SE
  jp = joinpoint(nih_sample_data, x=year, y=rate, by=sex, se=se,
                 run_opts=run_opt)
  expect_type(jp, "list")
  expect_s3_class(jp, "nih.joinpoint")

  p = jp_plot(jp)
  expect_type(p, "list")
  expect_s3_class(p, "patchwork")

  expect_message(print(jp),
                 class="print_joinpoint")
})

test_that("joinpoint: linear, no BY, no SE", {
  skip_on_cran()

  run_opt = run_options(model="lin", max_joinpoints=2, n_cores=3)

  #no by, no SE
  jp = joinpoint(nih_sample_data, x=year, y=rate,
                 run_opts=run_opt)
  expect_type(jp, "list")
  expect_s3_class(jp, "nih.joinpoint")

  p = jp_plot(jp)
  expect_type(p, "list")
  expect_s3_class(p, "patchwork")
})


test_that("joinpoint: multiby", {
  skip_on_cran()

  run_opt = run_options(model="ln", max_joinpoints=2, n_cores=3)
  export_opt = export_options()

  set.seed(1)
  df=nih_sample_data %>%
    mutate(group=sample(c("A", "B", "C"), dplyr::n(), replace=TRUE))

  jp = joinpoint(df, x=year, y=rate, by=c(sex, group), se=se,
                 run_opts=run_opt, export_opts=export_opt, verbose=TRUE)

  jp$apc

  expect_error(jp_plot(jp),
               class="jp_plot_many_stratif_error")
})
