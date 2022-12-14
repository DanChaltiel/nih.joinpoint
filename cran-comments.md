
## Test environments

* local R installation, `R 4.1.2`
* `check_rhub(build_args="--no-build-vignettes", check_args="--no-build-vignettes --as-cran")`
* `check_win_devel(args="--no-build-vignettes")`


## R CMD check results

There were no ERROR, WARNING or NOTE locally.
There were WARNINGs about vignettes on rhub and win_devel that could not be solved, as explained below.
        

## Comments

* This package is an API over some NIH's software that comes separately and is subject to appliance. I wrote it for myself and it increased my productivity by a whole lot, so I figured I should share it. I am not affiliated to NIH but this package does not break the Terms of Use Agreement, as long as I do not share a copy of the software (which I obviously don't).

* Therefore, this package needs another software installed (on Windows), so testing or running any example is not possible. The vignette was generated using an an appropiate environment and should not be re-generated during checkup, hence the arguments for `R CMD` in `check_rhub()`. However, the end-user that has the software installed might re-generate the vignette if needed.
