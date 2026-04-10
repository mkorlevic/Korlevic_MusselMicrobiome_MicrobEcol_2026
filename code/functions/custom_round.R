#################################################################################################################
# custom_round.R
#
# Function to customise the rounding and formatting of numbers.
#
#################################################################################################################

custom_round <- function(x = NULL) {
  
  if (is.null(x)) {
    stop("Input x cannot be NULL.")
  }
  
  result <- format(x = round(x = x, digits = 2), nsmall = 2)
  
  return(result)
  
}

