#' Block randomization
#'
#' @param n total number of randomizations (within a single strata)
#' @param arms number of arms to randomise
#' @param blocksizes vector of numbers of each arm to include in blocks
#' @param pascal logical, whether to use pascal's triangle to determine block sizes
#'
#' @returns a data frame with columns block, blocksize, seq_in_block, arm
#' @export
#'
#' @examples
#'
#' blockrand(100, blocksizes = c(1, 2))
#'
blockrand <- function(n,
                      arms = LETTERS[seq(2)],
                      blocksizes = 1:4,
                      pascal = TRUE
                      ){

  N_per_block <- blocksizes * length(arms)

  if(pascal) {
    p <- pascalprops(length(N_per_block))
  } else {
    p <- rep(1 / length(N_per_block), length(N_per_block))
  }

  # estimate number of required blocks
  min_blocks <- ceiling(n / min(N_per_block))

  # generate block sizes
  blocks <- sample(N_per_block, min_blocks, replace = TRUE, prob = p)

  # select blocks to reach n
  blocks <- blocks[1:min(which(cumsum(blocks) >= n))]

  # generate randomization
  rlist <- lapply(seq_along(blocks), function(i){
    arms_i <- rep(arms, each = blocks[i] / length(arms))

    # output dataframe
    data.frame(block = i,
               blocksize = blocks[i],
               seq_in_block = 1:blocks[i],
               arm = sample(arms_i, blocks[i]))
  }) |> do.call(what = rbind)
  rlist$seq_in_list <- seq_len(nrow(rlist))
  rlist <- rlist[, c("seq_in_list", "block", "blocksize", "seq_in_block", "arm")]

  return(rlist)
}
