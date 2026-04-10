############################################################
# Libraries used
############################################################

library(stats)
############################################################
# Libraries required for code/functions/custom_plot_alpha.R
# to work properly; must be loaded before other libraries
# to avoid conflicts
library(grid)
library(vctrs)
library(gtable)
library(plyr)
library(lazyeval)
library(ggforce)
############################################################
library(knitr)
library(rmarkdown)
library(bookdown)
library(tinytex)
library(kableExtra)
library(vegan)
library(RColorBrewer)
library(cowplot)
library(ggh4x)
library(legendry)
library(cld)
library(ggnewscale)
library(tidyverse)

#############################################################
# Custom functions used
############################################################

source("code/functions/r_package_version.R")
source("code/functions/format_labels.R")
source("code/functions/scaleFUN.R")
source("code/functions/custom_rrarefy.R")
source("code/functions/custom_breaks.R")
source("code/functions/custom_limits.R")
source("code/functions/facet_zoom_right.R")
source("code/functions/custom_plot_alpha.R")
source("code/functions/custom_clean_taxonomy.R")
source("code/functions/custom_structure_taxonomy.R")
source("code/functions/italicise_names.R")
source("code/functions/format_p_values.R")
source("code/functions/custom_cld.R")
source("code/functions/custom_bray.R")
source("code/functions/custom_round.R")
source("code/functions/custom_min_max.R")

############################################################
# Custom ggplot2 theme used
############################################################

source("data/raw/theme.R")

############################################################
# Options for knitr
############################################################

# Set working directory for R code chunks
# (https://bookdown.org/yihui/rmarkdown-cookbook/working-directory.html)
if (require("knitr")) {
    opts_knit$set(root.dir = getwd())
  }

# Avoid false positive error when using knitr::include_graphics()
# (knitr release 1.28, https://github.com/yihui/knitr/releases/tag/v1.28)
include_graphics = function(...) {
    knitr::include_graphics(..., error = FALSE)
  }

############################################################
# Permanently setting the CRAN repository
# (https://www.r-bloggers.com/permanently-setting-the-cran-repository/)
############################################################

local({
  r <- getOption("repos")
  r["CRAN"] <- "https://cran.wu.ac.at/"
  options(repos = r)
})

############################################################
# Option to keep the auxiliary TeX files when rendering
############################################################
options(tinytex.clean = FALSE)

