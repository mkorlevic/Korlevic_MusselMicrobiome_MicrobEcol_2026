#################################################################################################################
# format_labels.R
#
# Function to format plot labels.
#
#################################################################################################################

format_labels <- function(x) {
  
  # Set the locale to British English with UTF-8 encoding
  Sys.setlocale(locale = "en_GB.utf8")
  x %>%
    # Convert the "date" column to date type
    mutate(date = as.Date(x = date, format = "%d.%m.%Y")) %>%
    # Extract the month from the "date" column and format it as a
    # full month name
    mutate(month = format(x = date, format = "%B")) %>%
    # Convert the "month" column to a factor
    mutate(month = factor(x = month, levels = unique(month))) %>%
    # Extract the year from the "date" column
    mutate(year = format(x = date, format = "%Y")) %>%
    # Convert the "year" column to a factor
    mutate(year = factor(x = year, levels = unique(year))) %>%
    # Format the "date" column
    mutate(date = format(x = date, format = "%d %B %Y")) %>%
    # Remove leading zeros from the day part of the "date" column
    mutate(date = str_replace(string = date,
                              pattern = "^0",
                              replacement = "")) %>%
    # Format the "environment" column values
    mutate(environment = case_when(
      environment == "seawater" ~ "Seawater",
      environment == "sediment" ~ "Sediment",
      environment == "gills"    ~ "Gills",
      TRUE                      ~ environment)) %>%
    # Convert the "environment" column to a factor
    mutate(environment = factor(x = environment,
                                levels = c("Seawater",
                                           "Sediment",
                                           "Gills"))) %>%
    # Format the "location" column values
    mutate(location = case_when(
      location == "lim_bay"       ~ "Lim Bay",
      location == "mali_ston_bay" ~ "Mali Ston Bay",
      TRUE                        ~ location)) %>%
    # Format the "site" column values
    mutate(site = case_when(
      site == "aquaculture" ~ "Aquaculture",
      site == "control"     ~ "Control",
      TRUE                  ~ site)) %>%
    # Extract the individual ID from the "label" column
    mutate(individual_id = if_else(environment == "Gills",
                                   true = str_extract(string = label,
                                                      pattern = "\\d+$"),
                                   false = NA)) %>%
    # Convert the "individual_id" column to a factor with sorted
    # levels
    mutate(individual_id = factor(x = individual_id,
                                  levels = sort(
                                    x = unique(
                                      x = as.numeric(
                                        x = individual_id))))) %>%
    # Group by "environment" and "date" to create an index for
    # individuals
    group_by(environment, date) %>%
    mutate(individual_index = if_else(condition = environment == "Gills",
                                      true = seq(1 : n()),
                                      false = NA)) %>%
    ungroup() %>%
    # Convert the "individual_index" column to a factor
    mutate(individual_index = factor(x = individual_index,
                                     levels = unique(individual_index)))
  
}

