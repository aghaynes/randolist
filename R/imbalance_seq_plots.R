#' Depict the imbalance of a randomisation sequence through time
#'
#' It can be useful to see how imbalance changes through time. This function
#' allows such a depiction by plotting the maximum imbalance as a function of
#' randomisation number (assuming that the observations are in the randomisation
#' order). This is especially useful in the case of randomisation via
#' minimisation. As well as the overall imbalance, the function also depicts the
#' imbalance within each strata (i.e. the interaction among stratifying
#' variables) and within strata identified by each stratifying variable itself.
#' @param data a data frame
#' @param randovar variable name containing the randomisation result
#' @param stratavars variable names of stratification variables
#' @param cross logical whether to cross the stratification variables to create
#' the individual strata
#' @returns Up to six ggplots. Each has the randomisation sequence along the x-axis
#' and imbalance on the y-axis. The different lines denotes different groupings.
#' All plots are paired: the first plot shows the observed balance, the second
#' shows the balance in a simulated dataset. There are up to three pairs of plots.
#' - First the overall values are shown.
#' - Second, each line represents a group as defined by the stratification variables.
#' E.g., if there is a 2-level stratification variable and a 3-level variable, there
#' will be 5 lines.
#' - The third pair shows the individual strata - the combination of all stratification
#' variables. For the 2- and 3-level example mentioned above, this would result
#' in 6 lines. This can be skipped by setting `cross` to `FALSE`.
#' @importFrom purrr map_dfr
#' @importFrom dplyr mutate filter row_number
#' @importFrom ggplot2 ggplot aes geom_line ylim
#' @importFrom rlang sym
#' @importFrom cli cli_progress_message
#' @export
#' @examples
#' data(rando_balance)
#' # without stratification variables
#' imbalance_seq_plots(rando_balance, "rando_res")
#' # with stratification factors
#' imbalance_seq_plots(rando_balance, "rando_res",
#'                     c("strat1", "strat2"))
#' # do not cross the stratification factors
#' imbalance_seq_plots(rando_balance, "rando_res",
#'                     c("strat1", "strat2"),
#'                     cross = FALSE)
#'
imbalance_seq_plots <- function(data,
                                randovar,
                                stratavars = NULL,
                                cross = TRUE){
  rando_n <- simarm <- varval <- var <- NULL

  armf <- randovar
  data <- data |>
    mutate(rando_n = row_number(),
           simarm = factor(sample(unique(data[[armf]]),
                                  replace = TRUE,
                                  size = nrow(data))),
           )

  if(!is.null(stratavars) & cross){
    data <- data |>
      mutate(strata_interaction = interaction(data |>
                                              select(all_of(stratavars))))
    stratavars <- c(stratavars, "strata_interaction")
  }

  # sequential imbalance overall
  cli_progress_message("Calculating sequential imbalance (overall)")
  seq_imb_overall <- map_dfr(1:nrow(data), function(x){
    data |>
      filter(rando_n <= x) |>
      imbalance(!!sym(armf)) |>
      mutate(rando_n = x)
  })

  cli_progress_message("Calculating simulated sequential imbalance (overall)")
  seq_imb_overall_sim <- map_dfr(1:nrow(data), function(x){
    data |>
      filter(rando_n <= x) |>
      imbalance(simarm) |>
      mutate(rando_n = x)
  })

  omax <- max(seq_imb_overall$imbalance, seq_imb_overall_sim$imbalance)
  out <- list(
    overall_observed = seq_imb_overall |>
      imbplot(ymax = omax,
              title = "Overall imbalance (observed)",
              col = FALSE),
    overall_simulated = seq_imb_overall_sim |>
      imbplot(ymax = omax,
              title = "Overall imbalance (simulated)",
              col = FALSE)
  )

  # sequential imbalance by strata
  stratvars <- stratavars
  if(length(stratvars) > 0){
    cli_progress_message("Calculating sequential imbalance (strata)")
    seq_imb_strata <- map_dfr(stratvars, function(v){
      map_dfr(1:nrow(data), function(x){
        data |>
          group_by(!!sym(v)) |>
          filter(rando_n <= x) |>
          strataimbalance(!!sym(armf), !!sym(v)) |>
          mutate(rando_n = x)
      }) |>
        mutate(var = v) |>
        rename(varval = 1) |>
        mutate(varval = as.numeric(varval))
    }) |>
      mutate(int = interaction(varval, var))

    cli_progress_message("Calculating simulated sequential imbalance (strata)")
    seq_imb_strata_sim <- map_dfr(stratvars, function(v){
      map_dfr(1:nrow(data), function(x){
        data |>
          group_by(!!sym(v)) |>
          filter(rando_n <= x) |>
          strataimbalance(simarm, !!sym(v)) |>
          mutate(rando_n = x)
      }) |>
        mutate(var = v) |>
        rename(varval = 1) |>
        mutate(varval = as.numeric(varval))
    }) |>
      mutate(int = interaction(varval, var))

    max_imb2 <- max(seq_imb_strata$imbalance[seq_imb_strata$var != "strata_interaction"],
                    seq_imb_strata_sim$imbalance[seq_imb_strata_sim$var != "strata_interaction"],
                    na.rm = TRUE)


    if(cross){
      max_imb <- max(seq_imb_strata$imbalance[seq_imb_strata$var == "strata_interaction"],
                     seq_imb_strata_sim$imbalance[seq_imb_strata_sim$var == "strata_interaction"],
                     na.rm = TRUE)
      out$strata_observed <- seq_imb_strata |> #head()
        filter(var == "strata_interaction") |>
        imbplot(ymax = max_imb,
                title = "Imbalance within strata (observed)",
                col = TRUE)

      out$strata_simulated <- seq_imb_strata_sim |> #head()
        filter(var == "strata_interaction") |>
        imbplot(ymax = max_imb,
                title = "Imbalance within strata (simulated)",
                col = TRUE)
    }

    out$stratavar_oberved <- seq_imb_strata |> #head()
      filter(var != "strata_interaction") |>
      imbplot(ymax = max_imb2,
              title = "Imbalance within stratifying variables (observed)",
              col = TRUE)

    out$stratavar_simulated <- seq_imb_strata_sim |> #head()
      filter(var != "strata_interaction") |>
      imbplot(ymax = max_imb2,
              title = "Imbalance within stratifying variables (simulated)",
              col = TRUE)
  }
  return(out)
}



