#' Accessory function to calculate the probabilities proportional to Pascals triangle
#' @param n number of elements in the row
#' @noRd
pascalprops <- function(n){
  pascalvals <- choose(n-1, 0:(n-1))
  p <- pascalvals / n
  return(p)
}
