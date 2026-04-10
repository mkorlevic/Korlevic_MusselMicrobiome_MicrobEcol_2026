#################################################################################################################
# plot_alpha.R
#
# Script to plot richness estimators and diversity indices.
# Dependencies: results/numerical/alpha.Rdata
#               results/numerical/kruskal_wallis.Rdata
#               code/functions/custom_plot_alpha.R
#               code/functions/custom_cld.R
# Produces: results/figures/alpha.jpg
#
#################################################################################################################

# Load data of calculated richness estimators and diversity indices
load(file = "results/numerical/alpha.Rdata")

# Load statistical data
load(file = "results/numerical/kruskal_wallis.Rdata")

# Generate plots and display statistical results using custom functions:
# statistical results are shown using the Compact Letter Display (CLD)
s.obs <- custom_plot_alpha(input = alpha, filter_parameter = "S.obs",
                           cld = custom_cld(x = kruskal_wallis$
                                              kruskal_wallis_list$
                                              S.obs$pairwise_wilcox),
                           cld_y = 1750,
                           plot_title = "Observed Number of OTUs")
chao1 <- custom_plot_alpha(input = alpha, filter_parameter = "S.chao1",
                           cld = custom_cld(x = kruskal_wallis$
                                              kruskal_wallis_list$
                                              S.chao1$pairwise_wilcox),
                           cld_y = 7000,
                           plot_title = "Chao1")
ace <- custom_plot_alpha(input = alpha, filter_parameter = "S.ACE",
                         cld = custom_cld(x = kruskal_wallis$
                                            kruskal_wallis_list$
                                            S.ACE$pairwise_wilcox),
                         cld_y = 7000,
                         plot_title = "ACE")
eshannon <- custom_plot_alpha(input = alpha, filter_parameter = "eshannon",
                              cld = custom_cld(x = kruskal_wallis$
                                                 kruskal_wallis_list$
                                                 eshannon$pairwise_wilcox),
                              cld_y = 1325,
                              plot_title = "Exponential Shannon",
                              facet_zoom = TRUE,
                              facet_zoom_ylim = c(0, 250),
                              cld_zoom_y = 220, 
                              panel.spacing.x = 5.5 * 1.15)
invsimpson <- custom_plot_alpha(input = alpha, filter_parameter = "invsimpson",
                                cld = custom_cld(x = kruskal_wallis$
                                                   kruskal_wallis_list$
                                                   invsimpson$pairwise_wilcox),
                                cld_y = 885,
                                plot_title = "Inverse Simpson",
                                facet_zoom = TRUE,
                                facet_zoom_ylim = c(0, 80),
                                cld_zoom_y = 71,
                                panel.spacing.x = 5.5 * 1.35)

# Add and customise the x-axis of the plots located at the bottom of each
# column in the combined plot
ace <- ace +
  # Customise the x-axis guide using nested levels
  scale_x_discrete(guide = guide_axis_nested(levels_text = list(
    element_text(hjust = 1.0, vjust = -1.5, angle = 90,
                 margin = margin(t = 5.5 / 2.5, b = 5.5 / 2.5, unit = "pt")),
    element_text()))) +
  # Add x-axis text
  theme(axis.text.x = element_text())
invsimpson <- invsimpson +
  # Customise the x-axis guide using nested levels
  scale_x_discrete(guide = guide_axis_nested(levels_text = list(
    element_text(hjust = 1.0, vjust = -1.5, angle = 90,
                 margin = margin(t = 5.5 / 2.5, b = 5.5 / 2.5, unit = "pt")),
    element_text()))) +
  # Add x-axis text
  theme(axis.text.x = element_text())

# Modify plots with zoomed areas by removing duplicated CLDs
# in the main plot and by showing letters in the zoomed area
# only for plotted box and whiskers
for (i in c("eshannon", "invsimpson")) {
  
  # Convert the ggplot object to a list of data frames
  # that can be modified
  p <- ggplot_build(p = get(x = i))
  
  # Make duplicated CLDs in the main plot and letters
  # without a corresponding box and whisker in the
  # zoomed plot transparent
  p$data[[5]][c(1 : 5, 7, 10), "alpha"] <- 0
  
  # Build and store the grobs necessary for
  # displaying the plot in a grob table
  # (If the ggplot_gtable() function is not called within the graphics device
  # driver, an empty PDF file will be created in the project home directory
  # [https://stackoverflow.com/questions/17012518/why-does-this-r-ggplot2-code-bring-up-a-blank-display-device/17013882#17013882].)
  pdf(file = NULL)
  p <- ggplot_gtable(data = p)
  dev.off()
  
  # Assign the modified object to the
  # variable name
  assign(x = i, value = p)
  
}

# Combine plots
p <- plot_grid(s.obs, chao1, ncol = 2)
p <- plot_grid(p, eshannon, invsimpson, nrow = 3,
               rel_heights = c(0.330, 0.330, 0.425))
ace <- plot_grid(ace, NULL, NULL, ncol = 1, rel_heights = c(0.425, 0.330, 0.330))
p <- plot_grid(p, ace, ncol = 2, rel_widths = c(1.0, 0.5))

# Add axis titles and adjust margins for the combined plot
p <- p +
  draw_label(label = "Environment and Site", x = 0.533, y = 0.005,
             fontfamily = "Times", size = 14) +
  draw_label(label = "Number of OTUs", x = 0.005, y = 0.545,
             fontfamily = "Times", size = 14, angle = 90) +
  theme(plot.margin = margin(t = 5.5 * 3, r = 5.5 * 3,
                             b = 5.5 * 3, l = 5.5 * 3, unit = "pt"))

# Save
ggsave(filename = "results/figures/alpha.jpg", plot = p,
       width = 210 * 1.35, height = 210 * 1.35, units = "mm")

