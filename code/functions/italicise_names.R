#################################################################################################################
# italicise_names.R
#
# Function to custom format taxa names, allowing options for italicised Latin names and other formatting styles
# as needed.
#
#################################################################################################################

italicise_names <- function(input = NULL) {
  
  # Ensure that the required arguments are provided
  if(is.null(input)) {
    stop("'input' must be provided.")
  }
  
  # Determine the correct formatting for specific taxa names
  formatted_names <- case_when(
    input == "Crocinitomicaceae_unclassified"   ~ "italic('Crocinitomicaceae')~plain('(NR)')",
    input == "Chloroplast"                      ~ paste0("plain(\"", input,  "\")"),
    input == "Marinimicrobia_(SAR406_clade)"    ~ "italic('Marinimicrobia')",
    input == "NB1-j"                            ~ "plain('NB1-j')",
    input == "Paracoccaceae_unclassified"       ~ "italic('Paracoccaceae')~plain('(NR)')",
    input == "Alphaproteobacteria_unclassified" ~ "italic('Alphaproteobacteria')~plain('(NR)')",
    input == "Vibrionaceae_unclassified"        ~ "italic('Vibrionaceae')~plain('(NR)')",
    input == "Candidatus_Endoecteinascidia"     ~ "plain('\"')*italic('Candidatus')~plain('Endoecteinascidia\"')",
    input == "Endozoicomonadaceae_unclassified" ~ "italic('Endozoicomonadaceae')~plain('(NR)')",
    input == "BD1-7_clade"                      ~ "plain('BD1-7 Clade')",
    input == "Pseudomonadota_unclassified"      ~ "italic('Pseudomonadota')~plain('(NR)')",
    input == "Bacteria_unclassified"            ~ "italic('Bacteria')~plain('(NR)')",
    input == "Other"                            ~ paste0("plain(\"", input, "\")"),
    input == "No_Relative"                      ~ "plain('No Relative')",
    TRUE                                        ~ paste0("italic(\"", input, "\")")
  )
  
  # Parse the formatted names into an R expression and return it
  return(parse(text = formatted_names))
  
}

