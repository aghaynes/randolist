#' Test the imbalance of randomisation via simulation
#'
#' This function tests whether the observed imbalance is less than might be
#' expected via a random draw, via a permutation test.
#'
#' @param data a dataframe with the variables indicated in `randovar` and,
#' optionally, `stratavars`
#' @param randovar character with the variable name indicating the randomisation
#' @param n_iter integer. number of simulations to perform
#' @param stratavars character vector with the variable names indicating the
#' stratification variables
#' @param arms character vector of arms in the appropriate balance. If NULL the
#' levels in `randovar` are used and assumed to be balanced
#' @param cross logical. Whether to cross the stratification variables.
#' @param ... other arguments passed onto other methods
#'
#' @returns a list with:
#' \itemize{
#'   \item \code{n_rando}: the number of randomisations
#'   \item \code{stratavars}: the names of the stratification variables
#'   \item \code{arms}: the arms
#'   \item \code{observed}: a dataframe with the observed imbalance
#'   \item \code{simulated}: a dataframe with the simulated imbalances (number of rows = \code{nrow(n_iter)})
#'   \item \code{tests}: a dataframe with the p-values
#' }
#' @export
#' @importFrom dplyr bind_rows
#' @importFrom cli cli_progress_along
#' @seealso [imbalance_test_plot()]
#'
#' @examples
#' data(rando_balance)
#' # without stratification variables
#' imbalance_test(rando_balance, "rando_res")
#' imb <- imbalance_test(rando_balance, "rando_res", stratavars = "strat1")
#' imbalance_test(rando_balance, "rando_res", stratavars = c("strat1", "strat2"))
#' imb <- imbalance_test(rando_balance, "rando_res2", stratavars = c("strat1", "strat2"))

imbalance_test <- function(data,
                           randovar,
                           n_iter = 1000,
                           stratavars = NULL,
                           arms = NULL,
                           cross = TRUE, ...){

  simrando <- strata_interaction <- overall <- NULL

  if(is.null(arms)){
    message("assuming balanced randomisation between arms")
    arms <- unique(data[[randovar]])
  }

  sim <- function(){
    data$simrando <- factor(sample(arms, nrow(data), replace = TRUE))
    data
  }
  if(cross & !is.null(stratavars)){
    if(length(stratavars) > 1){
      data$strata_interaction <- interaction(data[, stratavars])
    } else {
      cross <- FALSE
    }
  }

  simres <- lapply(cli_progress_along(1:n_iter,
                                      name = "Simulating randomisations"),
                   function(iter){
    d <- sim()
    out <- list(
      overall = imbalance(d, simrando)$imbalance,
      stratavars = NA,
      strata = NA
    )
    if(!is.null(stratavars)){
      out$stratavars <- max(sapply(stratavars, function(svar){
         max(strataimbalance(d, simrando, !!svar)$imbalance)
        }))
      if(cross){
        out$strata <- max(
          strataimbalance(d, simrando,
                          strata_interaction)$imbalance)

      }
    }
    return(out)
  }) |> bind_rows()

  obs <- list(
    overall = imbalance(data, !!sym(randovar))$imbalance,
    stratavars = NA,
    strata = NA
  )
  if(!is.null(stratavars)){
    obs$stratavars <- max(sapply(stratavars, function(svar){
      max(strataimbalance(data, !!sym(randovar), !!sym(svar))$imbalance)
    }))
    if(cross){
      obs$strata <- max(
        strataimbalance(data, !!sym(randovar),
                        strata_interaction)$imbalance)
    }
  }

  # test
  tests <- sapply(c("overall", "stratavars", "strata"),
         function(lvl){
           if(!is.na(obs[[lvl]])){
             out <- mean(obs[[lvl]] >= simres[[lvl]])
           } else {
             out <- NA
           }
           return(out)
         }, simplify = FALSE)

  out <- list(n_rando = nrow(data),
              stratavars = stratavars,
              arms = arms,
              observed = obs,
              simulated = simres,
              tests = tests)

  class(out) <- c("imbalance", class(out))

  return(out)

}



#' @export
print.imbalance <- function(x, ...){
  n_iter <- nrow(x$simulated)

  cat("Randomisations to date:", x$n_rando, "\n")
  cat("Overall imbalance:", x$observed$overall, "\n")
  cat("  Probability of equal or less imbalance from random allocation:", x$tests$overall, "\n")

  if(!is.na(x$tests$stratavars)){
    cat("\nRandomisation stratified by", glue_collapse(x$stratavars, ", ", last = " and "), "\n")
    cat("Maximum observed imbalanced within stratifying variables:", x$observed$stratavars, "\n")
    cat("  Probability of equal or less imbalance from random allocation:", x$tests$stratavars, "\n")
    if(!is.na(x$tests$strata)){
      cat("Maximum observed imbalanced within individual strata:", x$observed$strata, "\n")
      cat("  Probability of equal or less imbalance from random allocation:", x$tests$strata, "\n")
    }
  }


}











