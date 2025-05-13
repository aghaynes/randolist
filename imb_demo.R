n <- 100
dat <- data.frame(x = sample(1:3, n, replace = TRUE, prob = c(4, 2, 2)),
                  y = sample(1:3, n, replace = TRUE, prob = c(.4, .4, .2)),
                  z = sample(1:3, n, replace = TRUE, prob = c(.2, .2, .6)),
                  arm = sample(1:2, n, TRUE))

randres <- dat


check_randomness <- function(randres, stratavars, armvar, datevar, nsim = 10){

}

# 1982 do-it test minization example
randres <- readr::read_csv("1982_DO-IT RCT_rando_result_20241205.csv")
stratavars <- c("v25532_1_mnpp1982_eligibility_rando_strat_nihss", "v25532_1_mnpp1982_eligibility_rando_strat_doac" )
arm <- "mnp_rando_done_gr"
datevar <- "mnp_rando_done_assigndate"

# names(randres)[names(randres) %in% stratavars] <- paste0("strata_", seq(stratavars))
# names(randres)[names(randres) %in% arm] <- "arm"
# names(randres)[names(randres) %in% datevar] <- "rando_tpt"
#
# dat <- randres[, c("arm", paste0("strata_", seq(stratavars)), "rando_tpt")]
# dat$interaction <- interaction(dat[, paste0("strata_", seq(stratavars))])
# dat$armf <- factor(dat$arm, labels = paste0("arm", seq(length(unique(dat$arm)))))
# dat$simarm <- factor(sample(levels(dat$armf), nrow(dat), replace = TRUE))

randres |> #names()
  rename(rando_res = v25532_1_mnpp1982_eligibility_rando_done,
         nihss = v25532_1_mnpp1982_eligibility_rando_strat_nihss,
         doac = v25532_1_mnpp1982_eligibility_rando_strat_doac) |>
  imbalance_seq_plots(randovar = "rando_res",
                      stratavars = c("nihss", "doac"))



# overall
dat |> imbalance(armf)

library(dplyr)

sim <- function(){
  dat |>
    mutate(simarm = sample(unique(armf), n(), replace = TRUE)) |>
    imbalance(simarm)
}

sim_imbalance <- bind_rows(lapply(seq(nsim), function(x) sim()))

p <- mean(sim_imbalance$imbalance < ((dat |> imbalance(armf))$imbalance))

# stratified (strata level)

dat |>
  strataimbalance(armf, interaction)

sim2 <- function(){
  dat |>
    mutate(simarm = sample(unique(armf), n(), replace = TRUE)) |>
    strataimbalance(simarm, interaction)
}
sim_strataimbalance <- bind_rows(lapply(seq(nsim), function(x) sim2()))

# stratified (variable level)
lapply(names(dat)[names(dat) %in% paste0("strata_", seq(stratavars))],
        function(x) {
          strataimbalance(dat, armf, !!sym(x))
  # dat |>
  #   strataimbalance(armf, {{ x }})
})

sim3 <- function(){
  tmp <- dat |>
    mutate(simarm = sample(unique(armf), n(), replace = TRUE))
  lapply(names(dat)[names(dat) %in% paste0("strata_", seq(stratavars))],
         function(x) strataimbalance(tmp, simarm, !!sym(x)))
}

lapply(seq(nsim), function(y) sim3())
