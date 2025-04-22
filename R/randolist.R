#' Generate randomisation lists
#'
#' Randomisation lists are central to randomised trials. This function allows
#' to generate randomisation lists simply, via (optionally) stratified block randomisation
#'
#' @param n total number of randomizations (per stratum)
#' @param arms arms to randomise
#' @param strata named list of stratification variables (see examples)
#' @param blocksizes numbers of each arm to include in blocks (see details)
#' @param pascal logical, whether to use pascal's triangle to determine block sizes
#' @param ... arguments passed on to other methods (e.g. blockrand)
#'
#' @details \code{blocksizes} defines the number of allocations to each arm in a block.
#' For example, if there are two arms, and \code{blocksizes} = 1, each block will
#' contain 2 randomisations. If \code{blocksizes} = \code{1:2}, each block will
#' contain either one of each arm, or two of each arm. Total block sizes are
#' therefore  \code{blocksizes * length(arms)}.
#'
#' By default, frequency of the different block sizes is determined using Pascal's
#' triangle.
#' This has the advantage that small and large block sizes are less common than
#' intermediate sized blocks, which helps with making it more difficult to guess
#' future allocations, and reduces the risk of finishing in the middle of a large
#' block.
#'
#' Unbalanced randomization is possible by specifying the same arm label multiple times.
#'
#' To disable block randomisation, set \code{blocksizes} to the same value as \code{n}.
#'
#' @export
#' @seealso [blockrand()]
#'
#' @examples
#' # example code
#' randolist(10)
#' # one stratifying variable
#' randolist(10, strata = list(sex = factor(1:2, levels = 1:2, labels = c("M", "F"))))
#' # two stratifying variables
#' randolist(10, strata = list(sex = factor(1:2, levels = 1:2, labels = c("M", "F")),
#'                             age = factor(1:2, levels = 1:2, labels = c("child", "adult"))))
#' # different arm labels
#' randolist(10, arms = c("arm 1", "arm 2"))
#'
#' # unbalanced (2:1) randomization
#' randolist(10, arms = c("arm 1", "arm 1", "arm 2"))
#'
#'
randolist <- function(n, arms = LETTERS[1:2], strata = NULL, blocksizes = 1:3, ...){

  if(is.null(strata)) {

    rlist <- blockrand(n = n, arms = arms, blocksizes = blocksizes, ...)

  } else {

    grid <- expand.grid(strata)
    grid$strata_txt <- apply(grid, 1, function(x) paste(x, collapse = "; "))
    grid$stratum <- nth <- 1:nrow(grid)


    rlist <- lapply(seq_along(nth), function(x){
      # get the current stratum
      stratum <- nth[x]

      # generate randomization for this stratum
      rlist <- blockrand(n = n, arms = arms, blocksizes = blocksizes, ...)

      # add stratum information to the randomization
      rlist$stratum <- stratum

      # return the randomization
      rlist
    }) |> do.call(what = "rbind") |>
      merge(grid, by = "stratum")

    class(rlist) <- c("randostratalist", class(rlist))
  }

  attr(rlist, "ratio") <- table(arms) |> paste(collapse = ":")
  attr(rlist, "arms") <- unique(arms)
  attr(rlist, "stratavars") <- names(strata)

  return(rlist)
}




