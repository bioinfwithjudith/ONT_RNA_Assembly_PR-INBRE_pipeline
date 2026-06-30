# 1. Install any missing library ----
#if (!requireNamespace("BiocManager", quietly=TRUE))
#  install.packages("BiocManager")

#BiocManager::install("DESeq2")

#install.packages("ggplot2")

#if (!require("BiocManager", quietly = TRUE))
#  install.packages("BiocManager")

#BiocManager::install("org.Hs.eg.db")

#BiocManager::install("clusterProfiler")

#install.packages("ggraph")

#install.packages("nlme", type = "binary")




# 2. Import libraries ----
library(DESeq2)
library(ggplot2)
library(org.Hs.eg.db)
#library(clusterProfiler)

# 3. Data import and preprocessing ----
counts_tsv = read.table("/Volumes/X9_Pro/lvazquez_contract/differential_expression_local_analysis_larger_dataset/transcript_counts.tsv", 
                        sep = "\t", header = TRUE)

counts <- as.data.frame(counts_tsv)

rownames(counts) <- counts[,1]
counts <- counts[,-1]

counts <- as.matrix(counts)
mode(counts) <- "numeric"

sample_info <- data.frame( 
  condition = factor(c(
    "Bdp1AA_Rna15AA", "Bdp1AA_Rna15AA", "Bdp1AA_Rna15AA",
    "Bdp1AA", "Bdp1AA", "Bdp1AA",
    "WT", "WT", "WT"
  )),
  row.names = colnames(counts)
)

# 3. Generate DESeq2 matrix ----
dds <- DESeqDataSetFromMatrix(
  countData = counts,
  colData = sample_info,
  design = ~ condition
)

# 4. Running DESeq2 ----
dds <- DESeq(dds)

# 5. Convert to dataframe for further analysis ----
res <- results(dds)
res_ordered <- res[order(res$padj), ]
res_df <- as.data.frame(res_ordered)

# Save dataframe, you never know
write.csv(
  res_df,
  file = "/Volumes/X9_Pro/lvazquez_contract/differential_expression_local_analysis_larger_dataset/DESeq2_results.csv",
  row.names = TRUE
)

# 6. Plotting DESeq2 results ----

# Generate MA plot
plotMA(res, ylim = c(-5, 5))

# Generate PCA plot
vsd <- varianceStabilizingTransformation(dds, blind = TRUE)
plotPCA(vsd, intgroup = "condition")

rld <- rlog(dds, blind = TRUE)
plotPCA(rld, intgroup = "condition")


# Generate a volcano plot
res_df <- as.data.frame(res)
res_df$transcript <- rownames(res_df)

# Generate a volcano plots with datapoints of interest

res_df$group <- "Not significant"

res_df$group[res_df$padj < padj_value & res_df$log2FoldChange >= 2] <- "Upregulated"
res_df$group[res_df$padj < padj_value & res_df$log2FoldChange <= -3] <- "Downregulated"

ggplot(res_df, aes(x = log2FoldChange,
                   y = -log10(padj),
                   color = group)) +
  geom_point(alpha = 0.7) +
  geom_vline(xintercept = c(-3, 2), linetype = "dashed") +
  geom_hline(yintercept = -log10(padj_value), linetype = "dashed") +
  theme_classic() +
  scale_color_manual(values = c(
    "Not significant" = "grey70",
    "Upregulated" = "red",
    "Downregulated" = "blue"
  ))

# 7. Obtain significant genes
padj_value <- 1e-50

sig <- res[
  which(
    res$padj < padj_value &
      (res$log2FoldChange <= -3 | res$log2FoldChange >= 2)
  ),
]

sig_downregulated <- res[
    which(
      res$padj < padj_value &
        (res$log2FoldChange <= -3)
),
]

sig_upregulated <- res[
  which(
    res$padj < padj_value &
      (res$log2FoldChange >= 2)
  ),
]


sig_genes <- rownames(sig_upregulated)

write.table(sig_genes,
            file = "/Volumes/X9_Pro/lvazquez_contract/differential_expression_local_analysis_larger_dataset/de/significant_upregulated_genes.txt",
            quote = FALSE,         
            row.names = FALSE,
            col.names = FALSE)
