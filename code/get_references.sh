#!/bin/bash

# Convert from RNA to DNA sequences
sed "/^[^>]/s/[Uu]/T/g" ${REFS}/silva.full.fasta > ${REFS}/silva.full_dna.fasta

# Screen the sequences
${MOTHUR} "#screen.seqs(fasta=${REFS}/silva.full_dna.fasta, start=${REFS_START_SCREEN}, end=${REFS_END_SCREEN}, maxambig=${REFS_MAXAMBIG}, processors=${NSLOTS})"

# Generate the alignment file
mv ${REFS}/silva.full_dna.good.fasta ${REFS}/silva.align

# Generate the taxonomy file
grep ">" ${REFS}/silva.align | cut -f 1,3 | cut -f 2 -d ">" > ${REFS}/silva.full

# Format the taxonomy files
wget ${SILVA_MAP_ADDRESS}
mv ${SILVA_MAP} tax_slv.txt.gz
gunzip tax_slv.txt.gz
mv tax_slv.txt ${REFS}/tax_slv.txt
R -e "source('code/format_taxonomy.R')"
mv ${REFS}/silva.full.tax ${REFS}/silva.tax

# Trim the database to the region of interest
${MOTHUR} "#pcr.seqs(fasta=${REFS}/silva.align, start=${REFS_START_SCREEN}, end=${REFS_END_SCREEN}, keepdots=F, processors=${NSLOTS}); unique.seqs()"

