#################################################################################################################
# plot_beta.R
#
# Script to plot Bray–Curtis dissimilarity coefficients into a matrix.
# Dependencies: data/mothur/raw.trim.contigs.good.unique.good.filter.unique.precluster.denovo.vsearch.pick.pick.opti_mcc.shared
#               data/raw/metadata.tsv
#               code/functions/custom_bray.R
#               code/functions/scaleFUN.R
#               data/raw/theme.R
# Produces: results/numerical/beta.Rdata
#           results/figures/beta.jpg
#
#################################################################################################################

# Load OTU/sample data
shared <- read_tsv(file = "data/mothur/raw.trim.contigs.good.unique.good.filter.unique.precluster.denovo.vsearch.pick.pick.opti_mcc.shared")

# Load metadata
metadata <- read_tsv(file = "data/raw/metadata.tsv")

# Calculate the Bray–Curtis dissimilarity coefficients using the custom function
bray_environment_site <- custom_bray(shared = shared,
                                     metadata = metadata,
                                     group_by = c("environment", "site"))
bray_gills_months <- custom_bray(shared = shared,
                                 metadata = metadata,
                                 filter_environment = "Gills",
                                 group_by = c("month","year"))

# Bind the calculated data
bray <- bind_rows(`Environments and Sites` =
                    bray_environment_site$bray_value,
                  `Gill Microbiome—Sampling Months` =
                    bray_gills_months$bray_value,
                  .id = "y_strip")

# Save the calculated data
save(bray, file = "results/numerical/beta.Rdata")

# Generate plots
p <- bray %>%
  # Initialise a ggplot object and define the aesthetic mappings
  ggplot(mapping = aes(x = interaction(columns_inside, columns_outside),
                       y = interaction(rows_inside, rows_outside),
                       fill = bray)) +
  # Create tiles and specify their look
  geom_tile(colour = "black", linewidth = 0.5) +
  # Add the values of the Bray–Curtis dissimilarity coefficient
  geom_text(mapping = aes(label = scaleFUN(x = bray)),
            family = "Times", fontface = "bold", size = 6.5) +
  # Customise the discrete scale of the x-axis
  scale_x_discrete(guide = ggh4x::guide_axis_nested()) +
  # Customise the discrete scale of the y-axis
  scale_y_discrete(guide = ggh4x::guide_axis_nested()) +
  # Specify the fill colours for the tiles
  scale_fill_gradientn(name = "Bray–Curtis\nDissimilarity",
                       breaks = seq(0, 1, by = 0.2),
                       limits = c(0, 1),
                       colours = rev(x = brewer.pal(n = 9, name = "YlOrBr"))) +
  # Define axes titles and plot title
  labs(title = NULL,
       x = "", y = "") +
  # Create multiple panels
  facet_wrap(facets = vars(y_strip), ncol = 2, scales = "free",
             strip.position = "top") +
  # Use general custom theme
  theme +
  # Add additional plot customisations
  theme(axis.text.y = element_text(hjust = 0.5, vjust = 0.5, angle = 90,
                                   margin = margin(r = 5.5 / 2.5,
                                                   l = 5.5 / 2.5,
                                                   unit = "pt")),
        axis.ticks.x = element_blank(),
        axis.ticks.y = element_blank(),
        axis.line = element_blank(),
        legend.margin = margin(b = 5.5 * 1.1,
                               r = 5.5 * 2.0,
                               l = 5.5 * -1.0, unit = "pt"),
        legend.key.height = unit(x = 5.5 * 5, unit = "pt"),
        legend.title = element_text(margin = margin(b = 5.5 * 2.0,
                                                    unit = "pt")))

# Save
ggsave(filename = "results/figures/beta.jpg", plot = p,
       width = 297, height = 210 / 1.4, units = "mm")

