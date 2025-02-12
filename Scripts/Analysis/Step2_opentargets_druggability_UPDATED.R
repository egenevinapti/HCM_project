library(dplyr)
library(tidyr)
library(stringr)
library(data.table)
library(stringdist)

# File paths
inpath <- "C:/Users/Ege Apti/Desktop/HCM_Project/Input/"
drug_data_path <- "C:/Users/Ege Apti/Desktop/HCM_Project/Input/Data/post_mantis_analysis/OpenTargets/"
outpath <- "C:/Users/Ege Apti/Desktop/HCM_Project/Output/"

# Load datasets
gene_list <- data.table::fread(paste0(inpath,'new_genes_above_0.7.csv'))
setnames(gene_list, 'Gene_Name', 'Gene')

ot_drugs <- data.table::fread(paste0(drug_data_path, 'OT_drug_interactions.csv'))
ot_warnings <- data.table::fread(paste0(drug_data_path,'drugwarnings.csv'))
ot_pharmgkb <- data.table::fread(paste0(drug_data_path, 'pharmacogenomics.csv'))
data.table::setnames(ot_pharmgkb, 'drugId', 'chemblIds')

# Prepare data for merging
ot_warnings$chemblIds <- gsub("\\['|'\\]|'", "", ot_warnings$chemblIds)
ot_warnings <- ot_warnings %>% separate_rows(chemblIds, sep = ",\\s*")

df <- merge(gene_list, ot_drugs, by='Gene', all.x=TRUE)
dt <- merge(df, ot_warnings, by='chemblIds', all.x=TRUE)
d <- merge(dt, ot_pharmgkb, by='chemblIds', all.x=TRUE, allow.cartesian=TRUE)

d <- d %>%
  group_by(Gene) %>%
  summarise(across(everything(), ~ paste(unique(.x), collapse = ", ")), .groups = 'drop')

d <- as.data.frame(d)
d <- filter(d, chemblIds != "")

# Generate druggability table BEFORE filtering
output <- select(d, Gene, chemblIds, name_drug)
output$name_drug <- trimws(tolower(output$name_drug))  # Normalize names
data.table::fwrite(output, paste0(outpath, 'Mantis_Genes_Druggability_table.csv'))

# Save results for interacting genes
gene_drugs_count <- unique(d$Gene)
gene_drugs_count_df <- data.frame(Genes = gene_drugs_count)
data.table::fwrite(gene_drugs_count_df, paste0(outpath, 'Mantis_genes_with_drugs.txt'))

# Load and analyze heart failure drugs
hf_drugs <- data.table::fread(paste0(drug_data_path,'Heart_Failure_known_drugs.tsv'))
hf_drugs_count <- filter(d, Gene %in% hf_drugs$symbol)
hf_drugs_count_prior <- unique(hf_drugs_count$Gene)
data.table::fwrite(data.frame(Gene = hf_drugs_count_prior), paste0(outpath, 'Genes_with_HF_drugs.txt'))

# Load and analyze HCM drugs
hcm_drugs <- data.table::fread(paste0(drug_data_path,'Familial_HCM_known_drugs.tsv'))
hcm_drugs_count <- filter(d, Gene %in% hcm_drugs$symbol)
hcm_drugs_count_prior <- unique(hcm_drugs_count$Gene)
data.table::fwrite(data.frame(Gene = hcm_drugs_count_prior), paste0(outpath, 'Genes_with_HCM_drugs.txt'))

# Identify cardiovascular drugs
patterns <- "\\bcardiac|artial|myocard|arrhyt|heart failure|heart|hypertroph|dilated|left ventric|right ventric|hypertension|blood pressure|diabetes|obesity\\b"
cvd_gene_drugs <- d %>%
  filter(grepl(patterns, tolower(terms_drug), ignore.case = TRUE))

gene_cvd_drugs_count_df <- data.frame(Gene = unique(cvd_gene_drugs$Gene))
gene_cvd_drugs_count_df$CVD_Drug_Interaction <- 'Yes'
data.table::fwrite(gene_cvd_drugs_count_df, paste0(outpath, 'Mantis_genes_with_CVD_drugs.txt'))
# 64 genes with CVD drugs

# Identify genes with ONLY non-CVD drugs - 27 genes that interact with only non-CVD drugs
noncvd_gene_drugs <- d %>%
  filter(!grepl(patterns, tolower(terms_drug), ignore.case = TRUE) & chemblIds != "")

gene_noncvd_drugs_count_df <- data.frame(Gene = unique(noncvd_gene_drugs$Gene))
gene_noncvd_drugs_count_df$NonCVD_Drug_Interaction <- 'Yes'
data.table::fwrite(gene_noncvd_drugs_count_df, paste0(outpath, 'Mantis_genes_with_NonCVD_drugs.txt'))

# Add a column identifying NonCVD drug genes
d$Interacts_with_nonCVD_drug_only <- ifelse(d$Gene %in% gene_noncvd_drugs_count_df$Gene, "Yes", "No")

# Extract and save unique drug names from non-CVD drugs
noncvd_expanded_output <- noncvd_gene_drugs %>%
  separate_rows(name_drug, sep = ", ") %>%
  select(name_drug) %>%
  distinct()
data.table::fwrite(noncvd_expanded_output, paste0(outpath, "noncvd_drug_names.csv"), col.names = FALSE)

# !! TODO here: copy paste noncvd_drug_names in to drugenrichr and download SIDER results
# https://maayanlab.cloud/DrugEnrichr/

# Process SIDER results
sider_results <- data.table::fread(paste0(outpath, 'SIDER_Side_Effects_table.txt'))
setnames(sider_results, 'Genes', 'Drugs')
sider_results$Drugs <- trimws(tolower(sider_results$Drugs))

unique_sider_drugs <- unique(unlist(strsplit(sider_results$Drugs, ";")))
unique_ot_drugs <- unique(output$name_drug)

missing_drugs <- unique_sider_drugs[!unique_sider_drugs %in% unique_ot_drugs]

drug_mapping <- data.frame(
  SIDER_Drug = missing_drugs,
  Closest_Match = sapply(missing_drugs, function(drug) {
    best_match <- unique_ot_drugs[which.min(stringdist::stringdist(drug, unique_ot_drugs, method = "jw"))]
    return(best_match)
  })
)

for (i in seq_len(nrow(drug_mapping))) {
  sider_results$Drugs <- gsub(
    paste0("\\b", drug_mapping$SIDER_Drug[i], "\\b"),
    drug_mapping$Closest_Match[i],
    sider_results$Drugs
  )
}

sider_results[, Drugs_list := strsplit(Drugs, ";")]

get_genes_for_drugs <- function(drugs) {
  gene_list <- unique(na.omit(output[output$name_drug %in% drugs, "Gene"]))
  if (length(gene_list) == 0) return(NA)
  paste(gene_list, collapse = ";")
}

sider_results[, Genes := sapply(Drugs_list, get_genes_for_drugs), by = .(Term)]

sider_results_out <- select(sider_results, Term, Overlap, `P-value`, `Adjusted P-value`, `Z-score`, `Combined Score`, Drugs, Genes)

sider_results_out[, Cardiovascular_side_effect := ifelse(grepl(patterns, Term, ignore.case = TRUE), "Yes", "No")]

setorder(sider_results_out, -Cardiovascular_side_effect, `Adjusted P-value`)

data.table::fwrite(sider_results_out, paste0(outpath, 'nonCVD_gene-drug_interactions_drugenrichr_SIDER.csv'))

# Summary printout
cat("Total prioritised genes:", nrow(gene_list), "\n")
cat("Genes interacting with any drug:", nrow(gene_drugs_count_df), "\n")
cat("Genes interacting with CVD drugs:", nrow(gene_cvd_drugs_count_df), "\n")
cat("Genes interacting only with non-CVD drugs:", nrow(gene_noncvd_drugs_count_df), "\n")

# Count of CVD-related SIDER terms
cvd_sider_terms <- sum(sider_results_out$Cardiovascular_side_effect == "Yes")
cat("Number of CVD-related SIDER terms:", cvd_sider_terms, "\n")


data.table::fwrite(gene_cvd_drugs_count_df, paste0(outpath, 'all_drug_interacting_genes.csv'))

