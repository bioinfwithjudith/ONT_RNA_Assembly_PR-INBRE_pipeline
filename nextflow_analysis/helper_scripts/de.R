# 1. Install any missing library ----
#if (!requireNamespace("BiocManager", quietly=TRUE))
#  install.packages("BiocManager")

#BiocManager::install("DESeq2")

#install.packages("ggplot2")

# 2. Import libraries ----
library(DESeq2)
library(ggplot2)

# 3. Data import and preprocessing ----
counts_tsv = read.table("/Volumes/X9_Pro/lvazquez_contract/differential_expression_local_analysis/transcript_counts.tsv", 
                        sep = "\t", header = TRUE)

counts <- as.data.frame(counts_tsv)

rownames(counts) <- counts[,1]
counts <- counts[,-1]

counts <- as.matrix(counts)
mode(counts) <- "numeric"

sample_info <- data.frame( 
  condition = factor(c(
    "barcode4", "barcode4", "barcode4","barcode5",
    "barcode6", "barcode6", "barcode6" , "barcode6"
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
  file = "/Volumes/X9_Pro/lvazquez_contract/differential_expression_local_analysis/DESeq2_results.csv",
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


# Generate an ugly volcano plot
res_df <- as.data.frame(res)
res_df$transcript <- rownames(res_df)

ggplot(res_df, aes(x = log2FoldChange,
                   y = -log10(padj))) +
  geom_point(alpha = 0.7) +
  theme_classic()
