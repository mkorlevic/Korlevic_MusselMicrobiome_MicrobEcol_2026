## Resident and transient microbial taxa in the gill microbiome of the mussel *Mytilus galloprovincialis*
This is the repository for the manuscript "Resident and transient microbial taxa in the gill microbiome of the mussel *Mytilus galloprovincialis*" written by Marino Korlević, Marsej Markovski, Damir Kapetanović, Irena Vardić Smrzlić, Karla Orlić, Jakša Bolotin, Valter Kožul, Svjetlana Bobanović-Ćolić, Vedrana Nerlović, and Lorena Perić. The raw sequencing data with the exception of negative controls have been deposited in the European Nucleotide Archive (ENA) at EMBL-EBI under the accession number [PRJEB107277](https://www.ebi.ac.uk/ena/browser/view/PRJEB107277). Negative control samples are part of this repository and are located in data/raw/. To be able to reproduce the results the mothur compatible SILVA reference file (release 138.2, available under a [CC-BY license](https://www.arb-silva.de/silva-license-information/)) must be created according to instruction given on the [mothur's blog](https://mothur.org/blog/2024/SILVA-v138_2-reference-files/) and in the Makefile. This README file contains an overview of the repository structure, information on software dependencies, and instructions how to reproduce and rerun the analysis.

### Overview

	project
	|- README                            # the top level description of content (this document)
	|- LICENSE                           # the license for this project
	|
	|- submission/                       # files necessary for manuscript or supplementary information rendering, e.g. executable R Markdown
	| |- preamble.tex                    # LaTeX in_header file used to format the PDF version of both the manuscript and supplementary information
	| |- manuscript.Rmd                  # executable R Markdown for the manuscript of this study
	| |- manuscript.tex                  # TeX version of the manuscript.Rmd file
	| |- manuscript.pdf                  # PDF version of the manuscript.Rmd file
	| |- manuscript.aux                  # auxiliary file of the manuscript.tex file, used for cross-referencing
	| |- before_body_manuscript.tex      # LaTeX before_body file used to format the PDF version of the manuscript
	| |- supplementary.Rmd               # executable R Markdown for the supplementary information of this study
	| |- supplementary.tex               # TeX version of the supplementary.Rmd file
	| |- supplementary.pdf               # PDF version of the supplementary.Rmd file
	| |- supplementary.aux               # auxiliary file of the supplementary.tex file, used for cross-referencing
	| |- before_body_supplementary.tex   # LaTeX before_body file to format the PDF version of supplementary information
	| |- packages.bib                    # BibTeX formatted references of used packages
	| |- references.bib                  # BibTeX formatted references
	| +- citation_style.csl              # CSL file used to format references
	|
	|- data/                             # raw, reference, and primary data, are not changed once created
	| |- references/                     # reference files used in the analysis
	| |- raw/                            # raw data, not altered in the analysis
	| +- mothur/                         # mothur processed data
	|
	|- code/                             # any programmatic code
	| +- functions/                      # custom functions
	|
	|- results/                          # all output from workflows and analyses
	| |- figures/                        # manuscript or supplementary information figures
	| +- numerical/                      # results of the statistics or other numerical results for manuscript or supplementary information
	|
	|- .gitignore                        # gitignore file for this study
	|- .Rprofile                         # Rprofile file containing instructions on which R libraries to load, information on functions,
	|                                    # rendering options for knitr and rmarkdown, etc.
	+- Makefile                          # executable Makefile for this study

### How to regenerate this repository

#### Dependencies
* GNU Bash (v. 5.2.21(1)), should be located in user's PATH
* GNU Make (v. 4.3), should be located in user's PATH
* mothur (v. 1.48.2)
* R (v. 4.5.3), should be located in user's PATH
* R packages:
  * `stats (v. 4.5.3)`
  * `grid (v. 4.5.3)`
  * `vctrs (v. 0.6.5)`
  * `gtable (v. 0.3.6)`
  * `plyr (v. 1.8.9)`
  * `lazyeval (v. 0.2.2)`
  * `ggforce (v. 0.4.2)`
  * `knitr (v. 1.50)`
  * `rmarkdown (v. 2.29)`
  * `bookdown (v. 0.45)`
  * `tinytex (v. 0.59)`
  * `kableExtra (v. 1.4.0)`
  * `vegan (v. 2.6-10)`
  * `RColorBrewer (v. 1.1-3)`
  * `cowplot (v. 1.1.3)`
  * `ggh4x (v. 0.3.0)`
  * `legendry (v. 0.2.4)`
  * `cld (v. 0.0.1)`
  * `ggnewscale (v. 0.5.2)`
  * `tidyverse (v. 2.0.0)`

#### Running analysis
Before running the analysis be sure to generate the mothur compatible SILVA reference file and indicate in the Makefile its location. The manuscript and supplementary information can be generated on a Linux computer by running the following commands:
```
git clone https://github.com/MicrobesRovinj/Korlevic_MusselMicrobiome_MicrobEcol_2026.git
cd Korlevic_MusselMicrobiome_MicrobEcol_2026/
make all
```
If something goes wrong and the analysis needs to be restarted run the following command from the project home directory before rerunning the analysis:
```
make clean
```

