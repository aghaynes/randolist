#' calculate imbalance stratified by a variable
#' @importFrom dplyr group_by count summarize
#' @noRd
strataimbalance <- function(x, var, strata){
  x |>
    group_by({{ strata }}) |>
    count({{ var }}, .drop = FALSE) |>
    summarize(imbalance = max(n) - min(n))
}
