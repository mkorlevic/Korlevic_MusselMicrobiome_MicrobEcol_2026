#################################################################################################################
# calculate_alpha.R
#
# Script to calculate richness estimators and diversity indices.
# Dependencies: data/mothur/raw.trim.contigs.good.unique.good.filter.unique.precluster.denovo.vsearch.pick.pick.opti_mcc.shared
#               code/functions/custom_rrarefy.R
#               data/raw/metadata.tsv
#               code/functions/format_labels.R
# Produces: results/numerical/rarefied.Rdata
#           results/numerical/alpha.Rdata
#
#################################################################################################################

# Load OTU/sample data
shared <- read_tsv(file = "data/mothur/raw.trim.contigs.good.unique.good.filter.unique.precluster.denovo.vsearch.pick.pick.opti_mcc.shared")

# Create the randomly rarefied community data using the custom function
rarefied <- custom_rrarefy(shared = shared)

# Save the rarefied OTU/sample data
save(rarefied, file = "results/numerical/rarefied.Rdata")

# Add sample IDs to row names (input for library vegan)
rarefied <- rarefied %>%
  column_to_rownames(var = "id")

# Calculate the observed number of OTUs and the estimators Chao1 and ACE
estimators <- rarefied %>%
  estimateR() %>%
  t() %>%
  as_tibble(.name_repair = "check_unique", rownames = NA) %>%
  rownames_to_column("Group")

# Calculate the diversity indices (Shannon entropy and inverse Simpson)
shannon <- rarefied %>%
  diversity(index = "shannon") %>%
  enframe(name = "Group", value = "shannon")
invsimpson <- rarefied %>%
  diversity(index = "invsimpson") %>%
  enframe(name = "Group", value = "invsimpson")

# Transform the Shannon entropy to the effective number of OTUs
# (http://www.loujost.com/Statistics%20and%20Physics/Diversity%20and%20Similarity/EffectiveNumberOfSpecies.htm)
eshannon <- mutate(shannon, shannon = exp(shannon)) %>%
  rename(eshannon = shannon)

# Load metadata
metadata <- read_tsv("data/raw/metadata.tsv")

# Customise metadata using custom function
metadata <- format_labels(x = metadata)

# Join metadata, the richness estimators, and the diversity indices
alpha <- inner_join(x = metadata, y = estimators, by = c("id" = "Group")) %>%
  inner_join(y = eshannon, by = c("id" = "Group")) %>%
  inner_join(y = invsimpson, by = c("id" = "Group"))

# Pivot longer the data
alpha <- alpha %>%
  pivot_longer(cols = c(S.obs, S.chao1, S.ACE, eshannon, invsimpson),
               names_to = "parameter", values_to = "value")

# Sort factor levels of the variable parameter
alpha <- alpha %>%
  mutate(parameter = factor(x = parameter, levels = c("S.obs",
                                                      "S.chao1",
                                                      "S.ACE",
                                                      "eshannon",
                                                      "invsimpson")))

# Save
save(alpha, file = "results/numerical/alpha.Rdata")

