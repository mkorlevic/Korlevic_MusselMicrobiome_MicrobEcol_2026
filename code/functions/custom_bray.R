#################################################################################################################
# custom_bray.R
#
# Function to customise the calculation of the Bray–Curtis dissimilarity coefficients.
# Dependencies: code/functions/format_labels.R
#               code/functions/custom_rrarefy.R
#
#################################################################################################################

custom_bray <- function(shared = NULL, metadata = NULL,
                        filter_environment = NULL, group_by = NULL) {
  
  # Ensure that the required arguments are provided
  if(is.null(shared) || is.null(metadata) || is.null(group_by)) {
    stop("'shared', 'metadata', and 'group_by' must be provided.")
  }
  
  #################################################################
  # Prepare the data
  #################################################################
  
  # Customise metadata using custom function
  metadata <- format_labels(x = metadata)
  
  # Join metadata with OTU/sample data
  shared_metadata <- shared %>%
    # Convert the "Group" column to character type
    mutate(Group = as.character(x = Group)) %>%
    # Join metadata with OTU/sample data
    left_join(y = metadata, by = c("Group" = "id"))
  
  # Filter samples from the environment specified by the argument
  # "filter_environment"
  if(!is.null(filter_environment)) {
    shared_metadata <- shared_metadata %>%
      # Filter samples from the specified environment
      filter(environment == {{ filter_environment }}) %>%
      # Remove columns that contain only NAs
      select(where(fn = ~ all(!is.na(.x)))) %>%
      # Remove abundance columns that contain only 0
      select(!starts_with(match = "Otu"),
             starts_with(match = "Otu") & where(fn = ~ any(.x != 0)))
  }
  
  # Store filtered data into a separate object
  shared_metadata_filtered <- shared_metadata
  
  # Sum sequences from groups defined by the argument "group_by"
  shared_metadata <- shared_metadata %>%
    group_by(across(.cols = {{ group_by }})) %>%
    summarise(across(.cols = starts_with(match = "Otu"), .fns = sum),
              .groups = "drop")
  
  # Create new sample IDs if argument "group_by" contains more than one item
  if(length(x = group_by) > 1) {
    shared_metadata <- shared_metadata %>%
      unite(col = Group, {{ group_by }}[1], {{ group_by }}[2], sep = "_")
  # Otherwise rename the column containing sample IDs to "Group"
  } else {
    shared_metadata <- shared_metadata %>%
      rename(Group = {{ group_by }})
  }
  
  # If argument "group_by" is equal to "c('environment', 'site')", convert the
  # "Group" column to a factor and order the rows according to the factors
  if(identical(x = group_by, y = c("environment", "site"))) {
    shared_metadata <- shared_metadata %>%
      mutate(Group = factor(x = Group, levels = c("Seawater_Aquaculture",
                                                  "Sediment_Aquaculture",
                                                  "Gills_Aquaculture",
                                                  "Seawater_Control",
                                                  "Sediment_Control"))) %>%
      arrange(Group)
  }
  
  # Create the randomly rarefied community data using the custom function
  shared_metadata <- custom_rrarefy(shared = shared_metadata)
  
  # Add sample IDs to row names (input for library vegan)
  shared_metadata <- shared_metadata %>%
    column_to_rownames(var = "id")
  
  #################################################################
  # Calculate the Bray–Curtis dissimilarity
  #################################################################
  
  # Calculate the Bray–Curtis dissimilarity
  bray <- shared_metadata %>%
    vegdist(method = "bray", binary = FALSE)
  
  # Convert the dissimilarity matrix to a matrix format
  bray <- as.matrix(bray)
  
  # Set the upper triangle of the matrix (including the diagonal) to NA
  bray[upper.tri(bray, diag = TRUE)] <- NA
  
  # Convert the dissimilarities from a matrix to a tibble
  bray <- bray %>%
    # Convert the matrix to a tibble
    as_tibble(.name_repair = "check_unique", rownames = NA) %>%
    # Add sample IDs from row names to a column
    rownames_to_column(var = "rows") %>%
    # Transform the data into a tidy long format and remove rows
    # that contain only NAs in the values_to column
    pivot_longer(cols = -rows, names_to = "columns", values_to = "bray",
                 values_drop_na = TRUE)
  
  # Split the column "rows" into two columns if argument "group_by"
  # contains two items
  if(length(x = group_by) == 2) {
    bray <- bray %>%
      # Split the column "rows" into two columns
      separate_wider_delim(col = rows, delim = "_",
                           names = c("rows_inside", "rows_outside")) %>%
      # Split the column "columns" into two columns
      separate_wider_delim(col = columns, delim = "_",
                           names = c("columns_inside", "columns_outside"))
  }
  
  # If argument "group_by" is equal to "c('environment', 'site')",
  # convert the sample names to factors and arrange the names
  if(identical(x = group_by, y = c("environment", "site"))) {
    bray <- bray %>%
      # Convert the column "columns_inside" to factors
      mutate(columns_inside = factor(x = columns_inside,
                                     levels = c("Seawater",
                                                "Sediment",
                                                "Gills"))) %>%
      # Convert the column "columns_outside" to factors
      mutate(columns_outside = factor(x = columns_outside,
                                      levels = c("Aquaculture",
                                                 "Control"))) %>%
      # Convert the column "rows_inside" to factors
      mutate(rows_inside = factor(x = rows_inside,
                                  levels = c("Gills",
                                             "Sediment",
                                             "Seawater"))) %>%
      # Convert the column "rows_outside" to factors
      mutate(rows_outside = factor(x = rows_outside,
                                   levels = c("Control",
                                              "Aquaculture")))
  }
  
  # If argument "group_by" is equal to "c('month', 'year')",
  # convert the sample names to factors and arrange the names
  if(identical(x = group_by, y = c("month", "year"))) {
    bray <- bray %>%
      # Convert the column "columns_inside" to factors
      mutate(columns_inside = factor(x = columns_inside,
                                     levels = c("July",
                                                "September",
                                                "November",
                                                "January",
                                                "March",
                                                "May"))) %>%
      # Convert the column "columns_outside" to factors
      mutate(columns_outside = factor(x = columns_outside,
                                      levels = c("2020",
                                                 "2021"))) %>%
      # Convert the column "rows_inside" to factors
      mutate(rows_inside = factor(x = rows_inside,
                                  levels = c("May",
                                             "March",
                                             "January",
                                             "November",
                                             "September",
                                             "July"))) %>%
      # Convert the column "rows_outside" to factors
      mutate(rows_outside = factor(x = rows_outside,
                                   levels = c("2021",
                                              "2020")))
  }
  
  #################################################################
  # Prepare and return the outputs
  #################################################################
  
  # Select the OTU abundance data from the filtered data and
  # create the randomly rarefied community data
  shared_metadata_filtered <- shared_metadata_filtered %>%
    # Select the columns containing sample IDs and OTU abundance data
    select(Group, starts_with(match = "Otu")) %>%
    # Create the randomly rarefied community data using the custom function
    custom_rrarefy() %>%
    # Join the rarefied OTU/sample data with metadata
    left_join(y = metadata, by = c("id" = "id")) %>%
    # Select the column containing sample IDs, the columns defined by the
    # argument "group_by", and the columns containing OTU abundance data
    select(id, {{group_by}}, starts_with(match = "Otu"))
  
  # Convert the summed data to a tibble
  shared_metadata <- shared_metadata %>%
    # Convert to tibble
    as_tibble(.name_repair = "check_unique", rownames = NA) %>%
    # Add sample IDs from row names to a column
    rownames_to_column(var = "id")
  
  # Combine the outputs into a list
  bray <- list(rarefied_data = shared_metadata_filtered,
               summed_data = shared_metadata,
               bray_value = bray)
  
  # Return the output
  return(bray)
  
}

