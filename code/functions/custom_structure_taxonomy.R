#################################################################################################################
# custom_structure_taxonomy.R
#
# Function to filter and structure the taxonomy data.
#
#################################################################################################################

custom_structure_taxonomy <- function(input = NULL,
                                      metadata = NULL,
                                      taxa_colour = NULL,
                                      select_environment = NULL,
                                      select_taxlevel = NULL,
                                      threshold = NULL,
                                      include_chloroplast = FALSE,
                                      split_pseudomonadota = FALSE) {
  
  #################################################################
  # Argument validation
  #################################################################
  
  # Ensure that the required arguments are provided and are of the
  # correct type
  if(is.null(x = input) || !is_tibble(x = input)) {
    stop("'input' must be a tibble.")
  }
  if(is.null(x = metadata) || !is_tibble(x = metadata)) {
    stop("'metadata' must be a tibble.")
  }
  if(is.null(x = select_taxlevel) || !is.numeric(x = select_taxlevel)) {
    stop("'select_taxlevel' must be a numeric value.")
  }
  if(is.null(x = threshold) || !is.numeric(x = threshold)) {
    stop("'threshold' must be a numeric value.")
  }
  
  #################################################################
  # Get rank IDs for groups of interest
  #################################################################
  
  # Get rank ID for chloroplast
  chloroplast <- input %>%
    filter(taxon == "Chloroplast") %>%
    select(rankID)
  
  # Get rank ID for Pseudomonadota
  pseudomonadota <- input %>%
    filter(taxon == "Pseudomonadota") %>%
    select(rankID)
  
  #################################################################
  # Select samples for data structuring and
  # customise the sequences without known relatives
  #################################################################
  
  # If required, filter the metadata to select samples
  # belonging to a specified environment
  if (!is.null(select_environment)) {
    metadata <- metadata %>%
      filter(environment == select_environment)
  }
  
  input <- input %>%
    # Select the samples for data structuring
    select(c(1 : total, all_of(x = metadata$id))) %>%
    # Rename the taxon that groups sequences without known
    # relatives from "unknown" (taxlevel == 1) or
    # "unknown_unclassified" (other taxlevels) to "No_Relative"
    mutate(taxon = if_else(condition = taxon %in% c("unknown",
                                                    "unknown_unclassified"),
                           true = "No_Relative",
                           false = taxon))
  
  #################################################################
  # Select the taxa for data structuring
  #################################################################
  
  input <- input %>%
    # Select the taxonomic level for data structuring
    filter(taxlevel == select_taxlevel |
             # If required, split the Pseudomonadota phylum to classes
             (split_pseudomonadota == TRUE &
                # Split the Pseudomonadota phylum only if the selected
                # taxonomic level is phylum (taxlevel == 2)
                select_taxlevel == 2 &
                # Filter the Pseudomonadota classes
                taxlevel == 3 &
                # Filter the Pseudomonadota classes based on the Pseudomonadota
                # rank ID
                str_detect(string = rankID, pattern = paste0("^", pseudomonadota, "."))) |
             # If required, filter the chloroplast
             (include_chloroplast == TRUE &
                # Filter the chloroplast only if the selected
                # taxonomic level is phylum (taxlevel == 2)
                select_taxlevel == 2 &
                # Filter the chloroplast base on its rank ID
                rankID %in% chloroplast$rankID))
  
  #################################################################
  # If required, subtract the chloroplast proportion from the
  # phylum to which it belongs
  #################################################################
  
  # Subtract the chloroplast proportion only if required
  if(include_chloroplast == TRUE) {
    # Ensure that the selected taxonomic level is phylum
    # (taxlevel == 2)
    if(select_taxlevel != 2) {
      stop("Cannot subtract chloplast if taxlevel is not 2 (phylum).")
    } else {
      input <- input %>%
        # Subtract the chloroplast proportion based on its rank ID
        mutate(across(.cols = total : last_col(), .fns = ~ case_when(
          rankID == str_extract(string = chloroplast, pattern = "(\\d+\\.){2}\\d+")
          ~ .x - .x[rankID == chloroplast$rankID],
          TRUE
          ~ .x)))
    }
  }
  
  #################################################################
  # Filter the taxa
  #################################################################
  
  input <- input %>%
    # Filter the taxa based on the defined threshold value
    filter(if_any(.cols = total : last_col(), .fns = ~ .x >= threshold))
  
  #################################################################
  # If the Pseudomonadota phylum is split, subtract the
  # Pseudomonadota classes above the threshold value from the
  # total Pseudomonadota
  #################################################################
  
  # Subtract the Pseudomonadota classes only if the Pseudomonadota
  # phylum is split
  if(split_pseudomonadota == TRUE) {
    # Ensure that the selected taxonomic level is phylum
    # (taxlevel == 2)
    if(select_taxlevel != 2){
      stop("Cannot subtract Pseudomonadota classes if taxlevel is not 2 (phylum).")
    } else {
      # Group all the taxa below the threshold value to "Other_Pseudomonadota"
      # if the threshold value is above 0 and below or equal to 100
      if(threshold > 0 && threshold <= 100) {
        input <- input %>%
          # Subtract the Pseudomonadota classes based on their rank ID
          mutate(across(.cols = total : last_col(), .fns = ~ case_when(
            rankID == pseudomonadota$rankID
            ~ .x - sum(.x[rankID = str_detect(string = rankID, pattern = paste0("^", pseudomonadota, "."))]),
            TRUE
            ~ .x))) %>%
          # Rename "Pseudomonadota" to "Other_Pseudomonadota"
          mutate(taxon = if_else(condition = (split_pseudomonadota == TRUE &
                                              taxon == "Pseudomonadota"),
                                 true = "Other_Pseudomonadota",
                                 false = taxon))
      } else {
        # Else print a warning message and remove "Pseudomonadota"
        warning("Threshold value is out of the valid range (0 < threshold <= 100).
                Calculation of \"Other_Pseudomonadota\" skipped.
                Phylum Psedumonadota removed.")
        # Remove "Pseudomonadota"
        input <- input %>%
          filter(taxon != "Pseudomonadota")
      }
      # Filter again the taxa based on the defined threshold value to exclude
      # "Other_Pseudomonadota" if its proportion is below the threshold value
      input <- input %>%
        filter(if_any(.cols = total : last_col(), .fns = ~ .x >= threshold))
    }
  }
  
  #################################################################
  # Customise the data
  #################################################################
  
  # Group all the taxa below the threshold value to "Other"
  if(threshold > 0 && threshold <= 100) {
    # Group all the taxa below the threshold value to "Other" if
    # the threshold value is above 0 and below or equal to 100
    input <- input %>%
      bind_rows(tibble(taxlevel = select_taxlevel,
                       rankID = NA,
                       taxon = "Other",
                       daughterlevels = NA,
                       summarise(.data = ., across(.cols = total : last_col(),
                                                   .fns = ~ 100 - sum(.x)))))
  } else {
    # Else print a warning message
    warning("Threshold value is out of the valid range (0 < threshold <= 100). Calculation of \"Other\" skipped.")
  }
  
  # Ensure that "No_Relative" is the last in the column
  input <- input %>%
    arrange(taxon %in% "No_Relative")
  
  #################################################################
  # Combine taxonomy data and metadata
  #################################################################
  
  # Transform sequence proportion data into a tidy long format,
  # where "sample" contains the names of the samples and "proportion" represents
  # their corresponding numerical proportions
  longer <- input %>%
    pivot_longer(cols = -c(taxlevel, rankID, taxon, daughterlevels, total),
                 names_to = "sample",
                 values_to = "proportion",
                 values_drop_na = FALSE)
  
  # Join metadata and taxonomy data
  metadata_longer <- left_join(x = metadata,
                              y = longer,
                              by = c("id" = "sample"))
  
  # If argument "taxa_colour" is provided, convert the taxa names
  # to factors so that the taxa names are ordered in the legend
  if (!is.null(taxa_colour)) {
    metadata_longer <- metadata_longer %>%
      mutate(taxon = factor(x = taxon, levels = names(taxa_colour)))
  }
  
  #################################################################
  # Return output
  #################################################################
  
  list(wider_taxonomy = input,
       longer_metadata_taxonomy = metadata_longer)
  
}

