#################################################################################################################
# plot_rarefaction.R
# 
# Script to plot the rarefaction curve of each sample.
# Dependencies: data/mothur/raw.trim.contigs.good.unique.good.filter.unique.precluster.denovo.vsearch.pick.pick.opti_mcc.groups.rarefaction
#               data/raw/metadata.tsv
#               code/functions/format_labels.R
#               data/raw/colour_month.R
#               data/raw/linetype_site.R
#               data/raw/colour_individual.R
#               code/functions/custom_breaks.R
#               code/functions/custom_limits.R
#               data/raw/theme.R
# Produces: results/figures/rarefaction_a.jpg
#           results/figures/rarefaction_b.jpg
#
#################################################################################################################

# Load input data and select values for plotting
rarefaction <- read_tsv(file = "data/mothur/raw.trim.contigs.good.unique.good.filter.unique.precluster.denovo.vsearch.pick.pick.opti_mcc.groups.rarefaction") %>%
  select(-matches("^lci-"), -matches("^hci-")) %>%
  pivot_longer(!numsampled, names_to = "sample", values_to = "sobs", values_drop_na = TRUE) %>%
  mutate(sample = str_replace_all(sample, pattern = "0.03-", replacement = ""))

# Load metadata
metadata <- read_tsv(file = "data/raw/metadata.tsv")

# Customise metadata using the custom function
metadata <- format_labels(x = metadata)

# Join metadata and input data
metadata_rarefaction <- inner_join(x = metadata, y = rarefaction,
                                   by = c("id" = "sample"))

# Load plot customisation data
source(file = "data/raw/colour_month.R")
source(file = "data/raw/linetype_site.R")
source(file = "data/raw/colour_individual.R")

#################################################################################################################
# Generate rarefaction plots for seawater and sediment samples
#################################################################################################################

# Generate plots
p <- metadata_rarefaction %>%
  # Filter samples to be plotted 
  filter(environment == "Seawater" | environment == "Sediment") %>%
  # Initialise a ggplot object and define the aesthetic mappings
  ggplot(aes(x = numsampled, y = sobs, group = id,
             colour = interaction(month, year, sep = " "),
             linetype = site)) +
  # Add lines and specify their width
  geom_line(linewidth = 1.0) +
  # Specify the colour of the lines
  scale_colour_manual(name = NULL,
                      values = colour_month,
                      breaks = names(colour_month)) +
  # Specify the type of the lines
  scale_linetype_manual(name = NULL,
                        values = linetype_site,
                        breaks = names(linetype_site)) +
  # Customise the continuous scale of the x-axis
  scale_x_continuous(breaks = custom_breaks,
                     limits = custom_limits,
                     expand = c(0, 0)) +
  # Customise the continuous scale of the y-axis
  scale_y_continuous(breaks = custom_breaks,
                     limits = custom_limits,
                     expand = c(0, 0)) +
  # Define axes titles and plot title
  labs(title = NULL,
       x = "Number of Sequences", y = "Number of OTUs") +
  # Create multiple plots arranged in a grid
  facet_grid2(rows = vars(environment), cols = vars(location),
              scales = "free", independent = "all", switch = "y") +
  # Use general custom theme
  theme +
  # Add additional plot customisations
  theme(axis.title.x = element_text(vjust = -2, margin = margin(b = 20, unit = "pt")),
        axis.title.y = element_text(vjust = -12),
        legend.key.width = unit(1.4, "cm"),
        panel.spacing = unit(x = 5.5 * 2, units =  "pt"),
        strip.switch.pad.grid = unit(x = 20, units = "pt"))

# Save
ggsave("results/figures/rarefaction_a.jpg",
       plot = p, width = 297, height = 210, units = "mm")

#################################################################################################################
# Generate rarefaction plots for gill samples
#################################################################################################################

# Generate plots
p <- metadata_rarefaction %>%
  # Filter samples to be plotted 
  filter(environment == "Gills") %>%
  # Initialise a ggplot object and define the aesthetic mappings
  ggplot(aes(x = numsampled, y = sobs,
             group = id, colour = individual_index)) +
  # Add lines and specify their width
  geom_line(linewidth = 1.0) +
  # Specify the colour of the lines
  scale_colour_manual(name = NULL,
                      values = colour_individual,
                      breaks = names(colour_individual)) +
  # Customise the continuous scale of the x-axis
  scale_x_continuous(breaks = custom_breaks,
                     limits = custom_limits,
                     expand = c(0, 0)) +
  # Customise the continuous scale of the y-axis
  scale_y_continuous(breaks = custom_breaks,
                     limits = custom_limits,
                     expand = c(0, 0)) +
  # Define axes titles and plot title
  labs(title = NULL,
       x = "Number of Sequences", y = "Number of OTUs") +
  # Create multiple plots with nested strips
  facet_nested(rows = vars(year, month), cols = vars(location),
               scales = "free", independent = "all", switch = "y",
               nest_line = element_line(linewidth = 0.5),
               resect = unit(x = 5.5, "pt")) +
  # Use general custom theme
  theme +
  # Add additional plot customisations
  theme(axis.title.x = element_text(vjust = -2, margin = margin(b = 20, unit = "pt")),
        axis.title.y = element_text(vjust = -20),
        legend.margin = margin(t = 5.5, r = 5.5, b = 0, l = 5.5 * 2, unit = "pt"),
        legend.key.width = unit(1.4, "cm"),
        panel.spacing = unit(x = 5.5 * 2, units =  "pt"),
        strip.text.y = element_text(size = 15),
        strip.switch.pad.grid = unit(x = 24, units = "pt"))

# Save
ggsave("results/figures/rarefaction_b.jpg",
       plot = p, width = 210, height = 297, units = "mm")

