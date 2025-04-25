#' Reformat a randolist object to the requirements of a database
#'
#' Databases generally require a specific format to be able to import a randomization
#' list. This function converts the randolist object to the format required by
#' REDCap or secuTrial.
#'
#' @param randolist a randolist object from `randolist` or `blockrand`
#' @param target_db the target database, either "REDCap" or "secuTrial"
#' @param strata_enc a list of data frames with the encoding of each stratification
#' variable. Should have two columns - the value used in `randolist` and code with
#' the values used in the database. See the examples for details.
#' @param rando_enc a data frame with the randomization encoding
#'
#' @details
#' `rando_enc` should contain an `arm` column containing the values supplied
#' to `randolist`, and a variable with the name required by the
#' database with the values that map to those in `arm`. See the examples.
#'
#' @importFrom dplyr select rename left_join mutate across all_of n
#' @importFrom rlang arg_match :=
#' @export
#'
#' @examples
#' r <- randolist(10,
#'                strata = list(sex = c("M", "F")),
#'                arms = c("T1", "T2"))
#' randolist_to_db(r,
#'   rando_enc = data.frame(arm = c("T1", "T2"),
#'                         rando_res = c(1, 2)),
#'   strata_enc = list(sex = data.frame(sex = c("M", "F"),
#'                                     code = 1:2)),
#'   target_db = "REDCap")
#' randolist_to_db(r,
#'   rando_enc = data.frame(arm = c("T1", "T2"),
#'                          rando_res = c(1, 2)),
#'   strata_enc = list(sex = data.frame(sex = c("M", "F"),
#'                                      code = 1:2)),
#'   target_db = "secuTrial")
randolist_to_db <- function(randolist,
                            target_db = c("REDCap", "secuTrial"),
                            strata_enc = NA,
                            rando_enc = NA){

  arm <- code <- Number <- NULL

  target_db <- arg_match(target_db, c("REDCap", "secuTrial"))
  stratavars <- attr(randolist, "stratavars")

  if(attr(randolist, "stratified")){
    if(!all(stratavars %in% names(strata_enc)))
      stop("All stratification variables must be in strata_enc")
    for(var in stratavars){
      # check that all used options exist
      if(!all(names(strata_enc[[var]]) == c(var, "code")))
        stop("strata_enc must contain a column named '", var, "' and a column named code")

      # replace
      randolist <- randolist |>
        left_join(strata_enc[[var]], by = var) |>
        select(- !!var) |>
        rename(!!var := code)
    }
  }

  if(target_db == "REDCap"){
    if(!is.data.frame(rando_enc)){
      stop("rando_encoding must be provided for REDCap")
    }
    if(!"arm" %in% names(rando_enc)){
      stop("rando_encoding must contain a column named 'arm'")
    }
    if(!all(randolist$arm %in% rando_enc$arm)){
      stop("rando_encoding must contain all arms in randolist")
    }
    out <- randolist |>
      select(all_of(stratavars), arm) |>
      left_join(rando_enc, by = "arm") |>
      select(-arm)
  }
  if(target_db == "secuTrial"){
    if(!is.na(rando_enc)){
      warning("rando_encoding ignored for secuTrial")
    }
    out <- randolist |>
      mutate(across(all_of(stratavars), ~ paste("value =", .x)),
             Number = 1:n()) |>
      select(Number, Group = arm, all_of(stratavars))
    warning("The SecuTrial target is untested and may require some adjustment")
  }
  return(out)
}
