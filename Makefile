# Run all
.PHONY : all

all : README.md\
      results/figures/rarefaction_a.jpg\
      submission/manuscript.pdf\
      submission/supplementary.pdf

#########################################################################################
#
# Part 1: Prepare software for analysis 
#
# 	Before we start the analysis, we need to make some preparations, such as:
# check if essential commands/software are available, define variables, update
# the name of the repository/project directory, update the year, obtain mothur from
# the mothur GitHub repository, etc.
#
#########################################################################################

# Define essential commands/software required for the analysis
EXECUTABLES = bash make R

# Check if required commands/software are available
software_check := $(foreach exec, $(EXECUTABLES),\
                  $(if $(shell command -v $(exec)),\
                  "$(exec) present in PATH!",\
                   $(error "No $(exec) in PATH!")))

# Define variables for directories and the basic stem of mothur files
export PROJECT_DIR := $(shell basename $(PWD))
export MOTHUR := code/mothur/mothur
export FUN := code/functions
export RAW := data/raw
export MOTH := data/mothur
export REFS := data/references
BASIC_STEM := $(MOTH)/raw.trim.contigs.good.unique.good.filter.unique.precluster.denovo.vsearch
export FIGS := results/figures
export NUM := results/numerical
export FINAL := submission

# Update the name of the GitHub repository/project directory name in README.md and manuscipt.Rmd
OLD_DIR_README_GIT := $(shell sed -n 's/^git clone https:\/\/github.com\/MicrobesRovinj\/\(.*\).git/\1/p' README.md)
OLD_DIR_README_CD := $(shell sed -n 's/^cd \(.*\)\//\1/p' README.md)
OLD_DIR_MANUSCRIPT := $(shell sed -n 's/.*(<https:\/\/github.com\/MicrobesRovinj\/\([^>]*\)>).*/\1/p' $(FINAL)/manuscript.Rmd)

.PHONY : check_dir_name

check_dir_name :
ifneq ($(PROJECT_DIR), $(OLD_DIR_README_GIT))
	$(shell sed -i 's/\(^git clone https:\/\/github.com\/MicrobesRovinj\/\).*\(.git\)/\1$(PROJECT_DIR)\2/' README.md)
	@echo "GitHub repository name has been updated in README.md."
else
	@echo "GitHub repository name is the same as in README.md." 
endif

ifneq ($(PROJECT_DIR), $(OLD_DIR_README_CD))
	$(shell sed -i 's/\(^cd \).*\(\/\)/\1$(PROJECT_DIR)\2/' README.md)
	@echo "Project directory name has been updated in README.md"
else
	@echo "Project directory name is the same as in README.md." 
endif

ifneq ($(PROJECT_DIR), $(OLD_DIR_MANUSCRIPT))
	$(shell sed -i 's/\(.*(<https:\/\/github.com\/MicrobesRovinj\/\)[^>]*\(>).*\)/\1$(PROJECT_DIR)\2/' $(FINAL)/manuscript.Rmd)
	@echo "GitHub repository name has been updated in manuscript.Rmd."
else
	@echo "GitHub repository name is the same as in manuscript.Rmd." 
endif

# Update the year in LICENSE.md
OLD_YEAR := $(shell sed -n 's/^Copyright (c) \([^ ]*\) .*/\1/p' LICENSE.md)
NEW_YEAR := $(shell echo $(PROJECT_DIR) | sed 's/^.*_\([^_]*\)$$/\1/')

.PHONY : check_year

check_year :
ifneq ($(NEW_YEAR), $(OLD_YEAR))
	$(shell sed -i 's/\(^Copyright (c)\) [^ ]* \(.*\)/\1 $(NEW_YEAR) \2/' LICENSE.md)
	@echo "Year has been updated in LICENSE.md."
else
	@echo "Year is the same as in LICENSE.md." 
endif

# Obtain the Linux version of mothur from the mothur GitHub repository
$(MOTHUR) : 
	wget --no-check-certificate https://github.com/mothur/mothur/releases/download/v1.48.2/Mothur.Ubuntu_22.zip
	unzip Mothur.Ubuntu_22.zip
	mv mothur code/
	rm Mothur.Ubuntu_22.zip

# Update software and R package information in README.md 
README.md : code/write_software_version.R\
            code/write_package_information.R\
            .Rprofile\
            $(FUN)/r_package_version.R\
            check_dir_name\
            check_year\
            $(MOTHUR)
	R -e "source('code/write_software_version.R')"
	R -e "source('code/write_package_information.R')"

#########################################################################################
#
# Part 2: Create the reference files
#
# 	We will need several reference files to complete the analyses including the
# SILVA reference alignment and taxonomy. As we are analysing both Bacteria and
# Archaea we need to optimize the procedure described on the mothur blog
# (https://mothur.org/blog/2024/SILVA-v138_2-reference-files/).
#
#########################################################################################

# We want the latest greatest reference alignment and the SILVA reference
# alignment is the best reference alignment on the market. We will use the
# Release 138.2. The curation of the reference files to make them compatible with
# mothur is described at https://mothur.org/blog/2024/SILVA-v138_2-reference-files/.
# As we are using primers from the Earth Microbiome Project that are targeting
# both Bacteria and Archaea (http://www.earthmicrobiome.org/protocols-and-standards/16s/)
# we need to modify the procedure described at
# https://mothur.org/blog/2024/SILVA-v138_2-reference-files/
# as this approach is removing shorter archeal sequences.
#
# The SILVA Release 138.2 was downloaded from the SILVA web page
# (https://www.arb-silva.de/fileadmin/silva_databases/release_138_2/ARB_files/SILVA_138.2_SSURef_NR99_03_07_24_opt.arb.gz),
# opened in ARB, and exported to silva.full_v138_2.fasta file as described at
# https://mothur.org/blog/2024/SILVA-v138_2-reference-files/#getting-the-data-in-and-out-of-the-arb-database.
# A total of 446,875 sequences were exported.

# Define the number of slots available for the analysis
export NSLOTS = 14

# Define environmental variables for reference files curation
export REFS_START_SCREEN = 11895
export REFS_END_SCREEN = 25318
export REFS_MAXAMBIG = 5
# Define the SILVA taxa mapping file
export SILVA_MAP_ADDRESS = https://www.arb-silva.de/fileadmin/silva_databases/release_138_2/Exports/taxonomy/tax_slv_ssu_138.2.txt.gz
export SILVA_MAP = tax_slv_ssu_138.2.txt.gz

# Create the reference files
$(REFS)/silva.tax\
$(REFS)/silva.pcr.align\
$(REFS)/silva.pcr.unique.align &: code/get_references.sh\
                                  code/format_taxonomy.R\
                                  $(MOTHUR)\
                                  ~/references/silva.full_v138_2/silva.full_v138_2.fasta
	# Copy the silva.full_v138_2.fasta file
	cp ~/references/silva.full_v138_2/silva.full_v138_2.fasta $(REFS)/silva.full.fasta
	# Run the script
	bash code/get_references.sh

#########################################################################################
#
# Part 3: Run data through mothur and calculate the sequencing error
#
# 	Process fastq files through mothur and generate files that will be used in
# the overall analysis.
#
#########################################################################################

# Generate raw.files for mothur's function make.contigs()
$(RAW)/raw.files : $(RAW)/metadata.tsv
	awk -F '\t' 'NR==1 {\
		for (i=1; i<=NF; i++) {\
			f[$$i] = i\
		}\
	}\
	{ print $$(f["id"]) "\t" "$(RAW)/"$$(f["file_name_f"]) "\t" "$(RAW)/"$$(f["file_name_r"]) }' $(RAW)/metadata.tsv > $(RAW)/raw.files
	tail -n +2 $(RAW)/raw.files > $(RAW)/temp.raw.files && mv $(RAW)/temp.raw.files $(RAW)/raw.files

# Download project fastq.gz files from the European Nucleotide Archive (ENA)
$(RAW)/24025-*.fastq : $(RAW)/NC_*.fastq
	wget "https://www.ebi.ac.uk/ena/portal/api/filereport?accession=PRJEB107277&result=read_run&fields=study_accession,sample_accession,experiment_accession,run_accession,tax_id,scientific_name,fastq_ftp,submitted_ftp,sra_ftp&format=tsv&download=true&limit=0" -O $(RAW)/deposited_list.txt
	cut -f $$(head -1 $(RAW)/deposited_list.txt | tr "\t" "\n" | cat -n | grep "submitted_ftp" | cut -f 1) $(RAW)/deposited_list.txt > $(RAW)/fastq.gz.txt
	tail -n +2 $(RAW)/fastq.gz.txt | tr ";" "\n" > $(RAW)/fastq.gz_list.txt
	sed -e "s/^/ftp:\/\//" -i $(RAW)/fastq.gz_list.txt
	wget -i $(RAW)/fastq.gz_list.txt -P $(RAW)/
	gzip -d $(RAW)/*.gz

# The primer.oligos file containing the sequences of gene specific primers must be
# specified in data/raw/. Also, the atcc_v4.fasta file containing sequences of the
# mock community members must be added to data/references/.

# Define environmental variables for fastq files processing
export MAXAMBIG = 0
export MINLENGTH = 225
export MAXLENGTH = 275
export ALIGNREF = $(REFS)/silva.pcr.unique.align
export STARTSCREEN = 1968
export ENDSCREEN = 11550
export MAXHOMOP = 20
export CLASSIFYREF = $(REFS)/silva.pcr.align
export CLASSIFYTAX = $(REFS)/silva.tax
export CONTAMINENTS = Chloroplast-Mitochondria-unknown-Eukaryota
export REMOVEGROUPS = PC1-PC2-NC1-NC2
export MOCKGROUPS = PC1-PC2
export MOCKREF = $(REFS)/atcc_v4.fasta

# Run fastq files through mothur, generate the summary.txt file to check if
# all went alright throughout the analysis, and calculate the sequencing error
$(BASIC_STEM).silva.wang.tax.summary\
$(BASIC_STEM).pick.pick.opti_mcc.shared\
$(MOTH)/summary.txt\
$(BASIC_STEM).pick.pick.error.summary &: code/get_processed.batch\
                                         code/get_summary.batch\
                                         $(REFS)/silva.tax\
                                         $(REFS)/silva.pcr.align\
                                         $(REFS)/silva.pcr.unique.align\
                                         $(MOTHUR)\
                                         $(RAW)/primer.oligos\
                                         $(RAW)/raw.files\
                                         $(RAW)/NC_*.fastq\
                                         $(RAW)/24025-*.fastq\
                                         $(REFS)/atcc_v4.fasta
	$(MOTHUR) code/get_processed.batch
	rm $(MOTH)/*.map
	$(MOTHUR) code/get_summary.batch

#########################################################################################
#
# Part 4: Calculate parameters
#
# 	Perform the calculation of various parameters used in the creation of plots or
# in the rendering of the manuscript and/or supplementary information.
#
#########################################################################################

# Calculate the parameters of alpha diversity
$(NUM)/rarefied.Rdata\
$(NUM)/alpha.Rdata &: code/calculate_alpha.R\
                      $(BASIC_STEM).pick.pick.opti_mcc.shared\
                      $(FUN)/custom_rrarefy.R\
                      $(RAW)/metadata.tsv\
                      $(FUN)/format_labels.R
	R -e "source('code/calculate_alpha.R')"

# Calculate the statistics for alpha diversity parameters
$(NUM)/kruskal_wallis.Rdata : code/calculate_alpha_statistics.R\
                              $(NUM)/alpha.Rdata\
                              $(FUN)/format_p_values.R
	R -e "source('code/calculate_alpha_statistics.R')"

#########################################################################################
#
# Part 5: Generate figures and tables
#
# 	Run scripts to generate figures and tables.
#
#########################################################################################

# Construct the rarefaction plots
$(FIGS)/rarefaction_a.jpg\
$(FIGS)/rarefaction_b.jpg &: code/get_rarefaction.batch\
                             $(BASIC_STEM).pick.pick.opti_mcc.shared\
                             $(MOTHUR)\
                             code/plot_rarefaction.R\
                             $(RAW)/metadata.tsv\
                             $(FUN)/format_labels.R\
                             $(RAW)/colour_month.R\
                             $(RAW)/linetype_site.R\
                             $(RAW)/colour_individual.R\
			     $(FUN)/custom_breaks.R\
			     $(FUN)/custom_limits.R\
                             $(RAW)/theme.R
	$(MOTHUR) code/get_rarefaction.batch
	R -e "source('code/plot_rarefaction.R')"	

# Construct the alpha diversity plot
$(FIGS)/alpha.jpg : code/plot_alpha.R\
                    $(NUM)/alpha.Rdata\
                    $(NUM)/kruskal_wallis.Rdata\
                    $(FUN)/custom_plot_alpha.R\
                    $(RAW)/colour_environment.R\
                    $(FUN)/facet_zoom_right.R\
                    $(RAW)/theme.R\
                    $(FUN)/custom_cld.R
	R -e "source('code/plot_alpha.R')"

# Calculate the metrics of beta diversity and construct the beta diversity plot
$(NUM)/beta.Rdata\
$(FIGS)/beta.jpg &: code/plot_beta.R\
                    $(BASIC_STEM).pick.pick.opti_mcc.shared\
                    $(RAW)/metadata.tsv\
                    $(FUN)/custom_bray.R\
                    $(FUN)/format_labels.R\
                    $(FUN)/custom_rrarefy.R\
                    $(FUN)/scaleFUN.R\
                    $(RAW)/theme.R
	R -e "source('code/plot_beta.R')"

# Construct the taxonomy plots
$(FIGS)/taxonomy_environments_sites.jpg\
$(FIGS)/taxonomy_seawater_sediment_phylum.jpg\
$(FIGS)/taxonomy_gills_phylum.jpg\
$(FIGS)/taxonomy_gills_genus.jpg &: code/plot_taxonomy.R\
                                    $(BASIC_STEM).silva.wang.tax.summary\
                                    $(FUN)/custom_clean_taxonomy.R\
                                    $(RAW)/taxa_colour.tsv\
                                    $(RAW)/metadata.tsv\
                                    $(FUN)/format_labels.R\
                                    $(FUN)/custom_structure_taxonomy.R\
                                    $(FUN)/italicise_names.R
	R -e "source('code/plot_taxonomy.R')"

##########################################################################################
#
# Part 6: Combine everything together 
#
# 	Render the manuscript and the supplementary information.
#
#########################################################################################

$(FINAL)/manuscript.pdf\
$(FINAL)/supplementary.pdf &: $(FINAL)/manuscript.Rmd\
                              $(FINAL)/references.bib\
                              $(FINAL)/citation_style.csl\
                              $(FINAL)/preamble.tex\
                              $(FINAL)/before_body_manuscript.tex\
                              .Rprofile\
                              $(BASIC_STEM).pick.pick.opti_mcc.shared\
                              $(NUM)/rarefied.Rdata\
                              $(BASIC_STEM).pick.pick.error.summary\
                              $(BASIC_STEM).silva.wang.tax.summary\
                              $(RAW)/metadata.tsv\
                              $(NUM)/alpha.Rdata\
                              $(NUM)/kruskal_wallis.Rdata\
                              $(NUM)/beta.Rdata\
                              $(FIGS)/map.jpg\
                              $(MOTHUR)\
                              $(FUN)/format_p_values.R\
                              $(FIGS)/alpha.jpg\
                              $(FUN)/format_labels.R\
                              $(FUN)/custom_bray.R\
                              $(FUN)/custom_rrarefy.R\
                              $(FUN)/custom_round.R\
                              $(FIGS)/beta.jpg\
                              $(FIGS)/taxonomy_environments_sites.jpg\
                              $(FUN)/custom_clean_taxonomy.R\
                              $(FUN)/custom_structure_taxonomy.R\
                              $(FUN)/custom_min_max.R\
                              $(FIGS)/taxonomy_gills_genus.jpg\
                              $(FINAL)/supplementary.Rmd\
                              $(FINAL)/before_body_supplementary.tex\
                              $(FIGS)/rarefaction_a.jpg\
                              $(FIGS)/rarefaction_b.jpg\
                              $(FIGS)/taxonomy_seawater_sediment_phylum.jpg\
                              $(FIGS)/taxonomy_gills_phylum.jpg
	R -e 'render("$(FINAL)/manuscript.Rmd", clean = FALSE)'
	R -e 'render("$(FINAL)/supplementary.Rmd", clean = FALSE)'
	rm $(FINAL)/*.knit.md $(FINAL)/*.log

# Clean
.PHONY : clean

clean :
	find ./ -type f -name "mothur.*.logfile" -delete
	find code/ -type d -name "mothur" -exec rm -r {} +
	find $(MOTH)/ -type f -not -name "README.md" -delete
	find $(RAW)/ -type f -not -name "README.md"\
                             -not -name "theme.R"\
                             -not -name "metadata.tsv"\
                             -not -name "primer.oligos"\
                             -not -name "colour_environment.R"\
                             -not -name "colour_individual.R"\
                             -not -name "colour_month.R"\
                             -not -name "linetype_site.R"\
                             -not -name "NC_24025-0094_all_R1.fastq"\
                             -not -name "NC_24025-0094_all_R2.fastq"\
                             -not -name "NC_24025-0172_all_R1.fastq"\
                             -not -name "NC_24025-0172_all_R2.fastq"\
                             -not -name "taxa_colour.tsv"\
                             -delete
	find $(REFS)/ -type f -not -name "README.md"\
                              -not -name "atcc_v4.fasta"\
                              -delete
	find $(FIGS)/ -type f -not -name "README.md"\
                              -not -name "map.jpg"\
                              -delete
	find $(NUM)/ -type f -not -name "README.md" -delete
	find $(FINAL)/ -type f -not -name "README.md"\
                               -not -name "manuscript.Rmd"\
                               -not -name "manuscript.aux"\
                               -not -name "references.bib"\
                               -not -name "citation_style.csl"\
                               -not -name "preamble.tex"\
                               -not -name "before_body_manuscript.tex"\
                               -not -name "supplementary.Rmd"\
                               -not -name "supplementary.aux"\
                               -not -name "before_body_supplementary.tex"\
                               -delete 

