#################################################################################################################
# custom_min_max.R
#
# Function to customise the rounding and formatting of the minimum and maximum values for the specified taxon.
#
#################################################################################################################

custom_min_max <- function(input = NULL, taxon = NULL) {
  
  # Ensure that the required arguments are provided
  if (is.null(input) || is.null(taxon)) {
    stop("'input' and 'taxon' must be provided.")
  }
  
  # To customise the rounding and formatting of values use the same function
  # used for rounding and formatting in submission/manuscript.Rmd and
  # submission/supplementary.Rmd rendering
  
  # (Modified code from submission/manuscript.Rmd or
  # submission/supplementary.Rmd)
  # Define a custom hook function to format output from inline R expressions
  # (This enables number formatting during inline R code execution.)
  inline_hook <- function(x){
    
    # Omit the printing of the values twice
#    print(x)
    
    if(is.list(x)){
      x <- unlist(x)
    }
    
    if(is.numeric(x)){
      if(abs(x - round(x)) < .Machine$double.eps ^ 0.5){
        paste(format(x, big.mark = ',', digits = NULL, scientific = FALSE))
      } else {
        paste(format(x, big.mark = ',', digits = 1, nsmall = 1, scientific = FALSE))
      }
    } else {
      paste(x)
    }
  }
  
  # Filter the taxon specified by the argument "taxon"
  result <- input %>%
    filter(taxon == {{ taxon }})
  
  # Customise the minimum and maximum values
  result <- paste0(
    inline_hook(x = result$min),
    "–",
    inline_hook(x = result$max))
  
  # Return the output
  return(result)
  
}

