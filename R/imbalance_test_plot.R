#' Plot imbalance and simulation and test results
#'
#' Plot histograms of imbalance values from simulation results and a vertical
#' lines to indicate the observed imbalance for each randomisation level (overall,
#' stratification variable level, and strata level, where appropriate). The
#' p-values from the tests are included in the figure captions.
#'
#' @param test `imbalance_test` object
#' @param vline_col colour for the vertical line indicating the observed imbalance
#' @param stack logical, whether to use `patchwork::wrap_plots` to stack the
#' plots in one column (`TRUE`) or return a list of ggplot objects (`FALSE`)
#' @importFrom ggplot2 geom_histogram geom_vline
#' @importFrom patchwork wrap_plots
#' @seealso [imbalance_test()]
#' @export
#' @examples
#' # example code
#' data(rando_balance)
#' # without stratification variables
#' imb <- imbalance_test(rando_balance, "rando_res2", stratavars = c("strat1", "strat2"))
#' imbalance_test_plot(imb)
#'


imbalance_test_plot <- function(test, vline_col = "red", stack = TRUE){

  if(!class(test)[1] == "imbalance")
    stop("`test` should be created via `imbalance_test`")
  if(!is.logical(stack))
    stop("`stack` should be a logical")

  out <- list()

  # overall
  out$overall <- test$simulated |>
    ggplot(aes(x = overall)) +
    geom_histogram(binwidth = 1) +
    geom_vline(xintercept = test$observed$overall, col = vline_col) +
    labs(title = "Overall observed imbalance",
         y = "Count",
         x = "Imbalance in simulated data",
         caption = paste("P =", test$tests$overall))

  # stratavars
  if(!is.na(test$tests$stratavars)){
    out$stratavars <- test$simulated |>
      ggplot(aes(x = stratavars)) +
      geom_histogram(binwidth = 1) +
      geom_vline(xintercept = test$observed$stratavars, col = vline_col) +
      labs(title = "Imbalance within stratifying variables",
           y = "Count",
           x = "Imbalance in simulated data",
           caption = paste("P =", test$tests$stratavars))
  }

  # strata
  if(!is.na(test$tests$strata)){
    out$strata <- test$simulated |>
      ggplot(aes(x = strata)) +
      geom_histogram(binwidth = 1) +
      geom_vline(xintercept = test$observed$strata, col = vline_col) +
      labs(title = "Imbalance within strata",
           y = "Count",
           x = "Imbalance in simulated data",
           caption = paste("P =", test$tests$strata))
  }

  if(stack){
    out <- wrap_plots(out, ncol = 1)
  }

  return(out)

}




