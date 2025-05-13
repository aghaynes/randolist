#' Plot the imbalance of a randomisation sequence through time
#' @importFrom ggplot2 ggplot aes geom_line guides guide_none ylim labs
#' @noRd
imbplot <- function(data, col = FALSE, ymax, title){
  if(col){
    thisaes <- aes(x = rando_n, y = imbalance, col = int)
  } else {
    thisaes <- aes(x = rando_n, y = imbalance)
  }
  data |>
    ggplot(thisaes) +
    geom_line() +
    guides(col = guide_none()) +
    ylim(0, ymax) +
    labs(title = title,
         y = "Imbalance",
         x = "Randomisation number")
}
