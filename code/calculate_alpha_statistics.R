#################################################################################################################
# calculate_alpha_statistics.R
#
# Script to calculate the Kruskal-Wallis H test and the pairwise Mann-Whitney U test for richness estimators
# and diversity indices.
# Dependencies: results/numerical/alpha.Rdata
#               code/functions/format_p_values.R
# Produces: results/numerical/kruskal_wallis.Rdata
#
#################################################################################################################

# Load data
load(file = "results/numerical/alpha.Rdata")

# Define object names for storing statistical results
kruskal_wallis_list <- list()
kruskal_wallis_tibble <- NULL

# Perform the Kruskal-Wallis H test and the pairwise Mann-Whitney U test
# for richness estimators and diversity indices
for (i in c("S.obs", "S.chao1", "S.ACE", "eshannon", "invsimpson")) {
  
  # Prepare data for testing
  data <- alpha %>%
    # Filter every richness estimator and diversity index
    filter(parameter == i) %>%
    # Define testing groups
    mutate(group = interaction(environment, site, sep = " (")) %>%
    # Enclose site names in parentheses
    mutate(group = str_replace(string = group,
                               pattern = "(.*)",
                               replacement = "\\1)")) %>%
    # Reorder factor levels for testing groups
    mutate(group = factor(x = group, levels = c("Seawater (Aquaculture)",
                                                "Sediment (Aquaculture)",
                                                "Gills (Aquaculture)",
                                                "Seawater (Control)",
                                                "Sediment (Control)")))
  
  # Perform the Kruskal-Wallis H test
  kruskal <- kruskal.test(formula = value ~ group,
                          data = data)
  
  # Perform the pairwise Mann-Whitney U test
  pairwise_wilcox <- pairwise.wilcox.test(
    x = data$value, g = data$group,
    p.adjust.method = "bonferroni")
  
  # Combine the statistical results of every richness estimator
  # and diversity index in a list
  kruskal_wallis_list[[i]] <- list(kruskal_wallis = kruskal,
                                   pairwise_wilcox = pairwise_wilcox)
  
  # Convert the results of the pairwise Mann-Whitney U test
  # to a tibble
  pairwise_wilcox_tibble <- pairwise_wilcox$p.value %>%
    # Convert the results to a tibble
    as_tibble(.name_repair = "check_unique", rownames = NA) %>%
    # Transfer the testing group names from row names to a column
    rownames_to_column("group")
  
  # Store the statistical results in a tibble
  test_data <- tribble(
    # Define the column names for the tibble
    ~ parameter, ~ kw_H, ~ kw_df, ~ kw_p, ~ pairwise_mw, ~ mw_p,
    # Add rows to the tibble with the Kruskal-Wallis H test results
    i, kruskal$statistic, kruskal$parameter, kruskal$p.value,
    # Add rows to the tibble with the pairwise Mann-Whitney U test results
    # for specific groups
    "Seawater (Aquaculture)–Sediment (Aquaculture)",
    filter(.data = pairwise_wilcox_tibble,
           group == "Sediment (Aquaculture)")$`Seawater (Aquaculture)`,
    i, kruskal$statistic, kruskal$parameter, kruskal$p.value,
    "Seawater (Aquaculture)–Gills (Aquaculture)",
    filter(.data = pairwise_wilcox_tibble,
           group == "Gills (Aquaculture)")$`Seawater (Aquaculture)`,
    i, kruskal$statistic, kruskal$parameter, kruskal$p.value,
    "Seawater (Aquaculture)–Seawater (Control)",
    filter(.data = pairwise_wilcox_tibble,
           group == "Seawater (Control)")$`Seawater (Aquaculture)`,
    i, kruskal$statistic, kruskal$parameter, kruskal$p.value,
    "Seawater (Aquaculture)–Sediment (Control)",
    filter(.data = pairwise_wilcox_tibble,
           group == "Sediment (Control)")$`Seawater (Aquaculture)`,
    i, kruskal$statistic, kruskal$parameter, kruskal$p.value,
    "Sediment (Aquaculture)–Gills (Aquaculture)",
    filter(.data = pairwise_wilcox_tibble,
           group == "Gills (Aquaculture)")$`Sediment (Aquaculture)`,
    i, kruskal$statistic, kruskal$parameter, kruskal$p.value,
    "Sediment (Aquaculture)–Seawater (Control)",
    filter(.data = pairwise_wilcox_tibble,
           group == "Seawater (Control)")$`Sediment (Aquaculture)`,
    i, kruskal$statistic, kruskal$parameter, kruskal$p.value,
    "Sediment (Aquaculture)–Sediment (Control)",
    filter(.data = pairwise_wilcox_tibble,
           group == "Sediment (Control)")$`Sediment (Aquaculture)`,
    i, kruskal$statistic, kruskal$parameter, kruskal$p.value,
    "Gills (Aquaculture)–Seawater (Control)",
    filter(.data = pairwise_wilcox_tibble,
           group == "Seawater (Control)")$`Gills (Aquaculture)`,
    i, kruskal$statistic, kruskal$parameter, kruskal$p.value,
    "Gills (Aquaculture)–Sediment (Control)",
    filter(.data = pairwise_wilcox_tibble,
           group == "Sediment (Control)")$`Gills (Aquaculture)`,
    i, kruskal$statistic, kruskal$parameter, kruskal$p.value,
    "Seawater (Control)–Sediment (Control)",
    filter(.data = pairwise_wilcox_tibble,
           group == "Sediment (Control)")$`Seawater (Control)`)
  
  # Create columns containing formatted p-values
  test_data <- test_data %>%
    mutate(kw_p_label = format_p_values(x = kw_p)) %>%
    mutate(mw_p_label = format_p_values(x = mw_p))
  
  # Combine the statistical results of every richness estimator
  # and diversity index in a tibble
  kruskal_wallis_tibble <- bind_rows(kruskal_wallis_tibble,
                                     test_data)
  
}

# Combine the statistical results stored in a tibble and
# a list
kruskal_wallis <- list(kruskal_wallis_tibble = kruskal_wallis_tibble,
                       kruskal_wallis_list = kruskal_wallis_list)

# Save
save(kruskal_wallis, file = "results/numerical/kruskal_wallis.Rdata")

