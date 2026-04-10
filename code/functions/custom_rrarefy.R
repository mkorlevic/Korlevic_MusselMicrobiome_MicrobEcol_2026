#################################################################################################################
# custom_rrarefy.R
#
# Function to create a randomly rarefied version of the community data.
#
#################################################################################################################

custom_rrarefy <- function(shared = shared) {
  
  # Prepare input data to generate a randomly rarefied version of the
  # community data
  shared <- shared %>%
    # Rename column Group to id
    rename(id = Group) %>%
    # Keep the column that contains sample IDs and remove abundance columns
    # that contain only 0
    select(id, starts_with(match = "Otu") & where(fn = ~ any(.x != 0))) %>%
    # Add sample IDs to row names (input for library vegan)
    column_to_rownames(var = "id")
  
  # Create a randomly rarefied version of the community data
  shared %>%
    # Apply vegan's function rrarefy() to generate a randomly rarefied
    # version of the community data
    rrarefy(., min(rowSums(.))) %>%
    # Convert output to tibble
    as_tibble(.name_repair = "check_unique", rownames = NA) %>%
    # Add sample IDs from row names to a column
    rownames_to_column(var = "id") %>%
    # Keep the column that contains sample IDs and remove abundance columns
    # that contain only 0
    select(id, starts_with(match = "Otu") & where(fn = ~ any(.x != 0)))
  
}
