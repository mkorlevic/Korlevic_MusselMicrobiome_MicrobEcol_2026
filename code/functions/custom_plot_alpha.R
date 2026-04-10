#################################################################################################################
# custom_plot_alpha.R
#
# Function to customise the plotting of richness estimators and diversity indices.
# Dependencies: data/raw/colour_environment.R
#               code/functions/facet_zoom_right.R
#               data/raw/theme.R
#
#################################################################################################################

custom_plot_alpha <- function(input = NULL, filter_parameter = NULL, cld = NULL,
                              cld_y = NULL,
                              plot_title = NULL, facet_zoom = FALSE,
                              facet_zoom_ylim = NULL, cld_zoom_y = NULL,
                              panel.spacing.x = NULL) {
  
  # Ensure that the required arguments are provided
  if(is.null(input) || is.null(filter_parameter) || is.null(cld) ||
     is.null(cld_y)) {
    stop("'input', 'filter_parameter', 'cld', and 'cld_y' must be provided.")
  }
  
  # Load plot customisation data
  source(file = "data/raw/colour_environment.R")
  
  # Function to set custom axis breaks when using the custom_plot_alpha()
  # function
  custom_alpha_breaks <- function(x) {
    unlist(case_when(max(x) > 10     & max(x) <= 20    ~ list(seq(0, 20, by = 5)),
                     max(x) > 20     & max(x) <= 40    ~ list(seq(0, 40, by = 10)),
                     max(x) > 40     & max(x) <= 60    ~ list(seq(0, 60, by = 10)),
                     max(x) > 60     & max(x) <= 80    ~ list(seq(0, 80, by = 20)),
                     max(x) > 80     & max(x) <= 100   ~ list(seq(0, 100, by = 25)),
                     max(x) > 100    & max(x) <= 200   ~ list(seq(0, 200, by = 50)),
                     max(x) > 200    & max(x) <= 250   ~ list(seq(0, 250, by = 50)),
                     max(x) > 250    & max(x) <= 600   ~ list(seq(0, 600, by = 100)),
                     max(x) > 600    & max(x) <= 1000  ~ list(seq(0, 1000, by = 200)),
#                    max(x) > 800    & max(x) <= 1000  ~ list(seq(0, 1000, by = 200)),
                     max(x) > 1000   & max(x) <= 1500  ~ list(seq(0, 1500, by = 250)),
                     max(x) > 1500   & max(x) <= 2000  ~ list(seq(0, 2000, by = 500)),
                     max(x) > 2000   & max(x) <= 2500  ~ list(seq(0, 2500, by = 500)),
                     max(x) > 2500   & max(x) <= 7000  ~ list(seq(0, 8000, by = 2000)),
                     max(x) > 7000   & max(x) <= 8000  ~ list(seq(0, 8000, by = 2000)),
                     max(x) > 8000   & max(x) <= 10000 ~ list(seq(0, 10000, by = 2000)),
                     max(x) > 10000  & max(x) <= 15000 ~ list(seq(0, 15000, by = 3000)),
                     max(x) > 15000  & max(x) <= 20000 ~ list(seq(0, 20000, by = 4000)),
                     max(x) > 20000  & max(x) <= 25000 ~ list(seq(0, 25000, by = 5000)),
                     max(x) > 25000  & max(x) <= 35000 ~ list(seq(0, 35000, by = 7000)),
                     max(x) > 35000  & max(x) <= 40000 ~ list(seq(0, 40000, by = 8000)),
                     max(x) > 40000  & max(x) <= 75000 ~ list(seq(0, 75000, by = 15000)),
                     max(x) > 75000                    ~ list(seq(0, 100000, by = 20000)),
                     TRUE                              ~ list(seq(0, 0, by = 0))))
  }
    
  # Function to set custom axis limits when using the custom_plot_alpha()
  # function
  custom_alpha_limits <- function(x) {
    case_when(max(x) > 10    & max(x) <= 20    ~ c(0, 20),
              max(x) > 20    & max(x) <= 40    ~ c(0, 40),
              max(x) > 40    & max(x) <= 60    ~ c(0, 60),
              max(x) > 60    & max(x) <= 80    ~ c(0, 80),
              max(x) > 80    & max(x) <= 100   ~ c(0, 100),
              max(x) > 100   & max(x) <= 200   ~ c(0, 200),
              max(x) > 200   & max(x) <= 250   ~ c(0, 250),
              max(x) > 250   & max(x) <= 600   ~ c(0, 600),
              max(x) > 600   & max(x) <= 1000  ~ c(0, 1000),
#             max(x) > 800   & max(x) <= 1000  ~ c(0, 1000),
              max(x) > 1000  & max(x) <= 1500  ~ c(0, 1500),
              max(x) > 1500  & max(x) <= 2000  ~ c(0, 2000),
              max(x) > 2000  & max(x) <= 2500  ~ c(0, 2500),
              max(x) > 2500  & max(x) <= 7000  ~ c(0, 8000),
              max(x) > 7000  & max(x) <= 8000  ~ c(0, 8000),
              max(x) > 8000  & max(x) <= 10000 ~ c(0, 10000),
              max(x) > 10000 & max(x) <= 15000 ~ c(0, 15000),
              max(x) > 15000 & max(x) <= 20000 ~ c(0, 20000),
              max(x) > 20000 & max(x) <= 25000 ~ c(0, 25000),
              max(x) > 25000 & max(x) <= 35000 ~ c(0, 35000),
              max(x) > 35000 & max(x) <= 40000 ~ c(0, 40000),
              max(x) > 40000 & max(x) <= 75000 ~ c(0, 75000),
              max(x) > 75000                   ~ c(0, 100000),
              TRUE                             ~ c(0, 0))
  }
    
  # Generate plot
  p <- input %>%
    # Filter samples to be plotted
    filter(parameter == filter_parameter) %>%
    # Initialise a ggplot object and define the aesthetic mappings
    ggplot(mapping = aes(x = interaction(environment, site), y = value, fill = environment)) +
    # Add a rectangle to emphasise the distinction between the control and
    # the aquaculture samples
    annotate(geom = "rect", xmin = 3.5, xmax = Inf, ymin = 0, ymax = Inf,
             colour = "gray50", fill = "transparent", linewidth = 0.8, linetype = "dashed") +
    # Add error bars and specify their width
    stat_boxplot(geom = "errorbar", width = 0.2) +
    # Create box and whiskers and specify the width of the box
    geom_boxplot(width = 0.5) +
    # Report statistical results using the Compact Letter Display (CLD)
    geom_text(data = cld, mapping = aes(x = group,
                                        y = cld_y,
                                        fill = NULL,
                                        label = cld),
              family = "Times",
              fontface = "bold",
              size = 4.5) +
    # Customise the continuous scale of the y-axis
    scale_y_continuous(breaks = custom_alpha_breaks,
                       limits = custom_alpha_limits,
                       expand = c(0, 0)) +
    # Specify the colour of the box fill
    scale_fill_manual(name = NULL,
                      values = colour_environment,
                      breaks = names(colour_environment)) +
    # Define axes titles and plot title
    labs(x = "", y = "",
         title = plot_title) +
    # Use general custom theme
    theme +
    # Add additional plot customisations
    theme(axis.text.x = element_blank(),
          legend.position = "none",
          plot.title = element_text(vjust = 5.0),
          plot.margin = margin(t = 5.5 * 4, r = 5.5, b = 5.5, l = 5.5,
                               unit = "pt"),
          strip.background = element_rect(fill = "gray80"))
  
  # If required zoom in on a subset of the data
  if(facet_zoom == TRUE) {
    p <- p +
      facet_zoom_right(ylim = facet_zoom_ylim, zoom.size = 1) +
      # Report again the statistical results using the
      # Compact Letter Display (CLD) so that they can be shown
      # also in the zoomed area
      geom_text(data = cld, mapping = aes(x = group,
                                          y = cld_zoom_y,
                                          fill = NULL,
                                          label = cld),
                family = "Times",
                fontface = "bold",
                size = 4.5) +
      # Set the distance between the main and the zoomed panel
      theme(panel.spacing.x = unit(x = panel.spacing.x, units = "pt"))
    
  }
  
  # Return output
  p
  
}

