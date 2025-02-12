
#https://machinelearningmastery.com/nonparametric-statistical-significance-tests-in-python/
library(data.table)
library(dplyr)
library(tidyverse)
library(ggplot2)
library(magrittr)
library(circlize)
library(heatmaply)
library(reshape2)
library(RColorBrewer)
library(ComplexHeatmap)
library(circlize)
#library(easyGgplot2)
library(ggpubr)
library(stats)
library(splitstackshape)
library(GeneOverlap)


gene_list <- fread('/home/hnicholls/HCM_druggability/Input/Data/genes_above_0.8.csv')
setnames(gene_list, 'Gene_Name', 'Gene')

mouse <- fread('/home/hnicholls/HCM_druggability/Input/Data/IMPC_phenotypeHitsPerGene-v20_1.csv')

cardiac_mouse <- mouse  %>%
  filter(str_detect(`Phenotype Hits`, 'cardio|cardiac|vessel|vasculature|vascular|heart|adrenal|kidney|ventricular|atrial|cholesterol|
                    thyroid|interval|QRS|segment|aorta|dilation|obes|obesity|body mass|sarcopenia|sarcopenic|muscle|skeletal muscle'))
cardiac_mouse$Gene = toupper(cardiac_mouse$Gene)


mouse$Gene = toupper(mouse$`Gene Symbol`)

mouse_test <- merge(mouse, gene_list, by="Gene", all.y=T)
natest1 <- filter(mouse_test , !is.na(`Phenotype Hits`))

df <- Reduce(function(x, y) merge(x, y, all.x = TRUE),
             list(gene_list, mouse))

df <- df[!duplicated(df$Gene), ]        

mouse_pops <- select(df, Gene, `# Phenotype Hits`, `Phenotype Hits`)
pheno_mouse_count <- filter(mouse_pops, !is.na(mouse_pops$`Phenotype Hits`))


#cardio only phenotypes:
df <- Reduce(function(x, y) merge(x, y, all.x = TRUE),
             list(gene_list, cardiac_mouse))

df <- df[!duplicated(df$Gene), ]        

mouse_pops <- select(df, Gene, `# Phenotype Hits`, `Phenotype Hits`)
cardiac_mouse_count <- filter(mouse_pops, !is.na(mouse_pops$`Phenotype Hits`))

new_mouse <- cSplit(mouse, "Phenotype Hits", sep = "::", direction = "long")
new_mouse_pops <- cSplit(mouse_pops, "Phenotype Hits", sep = "::", direction = "long")
colnames(new_mouse_pops)[2] <- 'gene_group_size'
colnames(new_mouse)[3] <- 'dataset_size'

new_mouse <- subset(new_mouse, `Phenotype Hits` %in% new_mouse_pops$`Phenotype Hits`)

d1_splitpops <- split(new_mouse_pops, new_mouse_pops$`Phenotype Hits`)
d2_split <- split(new_mouse, new_mouse$`Phenotype Hits`)

# this should be TRUE in order for Map to work correctly
all(names(d1_splitpops) == names(d2_split))

tests <- Map(function(d1, d2) {
  go.obj <- newGeneOverlap(d1$Gene, d2$Gene, genome.size = 20000)
  return(testGeneOverlap(go.obj))
}, d1_splitpops, d2_split)


results <- tibble(pheno = names(tests), tests = tests) %>% 
  rowwise() %>% 
  mutate(
    across(tests, 
           .fns = list(tested = getTested, pval = getPval), 
           .names = '{.fn}')
  ) %>% 
  select(-tests)

results$pval_adjusted <- p.adjust(results$pval, "fdr")

colnames(results)[1] <- 'Phenotype'
fwrite(results, '/home/hnicholls/HCM_druggability/Output/IMPC_genes_ranked_enriched.csv')

mouse_df <- select(df, Gene, `# Phenotype Hits`, `Phenotype Hits`)
mouse_count <- filter(mouse_df, `# Phenotype Hits` > 0)

mouse_count2 <- cSplit(mouse_count, "Phenotype Hits", sep = "::", direction = "long")

mouse_count2 <- select(mouse_count2, `Phenotype Hits`)
colnames(mouse_count2)[1] <- 'Phenotype'
mouse_count_pheno <- aggregate(list(numdup=rep(1,nrow(mouse_count2))), mouse_count2, length)
mouse_count_pheno <- mouse_count_pheno  %>% dplyr::arrange(desc(numdup))
mouse_count_pheno <- mouse_count_pheno[1:20,]
colnames(mouse_count_pheno)[2] <- 'Count'

mouse_count_pheno$Phenotype <- factor(mouse_count_pheno$Phenotype, levels = mouse_count_pheno$Phenotype)

dt <- merge(mouse_count_pheno, results, by='Phenotype', all.x=T)
dt$pval_adjusted <-signif(dt$pval_adjusted, digits = 5)
mouse_df_plot2 <- dt

setwd('/home/hnicholls/HCM_druggability/Output')
# Set the file output directly without needing a display
png("Genes_ranked_IMPC_enrichment.png", width = 14, height = 8, units = "in", res = 300)

# Generate the plot
p2 <- ggplot(data=mouse_df_plot2, aes(x=Phenotype, y=Count)) +
  geom_bar(stat="identity", fill="darkslateblue") +
  theme(text = element_text(family = "Arial"),
        axis.text.x = element_text(color = "grey20", size = 16, hjust = .5, vjust = .5, face = "plain"),
        axis.text.y = element_text(color = "grey20", size = 14, angle = 0, hjust = 1, vjust = 0, face = "plain"),  
        axis.title.x = element_text(color = "grey20", size = 16, angle = 0, hjust = .5, vjust = 0, face = "plain"),
        axis.title.y = element_text(color = "grey20", size = 16, angle = 90, hjust = .5, vjust = .5, face = "plain")) +
  theme(plot.title = element_text(size = 16, face = "bold"),
        legend.title=element_text(size=14), legend.text=element_text(size=14)) +
  coord_flip() +
  ggtitle("Top 20 Most Frequent IMPC Mouse Phenotypes")  + 
  ylab("Gene Count") + 
  theme(plot.title = element_text(hjust = 0.5)) +
  geom_text(aes(label=pval_adjusted), position=position_dodge(width=0.9), vjust=0.25, hjust = 1.1, colour = "white")

p2
# Close the PNG device
dev.off()

df2 <- select(new_mouse,  `MGI Gene Id`,  `Phenotype Hits`, Gene)
df2 <- filter(df2, Gene %in% gene_list$Gene)
setnames(df2, 'Phenotype Hits', 'Phenotype')
results2 <- merge(results, df2, by='Phenotype', all.x=TRUE)
results2 <- select(results2, -tested)
collapsed_results <- results2 %>%
  group_by(Phenotype) %>%
  summarise(
    pval = first(pval),
    pval_adjusted = first(pval_adjusted),
    `MGI Gene Id` = toString(unique(`MGI Gene Id`)),
    Gene = toString(unique(Gene))
  ) %>%
  ungroup() 

fwrite(collapsed_results, '/home/hnicholls/HCM_druggability/Output/IMPC_results_table.csv')

