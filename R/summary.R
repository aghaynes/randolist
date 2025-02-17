#' @export
summary.randolist <- function(object, ...){
  cat("Randomisation list\n")
  cat("Number of randomizations: ", nrow(object), "\n")
  cat("Number of blocks: ", length(unique(object$block)), "\n")
  cat("Block sizes:")
  print(table(object$blocksize[object$seq_in_block == 1]))
  cat("Arms: ")
  print(table(object$arm))
  invisible(object)
}








