#################################################################################################################
# custom_cld.R
#
# Function to generate and customise the Compact Letter Display (CLD).
#
#################################################################################################################

custom_cld <- function(x = NULL) {
  
  # Ensure that the required argument is provided
  if(is.null(x)) {
    stop("'x' must be provided.")
  }
  
  # Generate Compact Letter Display (CLD)
  output <- make_cld(obj = x,
            alpha = 0.05) %>%
    # Convert the CDL to a tibble
    as_tibble() %>%
    # Format testing groups by separating environment
    # and site with a dot
    mutate(group = str_replace(string = group,
                               pattern = " \\((.+)\\)",
                               replacement = "\\.\\1"))
  
  # Return output
  output
  
}

