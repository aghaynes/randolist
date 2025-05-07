#' Summary method for randolist objects
#' @param object a randolist object
#' @param ... additional arguments (currently unused)
#' @noRd
summary_int <- function(object, ...){
  # cat("Number of randomizations: ", nrow(object), "\n")
  # cat("Number of blocks: ", length(unique(object$block_in_strata)), "\n")
  # cat("Block sizes:")
  # print(table(object$blocksize[object$seq_in_block == 1]))
  # cat("Arms: ")
  # print(table(object$arm))
  # invisible(object)

  list(
    n_rando = nrow(object),
    n_blocks = length(unique(object$block_in_strata)),
    block_sizes = table(object$blocksize[object$seq_in_block == 1]),
    arms = table(object$arm),
    ratio = attr(object, "ratio")
  )
}


#' Summary method fro randolist objects
#'
#' Create a short summary report of the aspects of the randomisation list, which
#' could be used for quality control.
#'
#' @param object randolist object
#' @param ... additional arguments (currently unused)
#' @export
#' @examples
#' r <- randolist(20)
#' print(summary(r))
#'
#' r2 <- randolist(20, strata = list(sex = c("M", "F")))
#' print(summary(r2))
#'
#' # NOTE: explicitly printing isn't technically necessary
#'
summary.randolist <- function(object, ...){

  stratified <- attr(object, "stratified")

  out <- summary_int(object, ...)

  if(stratified){
    out <- c(out,
      list(
        stratified = stratified,
        stratavars = attr(object, "stratavars"),
        stratavars_tabs = lapply(attr(object, "stratavars"), function(x){
          list(
            levels = table(object[[x]]),
            levels_by_arm = table(object[[x]], object$arm)
          )
        }),
        strata = table(object$strata_txt),
        stratum_tabs = lapply(split(object, object$stratum), function(x){
          list(
            stratum_txt = x$strata_txt[1],
            summary = summary_int(x)
          )
        })
      )
    )
  } else {
    out <- c(out,
             list(stratified = stratified,
                  stratavars = NA,
                  stratavars_tabs = NA,
                  strata = NA,
                  stratum_tabs = NA))
  }

  class(out) <- c("randolistsum", class(out))

  return(out)

}

#' @export
#' @importFrom glue glue_collapse
print.randolistsum <- function(x, ...){

  cat("---- Randomisation list report ----\n")
  cat("-- Overall\n")

  cat("Total number of randomisations: ", x$n_rando, "\n")
  cat("Randomisation groups: ", paste(names(x$arms), collapse = " : "), "\n")
  cat("Randomisation ratio:", x$ratio, "\n")

  cat("Randomisations to each arm:")
  print(x$arms)

  cat("Block sizes:")
  print(x$block_sizes)


  if(x$stratified){
    cat("-- Stratifier level \n")

    cat("Randomisation list is stratified by variables", glue_collapse(x$stratavars, ", ", last = " and "), "\n")
    lapply(seq_along(x$stratavars),
           function(y){
             cat("- ", y, "\n")
             cat("Randomisations per level of", x$stratavars[y], ":")
             print(x$stratavars_tabs[[y]]$levels)
             cat("Balance per level of", x$stratavars[y], ":")
             print(x$stratavars_tabs[[y]]$levels_by_arm)
           })

    cat("-- Stratum level \n")
    cat(nrow(x$strata), "strata are defined:\n")
    print(x$strata)

    lapply(seq_along(x$stratum_tabs),
           function(y){
             cat("- ", names(x$strata)[y], "\n")
             # print(x$stratum_tabs[[x]]$summary)
             cat("Number of randomisations: ", x$stratum_tabs[[y]]$summary$n_rando)
             print(x$stratum_tabs[[y]]$summary$arms)

             cat("Block sizes: ")
             print(x$stratum_tabs[[y]]$summary$block_sizes)
           })

  }

}



