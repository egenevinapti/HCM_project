# -----------------------------------------------------------------------------------
# Description:
# This script processes Mantis-ML probability scores for gene classification related
# to Hypertrophic Cardiomyopathy (HCM). The steps include:
#
# 1. Reading input data:
#    - `mantis_scored`: Contains gene probability scores.
#    - `hcm_loci`: List of known HCM-associated genes from GWAS catalog.
#
# 2. Identifying top genes based on Mantis-ML probability thresholds (0.9, 0.8, 0.75, 0.7, 0.5).
#    - Creates separate lists for genes above each threshold.
#
# 3. Summarizing gene counts per threshold.
#
# 4. Generating a histogram of the Mantis-ML probability distribution.
#
# 5. Extracting genes above the 0.75 probability threshold as the primary gene list.
#
# 6. Comparing these genes with known HCM loci:
#    - Identifying overlap with known HCM loci.
#    - Saving novel high-probability genes (not in HCM loci).
#
# 7. Exporting results:
#    - `genes_above_0.75.csv`: List of genes above 0.75 threshold.
#    - `novel_high_prob_genes.csv`: List of high-probability genes not in known HCM loci.
#    - `threshold_counts.csv`: Summary of gene counts per threshold.
# -----------------------------------------------------------------------------------

library(dplyr)
library(ggplot2)
library(data.table)

input_path <- "\\HCM_Project\\Input"
input_path_2 <- "/HCM_Project/Input"
output_path <- "\\HCM_Project\\Output\\"

# Read in data
mantis_scored <- data.table::fread(paste0(input_path_2, "/AllClassifiers.Merged.mantis-ml_predictions.csv"))
hcm_loci <- data.table::fread(paste0(input_path, "\\GWAS_catalog_HCM_loci_genes.csv"))

# Clean hcm_loci by trimming white spaces and removing empty or NA rows
hcm_loci <- hcm_loci %>%
  mutate(across(everything(), ~ trimws(.))) %>%  # Trim whitespace
  filter(if_all(everything(), ~ . != "" & !is.na(.)))  # Remove empty or NA rows

# Define thresholds
thresholds <- c(0.9, 0.8, 0.75, 0.7, 0.5)

# Identify top genes by thresholds
top_genes <- lapply(thresholds, function(thresh) {
  mantis_scored %>% filter(mantis_ml_proba > thresh) %>% select(Gene_Name)
})
names(top_genes) <- paste0("new_top_genes_", thresholds)

# Create small table showing counts per threshold
threshold_counts <- tibble(
  Threshold = thresholds,
  Gene_Count = sapply(top_genes, nrow)
)

# Print/view result
print(threshold_counts)

# Save table
fwrite(threshold_counts, paste0(output_path, "threshold_counts.csv"))

# Histogram distribution of mantis ml probability
ggplot(mantis_scored, aes(x = mantis_ml_proba)) +
  geom_histogram(binwidth = 0.05, fill = "blue", alpha = 0.7, color = "black") +
  labs(title = "Histogram of Mantis ML Probability",
       x = "Mantis ML Probability",
       y = "Count") +
  theme_minimal()

# Take genes from 0.75 as gene list of interest
gene_list_0.75 <- top_genes[["new_top_genes_0.75"]]
gene_list_0.8 <- top_genes[["new_top_genes_0.8"]]

# Save results
fwrite(gene_list_0.8, paste0(output_path, "new_genes_above_0.8.csv"))
fwrite(gene_list_0.75, paste0(output_path, "new_genes_above_0.75.csv"))

mantis_scored_075_novel <- filter(mantis_scored, mantis_ml_proba > 0.75)
mantis_scored_075_novel <- filter(mantis_scored_075_novel, known_gene==0)

mantis_scored_075_known <- filter(mantis_scored, mantis_ml_proba > 0.75)
mantis_scored_075_known <- filter(mantis_scored_075_known, known_gene==1)

fwrite(mantis_scored_075_novel, paste0(output_path, "mantis_075_novel_genes.csv"))
fwrite(mantis_scored_075_known, paste0(output_path, "mantis_075_known_genes.csv"))


# Assuming mantis_scored is your data table and it has columns: mantis_ml_proba, known, Gene_Name

# Step 1: Filter by mantis_ml_proba > 0.75
mantis_scored_filtered <- mantis_scored[mantis_scored$mantis_ml_proba > 0.75]

# Step 2: Create a new column for 'Known genes' and 'Novel genes' based on 'known' column
mantis_scored_filtered$Known_genes_new_0.75 <- ifelse(mantis_scored_filtered$known == 1, mantis_scored_filtered$Gene_Name, NA)
mantis_scored_filtered$Novel_genes_new_0.75 <- ifelse(mantis_scored_filtered$known == 0, mantis_scored_filtered$Gene_Name, NA)

# Step 3: Optionally, you can clean up NA values if needed
# Replace NA in 'Known_genes' and 'Novel_genes' with empty strings (if you don't want NA values)
mantis_scored_filtered$Known_genes[is.na(mantis_scored_filtered$Known_genes)] <- ""
mantis_scored_filtered$Novel_genes[is.na(mantis_scored_filtered$Novel_genes)] <- ""

# Now mantis_scored_filtered has new columns: Known_genes and Novel_genes
head(mantis_scored_filtered)


# Old code (not needed)
# Identify how many are already known HCM loci
known_hcm_genes <- gene_list_0.8 %>% 
  filter(Gene_Name %in% hcm_loci$Gene)

# If there are known HCM genes, save the novel ones
if (nrow(known_hcm_genes) > 0) {
  novel_genes <- gene_list_0.8 %>% 
    filter(!Gene_Name %in% hcm_loci$Gene)
  
  # Save novel high-probability genes
 # fwrite(novel_genes, paste0(output_path, "new_novel_high_prob_genes.csv"))
}
