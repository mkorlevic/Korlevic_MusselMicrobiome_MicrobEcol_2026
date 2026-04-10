desired_levels <- c("domain", "phylum", "class", "order", "family", "genus")
desired_levels_tbl <- tibble(
  tax_level = factor(desired_levels, desired_levels))

# This is their reference taxonomy with levels for each substring found
# in the database
tax_label_level <- read_tsv("data/references/tax_slv.txt", col_names = FALSE, 
                            col_type = cols(.default = col_character())) %>%
  select(tax_label = X1, tax_level = X3)


# This is the full taxonomy for each sequence in the database
database_tax_label <- read_tsv("data/references/silva.full",
                               col_names = c("id", "tax_label"),
                               col_type = cols(.default = col_character()))

# These are the unique tax_label values found in database_tax_label
unique_tax_labels <- database_tax_label %>%
  select(tax_label) %>%
  distinct() %>%
  left_join(tax_label_level, by = "tax_label") %>%
  select(tax_label)


# Now need to get each of the substrings found in unique_tax_labels and return
# the tax_level for each substring taxonomy
generate_substrings <- function(s) {
  words <- str_replace(s, ";$", "") |>
    str_split(";") |>
    unlist()
  
  substrings <- character(length(words))
  for(w in seq_along(words)){
    substrings[w] <- paste(paste(words[1:w], collapse = ";"), "", sep = ";")
  }
  substrings
}

# Replace missing levels with incertae sedis of the previous good name with
# the taxonomic level appended
fill_ss_tbl <- function(ss_tbl) {
  
  if(nrow(ss_tbl) != 6) {
    
    ss_tbl <- ss_tbl %>%
      right_join(desired_levels_tbl, by = "tax_level")
    
    nas <- which(is.na(ss_tbl$substring))
    previous_good_string <- ""
    
    for(n in nas){
      if(!str_detect(ss_tbl[n - 1, "substring"], "_insertae_sedis_")){
        previous_good_string <- n - 1
      }
      
      ss_tbl[n, "substring"] <- paste0(ss_tbl[previous_good_string, "substring"],
                                       "_insertae_sedis_",
                                       ss_tbl[n, "tax_level"])
    }
  }
  
  str_replace_all(paste(paste(ss_tbl$substring, collapse = ";"), "", sep = ";"),
                  " ",
                  "_")
}


clean_tax_labels_lookup <- unique_tax_labels %>%
  mutate(substring = map(tax_label, generate_substrings)) %>% # Generate substrs
  unnest(substring) %>%
  inner_join(tax_label_level, by = c("substring" = "tax_label")) %>%
  mutate(substring = str_replace(substring, "^.*?([^;]+);$", "\\1")) %>%
  filter(!str_detect(substring, "^Incertae Sedis$")) %>% 
  select(tax_label, substring, tax_level) %>%
  nest(data = -tax_label) %>%
  mutate(clean_tax_label = map_chr(data, ~fill_ss_tbl(.x))) %>%
  unnest(clean_tax_label) %>%
  select(-data)


left_join(database_tax_label, clean_tax_labels_lookup, by = "tax_label") %>%
  select(id, clean_tax_label) %>%
  write_tsv(file = "data/references/silva.full.tax", quote = "none", col_names = FALSE)

