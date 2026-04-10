#################################################################################################################
# plot_taxonomy.R
#
# Script to plot the relative contribution of the most abundant taxonomic groups.
# Dependencies: data/mothur/raw.trim.contigs.good.unique.good.filter.unique.precluster.denovo.vsearch.silva.wang.tax.summary
#               code/functions/custom_clean_taxonomy.R
#               data/raw/taxa_colour.tsv
#               data/raw/metadata.tsv
#               code/functions/format_labels.R
#               code/functions/custom_structure_taxonomy.R
#               code/functions/italicise_names.R
# Produces: results/figures/taxonomy_environments_sites.jpg
#           results/figures/taxonomy_seawater_sediment_phylum.jpg
#           results/figures/taxonomy_gills_phylum.jpg
#           results/figures/taxonomy_gills_genus.jpg
#
#################################################################################################################

# Load taxonomy data
taxonomy <- read_tsv(file = "data/mothur/raw.trim.contigs.good.unique.good.filter.unique.precluster.denovo.vsearch.silva.wang.tax.summary")

# Clean taxonomy data using the custom function
taxonomy <- custom_clean_taxonomy(input = taxonomy,
                                  control = c("PC1", "PC2", "NC1", "NC2"),
                                  remove_chloroplast = TRUE)

# Load colours for the taxa
colour <- read_tsv(file = "data/raw/taxa_colour.tsv") %>%
  select(-Taxlevel) %>%
  deframe()

# Load metadata
metadata <- read_tsv(file = "data/raw/metadata.tsv")

# Customise metadata using the custom function
metadata <- format_labels(x = metadata)

# Remove positive and negative controls from metadata
metadata <- metadata %>%
  filter(!(id %in% c("PC1", "PC2", "NC1", "NC2")))

#################################################################################################################
# Generate the taxonomy plot for each environment and site
#################################################################################################################

# Prepare taxonomy data for plotting using the custom function
environments_sites <- custom_structure_taxonomy(input = taxonomy,
                                                metadata = metadata,
                                                taxa_colour = colour,
                                                select_environment = NULL,
                                                select_taxlevel = 2,
                                                threshold = 3,
                                                include_chloroplast = FALSE,
                                                split_pseudomonadota = TRUE)

# Group the samples by "environment", "site", and
# "taxon" and summarise the data by calculating the
# mean and standard deviation
metadata_environments_sites <- environments_sites$longer_metadata_taxonomy %>%
  group_by(environment, site, taxon) %>%
  summarise(mean = mean(proportion),
            sd = sd(proportion),
            .groups = "drop")

# Generate plot
p <- metadata_environments_sites %>%
  # Initialise a ggplot object and define the aesthetic mappings
  ggplot(mapping = aes(x = interaction(environment, site),
                       y = mean,
                       fill = taxon)) +
  # Create stacked bar charts and specify their look
  geom_bar(stat = "identity", colour = "black", linewidth = 0.5) +
  # Customise the discrete scale of the x-axis
  scale_x_discrete(guide = ggh4x::guide_axis_nested()) +
  # Customise the continuous scale of the y-axis
  scale_y_continuous(breaks = seq(0, 100, by = 10),
                     expand = c(0, 0)) +
  # Specify the fill colours for the stacked bar charts
  scale_fill_manual(name = NULL,
                    labels = italicise_names(input = levels(
                      x = metadata_environments_sites$taxon)),
                    values = colour,
                    breaks = levels(x = metadata_environments_sites$taxon)) +
  # Define axes titles and plot title
  labs(title = NULL,
       x = "Environment and Site", y = "%") +
  # Use general custom theme
  theme +
  # Add additional plot customisations
  theme(axis.title.x = element_text(vjust = -2,
                                    margin = margin(b = 20, unit = "pt")),
        axis.text.x = element_text(hjust = 1.0, vjust = 0.5, angle = 90,
                                   margin = margin(t = 5.5 / 2.5,
                                                   b = 5.5 / 2.5,
                                                   unit = "pt")),
        legend.key.spacing.y = unit(x = 1.5, units = "pt"),
        plot.margin = margin(t = 5.5 * 3, r = 5.5 * 2,
                             b = 5.5 * 0, l = 5.5 * 3, unit = "pt"))

# Save
ggsave(filename = "results/figures/taxonomy_environments_sites.jpg",
       plot = p, width = 297 / 1.25, height = 210 / 1.25, units = "mm")

#################################################################################################################
# Generate taxonomy plots for seawater and sediment samples
#################################################################################################################

# Prepare taxonomy data for plotting using the custom function
seawater <- custom_structure_taxonomy(input = taxonomy,
                                      metadata = metadata,
                                      taxa_colour = colour,
                                      select_environment = "Seawater",
                                      select_taxlevel = 2,
                                      threshold = 3,
                                      include_chloroplast = FALSE,
                                      split_pseudomonadota = TRUE)
sediment <- custom_structure_taxonomy(input = taxonomy,
                                      metadata = metadata,
                                      taxa_colour = colour,
                                      select_environment = "Sediment",
                                      select_taxlevel = 2,
                                      threshold = 3,
                                      include_chloroplast = FALSE,
                                      split_pseudomonadota = TRUE)

# Bind the prepared taxonomy data
seawater_sediment <- bind_rows(seawater = seawater$longer_metadata_taxonomy,
                               sediment = sediment$longer_metadata_taxonomy,
                               .id = "strip_y")

# Generate plots
p <- seawater_sediment %>%
  # Create a complete dataset by filling in missing combinations of the
  # defined variables (NA is inserted for any missing values)
  complete(strip_y, nesting(month, year), location, site) %>%
  # Initialise a ggplot object and define the aesthetic mappings
  ggplot(mapping = aes(x = interaction(month, year), y = proportion)) +
  # Create stacked bar charts and specify their look
  geom_bar(mapping = aes(fill = taxon),
           data = ~subset(x = ., subset = strip_y == "seawater"),
           stat = "identity", colour = "black", linewidth = 0.5) +
  # Add "NA" labels for missing samples and specify their look
  geom_text(mapping = aes(y = 6,
                          label = if_else(condition = is.na(x = proportion),
                                          true = "NA",
                                          false = NA)),
            family = "Times",
            size = 4) +
  # Customise the discrete scale of the x-axis
  scale_x_discrete(guide = ggh4x::guide_axis_nested()) +
  # Customise the continuous scale of the y-axis
  scale_y_continuous(breaks = seq(0, 100, by = 10),
                     expand = c(0, 0)) +
  # Specify the fill colours for the stacked bar charts
  scale_fill_manual(name = NULL,
                    labels = italicise_names(
                      input = levels(
                        x = seawater_sediment$taxon)),
                    guide = guide_legend(order = 1),
                    values = colour,
                    breaks = levels(
                      x = seawater_sediment$taxon)) +
  # Add a new scale to the plot to create two separate
  # legends
  new_scale_fill() +
  # Create stacked bar charts and specify their look
  geom_bar(mapping = aes(fill = taxon),
           data = ~subset(x = ., subset = strip_y == "sediment"),
           stat = "identity", colour = "black", linewidth = 0.5) +
  # Specify the fill colours for the stacked bar charts
  scale_fill_manual(name = NULL,
                    labels = italicise_names(
                      input = levels(
                        x = seawater_sediment$taxon)),
                    guide = guide_legend(order = 2),
                    values = colour,
                    breaks = levels(
                      x = seawater_sediment$taxon)) +
  # Define axes titles and plot title
  labs(title = NULL,
       x = "Month and Year", y = "%") +
  # Create multiple plots with nested strips
  facet_nested(rows = vars(strip_y, site), cols = vars(location),
               scales = "fixed", axes = "all", remove_labels = "all",
               independent = "none", labeller = labeller(
                 strip_y = c(seawater = "Seawater", sediment = "Sediment")),
               switch = "y",
               nest_line = element_line(linewidth = 0.5),
               resect = unit(x = 5.5, "pt")) +
  # Use general custom theme
  theme +
  # Add additional plot customisations
  theme(axis.title.x = element_text(vjust = -2, margin = margin(b = 20, unit = "pt")),
        axis.title.y = element_text(vjust = -18),
        axis.text.x = element_text(hjust = 1.0, vjust = 0.5, angle = 90,
                                   margin = margin(t = 5.5 / 2.5, b = 5.5 / 2.5, unit = "pt")),
        # The line separating different layers of labels (nesting line) on the x-axes
        # cannot be removed from the panels together with the x-axis labels. To address
        # this, we store two versions of the plot: one with the transparent nesting line
        # and another with the nesting line in black. We then replace the transparent
        # nesting line in the original plot with the black one for the bottom two panels.
        ggh4x.axis.nestline.x = element_line(colour = "transparent"),
        legend.spacing.y = unit(x = 5.5 * 8.2, units = "pt"),
        legend.key.spacing.y = unit(x = 1.5, units = "pt"),
        panel.spacing.x = unit(x = 5.5 * 3, units =  "pt"),
        panel.spacing.y = unit(x = 5.5 * -7, units =  "pt"),
        strip.switch.pad.grid = unit(x = 20, units = "pt"))

# Generate plot with the nesting line on the x-axes coloured in black
p_axis <- p +
  theme(ggh4x.axis.nestline.x = element_line(colour = "black"))

# Build and store the grobs necessary for displaying the plots in a grob table
# (If the ggplot_gtable() function is not called within the graphics device
# driver, an empty PDF file will be created in the project home directory
# [https://stackoverflow.com/questions/17012518/why-does-this-r-ggplot2-code-bring-up-a-blank-display-device/17013882#17013882].)
pdf(file = NULL)
p_axis <- ggplot_gtable(data = ggplot_build(plot = p_axis))
p <- ggplot_gtable(data = ggplot_build(plot = p))
dev.off()

# Replace the axis grob containing the transparent nesting line with the one
# containing the nesting line coloured in black
p$grobs[[18]] <- p_axis$grobs[[18]]
p$grobs[[19]] <- p_axis$grobs[[19]]

# Save
ggsave(filename = "results/figures/taxonomy_seawater_sediment_phylum.jpg",
       plot = p, width = 210, height = 297, units = "mm")

#################################################################################################################
# Generate taxonomy plots for gill samples
#################################################################################################################

# Define threshold values for taxonomic levels and whether
# to split the Pseudomonadota
plots <- tibble(taxlevel = c(2, 6),
                taxlevel_name = c("phylum", "genus"),
                threshold = c(3, 10),
                split_pseudomonadota = c(TRUE, FALSE))

# Generate plots for different taxonomic levels in
# a for loop
for (i in seq(1 : nrow(plots))) {
  
  # Prepare taxonomy data for plotting using the custom function
  gills <- custom_structure_taxonomy(input = taxonomy,
                                     metadata = metadata,
                                     taxa_colour = colour,
                                     select_environment = "Gills",
                                     select_taxlevel = plots$taxlevel[i],
                                     threshold = plots$threshold[i],
                                     include_chloroplast = FALSE,
                                     split_pseudomonadota = plots$split_pseudomonadota[i])
  
  # Generate plot
  p <- gills$longer_metadata_taxonomy %>%
    # Create a complete dataset by filling in missing combinations of the
    # defined variables (NA is inserted for any missing values)
    complete(nesting(month, year), location, individual_index) %>%
    # Initialise a ggplot object and define the aesthetic mappings
    ggplot(mapping = aes(x = individual_index, y = proportion, fill = taxon)) +
    # Create stacked bar charts and specify their look
    geom_bar(stat = "identity", colour = "black", linewidth = 0.5) +
    # Add "NA" labels for missing samples and specify their look
    geom_text(mapping = aes(y = 6,
                            label = if_else(condition = is.na(x = proportion),
                                            true = "NA",
                                            false = NA)),
              family = "Times",
              size = 4) +
    # Customise the discrete scale of the x-axis
    scale_x_discrete() +
    # Customise the continuous scale of the y-axis
    scale_y_continuous(breaks = seq(0, 100, by = 10),
                       expand = c(0, 0)) +
    # Specify the fill colours for the stacked bar charts
    scale_fill_manual(name = NULL,
                      labels = italicise_names(
                        input = levels(
                          x = gills$longer_metadata_taxonomy$taxon)),
                      guide = guide_legend(order = 1),
                      values = colour,
                      breaks = levels(
                        x = gills$longer_metadata_taxonomy$taxon)) +
    # Define axes titles and plot title
    labs(title = NULL,
         x = "Individual Index", y = "%") +
    # Create multiple plots with nested strips
    facet_nested(rows = vars(year, month), cols = vars(location),
                 scales = "fixed", axes = "all", remove_labels = "all",
                 independent = "none", switch = "y",
                 nest_line = element_line(linewidth = 0.5),
                 resect = unit(x = 5.5 * 2, "pt")) +
    # Use general custom theme
    theme +
    # Add additional plot customisations
    theme(axis.title.x = element_text(vjust = -2, margin = margin(b = 20, unit = "pt")),
          axis.title.y = element_text(vjust = -24),
          legend.key.spacing.y = unit(x = 1.5, units = "pt"),
          panel.spacing = unit(x = 5.5 * 4, units =  "pt"),
          strip.text = element_text(size = 22),
          strip.switch.pad.grid = unit(x = 24, units = "pt"))
  
  # Add annotations to the legend while plotting genera
  if (plots$taxlevel[i] == 6) {
    p <- plot_grid(p, nrow = 1, ncol = 2, rel_widths = c(0.94, 0.06)) +
      # Draw a vertical line connecting all Gammaproteobacteria taxa
      draw_line(x = c(0.937, 0.937), y = c(0.10, 0.228), size = 0.4) +
      # Place the label "Gammaproteobacteria" near the vertical line
      draw_label(label = "Gammaproteobacteria", x = 0.955, y = 0.117,
                 hjust = 0, fontfamily = "Times", fontface = "italic",
                 size = 12, angle = 90)
  }
  
  # Save
  ggsave(filename = paste0("results/figures/taxonomy_gills_",
                           plots$taxlevel_name[i],
                           ".jpg"),
         plot = p, width = 210 * 1.33, height = 297 * 1.33, units = "mm")
  
}

