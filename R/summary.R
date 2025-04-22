#' Summary method for randolist objects
#' @param object a randolist object
#' @param ... additional arguments (currently unused)
#' @export
summary.randolist <- function(object, ...){
  cat("Number of randomizations: ", nrow(object), "\n")
  cat("Number of blocks: ", length(unique(object$block_in_strata)), "\n")
  cat("Block sizes:")
  print(table(object$blocksize[object$seq_in_block == 1]))
  cat("Arms: ")
  print(table(object$arm))
  invisible(object)
}


#' @describeIn summary.randolist summary.randolist
#' @export
summary.randostratalist <- function(object, ...){

  cat("Randomization ratio:", attr(object, "ratio"), "\n")
  cat("Randomization groups: ", attr(object, "arms"), "\n")
  cat("Total number of randomisations: ", nrow(object), "\n")
  print(table(object$arm))
  cat("Number of strata: ", length(unique(object$strata)), "\n")

  stratavars <- attr(object, "stratavars")
  cat("Variables defining strata: ", paste(stratavars, collapse = ", "), "\n")
  sapply(stratavars, function(x){
    cat("  ", x, ":")
    print(table(object[[x]]))
    print(table(object[[x]], object$arm))
  })

  cat("\nStrata:")
  print(table(object$strata_txt))
  cat("\n")

  split(object, object$stratum) |> #str()
    lapply(function(x){
      cat("Strata:", x$strata_txt[1], "\n")
      summary.randolist(x)
      cat("\n")
      return(invisible(NULL))
      })

  return(invisible(NULL))
}




