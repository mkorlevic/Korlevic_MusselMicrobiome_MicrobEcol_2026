#################################################################################################################
# custom_clean_taxonomy.R
#
# Function to clean the taxonomy data.
#
#################################################################################################################

custom_clean_taxonomy <- function(input = NULL, control = NULL, remove_chloroplast = FALSE) {
  
  # Ensure that the required arguments are provided
  if(is.null(input) || is.null(control)) {
    stop("'input' and 'control' must be provided.")
  }
  
  # Remove the row containing the total number of sequences
  taxonomy <- input %>%
    filter(taxon != "Root")
  
  # Get rankID for eukaryotic sequences
  eukaryota <- taxonomy %>%
    filter(taxon == "Eukaryota") %>%
    select(rankID)
  # Remove eukaryotic sequences
  taxonomy <- taxonomy %>%
    filter(!str_detect(string = rankID, pattern = paste0("^", eukaryota)))
  
  # Get rankID for mitochondrial sequences
  mitochondria <- taxonomy %>%
    filter(taxon == "Mitochondria") %>%
    select(rankID)
  # Remove mitochondrial sequences and subtract their number from higher taxonomic levels to which they belong
  taxonomy <- taxonomy %>%
    # Subtract mitochondrial sequence number from higher taxonomic levels to which it belongs
    mutate(across(.cols = total : last_col(), .fns = ~ case_when(
      rankID == str_extract(string = mitochondria, pattern = "(\\d+\\.){4}\\d+") ~ .x - .x[rankID == mitochondria$rankID],
      rankID == str_extract(string = mitochondria, pattern = "(\\d+\\.){3}\\d+") ~ .x - .x[rankID == mitochondria$rankID],
      rankID == str_extract(string = mitochondria, pattern = "(\\d+\\.){2}\\d+") ~ .x - .x[rankID == mitochondria$rankID],
      rankID == str_extract(string = mitochondria, pattern = "(\\d+\\.){1}\\d+") ~ .x - .x[rankID == mitochondria$rankID],
      TRUE ~ .x))) %>%
    # Remove mitochondrial sequences
    filter(!str_detect(string = rankID, pattern = paste0("^", mitochondria)))
  
  # Get rankID for chloroplast sequences
  chloroplast <- taxonomy %>%
    filter(taxon == "Chloroplast") %>%
    select(rankID)
  # If required, remove chloroplast sequences and subtract their number from higher taxonomic levels to which they belong
  if(remove_chloroplast == TRUE) {
    taxonomy <- taxonomy %>%
      # Subtract chloroplast sequence number from higher taxonomic levels to which it belongs
      mutate(across(.cols = total : last_col(), .fns = ~ case_when(
        rankID == str_extract(string = chloroplast, pattern = "(\\d+\\.){3}\\d+") ~ .x - .x[rankID == chloroplast$rankID],
        rankID == str_extract(string = chloroplast, pattern = "(\\d+\\.){2}\\d+") ~ .x - .x[rankID == chloroplast$rankID],
        rankID == str_extract(string = chloroplast, pattern = "(\\d+\\.){1}\\d+") ~ .x - .x[rankID == chloroplast$rankID],
        TRUE ~ .x))) %>%
      # Remove chloroplast sequences
      filter(!str_detect(string = rankID, pattern = paste0("^", chloroplast)))
  }
  
  # Remove positive (mock community) and negative controls
  taxonomy <- taxonomy %>%
    select(-all_of(control))
  
  # Calculate the proportion of each taxon
  taxonomy <- taxonomy %>%
    group_by(taxlevel) %>%
    mutate(across(.cols = total : last_col(), .fns = ~ .x / sum(.x) * 100)) %>%
    ungroup()
  
  # Return output
  taxonomy
  
}

