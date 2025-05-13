#' calculate imbalance.
#' Use of min and max allows to generalise to more than two arms.
#' @importFrom dplyr group_by count summarize
#' @noRd
imbalance <- function(x, var){
  x |>
    count({{ var }}, .drop = FALSE) |>
    summarize(imbalance = max(n) - min(n))
}
