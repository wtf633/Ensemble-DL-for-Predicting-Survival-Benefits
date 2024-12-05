#### Identifying DEGs ####
library(DESeq2)
library(tidyverse)
gene_matrix <- read.csv("Q:\\TIHC_R\\gen_t\\Gene_LIHC.csv",  check.names = F, stringsAsFactors = F)
colnames(gene_matrix)
gene_matrix = na.omit(gene_matrix) 
row.names(gene_matrix) <- gene_matrix$Gene.Symbol
dim(gene_matrix)
matrix_final = gene_matrix[gene_matrix$Gene.Symbol != "",]
dim(matrix_final)
matrix_final <- subset(matrix_final, select = -1)  
dim(matrix_final)
dljdz=function(x) {
  DOWNB=quantile(x,0.25)-1.5*(quantile(x,0.75)-quantile(x,0.25))
  UPB=quantile(x,0.75)+1.5*(quantile(x,0.75)-quantile(x,0.25))
  x[which(x<DOWNB)]=quantile(x,0.5)
  x[which(x>UPB)]=quantile(x,0.5)
  return(x)
}
matrix_leave=matrix_final
boxplot(matrix_leave,outline=FALSE, notch=T, las=2)  
dim(matrix_leave)
# Handle outliers
matrix_leave_res=apply(matrix_leave,2,dljdz)
boxplot(matrix_leave_res,outline=FALSE, notch=T, las=2)  
dim(matrix_leave_res)
gene_avg <- apply(matrix_final, 1, mean)
filtered_genes_1 <- matrix_final[gene_avg >= 1, ]
dim(filtered_genes_1)
write.csv(filtered_genes_1,'Q:\\TIHC_R\\gen_t\\exprSet_clean_count.csv',row.names = TRUE)
gene_matrix <- read.csv("Q:\\TIHC_R\\gen_t\\exprSet_clean_count.csv", row.names = 1, check.names = F, stringsAsFactors = F)
colnames(gene_matrix)
risk_score <- read.csv("Q:\\TIHC_R\\gen_t\\score.csv",  row.names = 1, check.names = T, stringsAsFactors = F)
rownames(risk_score)
if(!all(colnames(gene_matrix) %in% rownames(risk_score))) {
  stop("Column names do not match. Check the column names for risk_score and gene_matrix")
}

# Transpose risk_score to match gene_matrix format
risk_score <- t(risk_score)
gene_matrix <- rbind(gene_matrix, risk_score)
sum(is.na(gene_matrix))
gene_matrix <- na.omit(gene_matrix)
sum(is.na(gene_matrix))
rnames <- rownames(gene_matrix)
rnames
print(tail(gene_matrix))
write.csv(gene_matrix,'Q:\\TIHC_R\\gen_t\\Gene_matrix_QX.csv',row.names = TRUE)

# 根据 risk_score stratification
rownames(gene_matrix)[21565:21566] 
gene <- "risk_os" #Enter the above variable name

conditions <- data.frame(
  sample = colnames(gene_matrix),
  group = factor(ifelse(gene_matrix[gene,] >= 1.25948, "high", "low"), levels = c("low", "high")),
  row.names = colnames(gene_matrix) 
)
conditions
any(is.na(gene_matrix[c(1:21564),]))  
any(!is.integer(gene_matrix[c(1:21564),]))  

non_integer_values <- gene_matrix[which(!is.integer(gene_matrix))]
non_integer_values
sapply(non_integer_values, class)
dds <- DESeqDataSetFromMatrix(
  countData = gene_matrix[c(1:21564),],
  colData = conditions,
  design = ~ group)
dds <- DESeq(dds)
resultsNames(dds)
res <- results(dds)
res_deseq2 <- as.data.frame(res)%>% 
  arrange(padj) %>% 
  dplyr::filter(abs(log2FoldChange) > 0, padj < 0.05)
print(head(res_deseq2))
write.csv(res_deseq2, "Q:\\TIHC_R\\gen_t\\DEG_results.csv", row.names = TRUE)
table(res$padj<0.05)
deseq_res <- as.data.frame(res[order(res$padj), ])
deseq_res$gene_id <- rownames(deseq_res)
write.csv(deseq_res[c(7, 1:6)], 'Q:\\TIHC_R\\gen_t\\DESeq_data1.csv', row.names = FALSE, sep = '\t', quote = FALSE)

# write.table(deseq_res[c(7, 1:6)], 'Q:\\TIHC_R\\gen_t\\DESeq_data1.txt', row.names = FALSE, sep = '\t', quote = FALSE)

deseq_res <- read.delim('Q:\\TIHC_R\\gen_t\\DESeq_data.txt', sep = '\t')
library(ggpubr)
library("ggplot2")
library(ggthemes)
ggthemes::theme_base()
DEG_data <- deseq_res
DEG_data$logP <- -log10(DEG_data$padj) # log10() conversion p-value after differential gene correction
dim(DEG_data)
DEG_data$Group <- "not-siginficant"
DEG_data$Group[which((DEG_data$padj < 0.05) & DEG_data$log2FoldChange > 2)] = "up-regulated"
DEG_data$Group[which((DEG_data$padj < 0.05) & DEG_data$log2FoldChange < -2)] = "down-regulated"
table(DEG_data$Group)
DEG_data <- DEG_data[order(DEG_data$padj),]
DEG_data$gene_id <- rownames(DEG_data)
#Add points to volcano map (data construction)
up_label <- head(DEG_data[DEG_data$Group == "up-regulated",],1)
down_label <- head(DEG_data[DEG_data$Group == "down-regulated",],1)
deg_label_gene <- data.frame(gene = c(rownames(up_label),rownames(down_label)),
                             label = c(rownames(up_label),rownames(down_label)))
DEG_data$gene <- rownames(DEG_data)
DEG_data <- merge(DEG_data,deg_label_gene,by = 'gene',all = T)
#不添加label
ggscatter(DEG_data,x = "log2FoldChange",y = "logP",
          color = "Group",
          palette = c("green","gray","red"),
          repel = T,
          ylab = "-log10(Padj)",
          size = 3) + 
  theme_base()+
  scale_y_continuous(limits = c(0,8))+
  scale_x_continuous(limits = c(-10,6))+
  geom_hline(yintercept = 1.3,linetype = "dashed")+
  geom_vline(xintercept = c(-2,2),linetype = "dashed")
# 新加一列Label
deg.data<- deseq_res
deg.data$logFDR <- -log10(deg.data$padj) 
deg.data$log2FC <- deg.data$log2FoldChange
# 新加一列Group
deg.data$Group = "normal"
deg.data$Group[which((deg.data$padj < 0.05) &deg.data$log2FoldChange > 2)] = "up"
deg.data$Group[which((deg.data$padj < 0.05) & deg.data$log2FoldChange < -2)] = "down"
table(deg.data$Group)
deg.data$Label = ""
deg.data <- deg.data[order(deg.data$padj), ]
up.genes <- head(deg.data$gene_id[which(deg.data$Group == "up")], 10)
up.genes
down.genes <- head(deg.data$gene_id[which(deg.data$Group == "down")],10)
down.genes
deg.top10.genes <- c(as.character(up.genes), as.character(down.genes))
deg.top10.genes
deg.data$Label[match(deg.top10.genes, deg.data$gene_id)] <- deg.top10.genes
deg.top10.genes
# The top 10 differentially expressed genes were added to the volcano map
p<-ggscatter(deg.data, x = "log2FC", y = "logFDR",
             color = "Group",
             palette = c("#00ba38", "grey11", "#f13527"),
             size = 3.5,
             label = deg.data$Label,
             font.label = 12,
             repel = T) + theme_base() + xlab("log2(FC)") + ylab("-log10(FDR)")+
  scale_y_continuous(limits = c(0,8))+
  scale_x_continuous(limits = c(-9.5,6))+
  geom_hline(yintercept = 1.30, linetype="dashed") +
  geom_vline(xintercept = c(-2,2), linetype="dashed")
png(file="Q:\\TIHC_R\\gen_t\\volc.png", bg="transparent",width = 2000, height = 1500, res = 300, units = "px")
print(p)
dev.off()


#### GO/KEGG analysis  ####

library(tidyverse)
library("BiocManager")
library(org.Hs.eg.db)
library(clusterProfiler)
library(readxl)
library(openxlsx)
library(ggplot2)
library(stringr)
library(enrichplot)
library(clusterProfiler)
library(GOplot)
library(DOSE)
library(ggnewscale)
library(topGO)
library(circlize)
library(ComplexHeatmap)
info <- read.csv( "Q:\\TIHC_R\\gen_t\\DEG_GO.csv", check.names = F, stringsAsFactors = F)
GO_database <- 'org.Hs.eg.db' #GO，http://bioconductor.org/packages/release/BiocViews.html#___OrgDb
KEGG_database <- 'hsa' #KEGG，http://www.genome.jp/kegg/catalog/org_list.html
gene <- bitr(info$gene_id,fromType = 'SYMBOL',toType = 'ENTREZID',OrgDb = GO_database)
GO<-enrichGO( gene$ENTREZID,#GO
              OrgDb = GO_database,
              keyType = "ENTREZID",
              ont = "ALL",
              pvalueCutoff = 0.05,
              qvalueCutoff = 0.05,
              readable = T)
dotplot(GO, showCategory = 10)
# Generate and save the dotplot
png(file="Q:\\TIHC_R\\gen_t\\GO.png", bg="transparent", width=2000, height=1500, res=300, units="px")
dotplot(GO, showCategory = 10)  # Show top 10 categories in the dotplot
dev.off()

KEGG<-enrichKEGG(gene$ENTREZID,#KEGG
                 # organism = KEGG_database,
                 organism ="hsa",
                 pvalueCutoff = 0.05,
                 qvalueCutoff = 0.05)
KEGG<- DOSE::setReadable(KEGG, OrgDb="org.Hs.eg.db", keyType='ENTREZID')#ENTREZID to gene Symbol

kegg_res <- setReadable(KEGG, OrgDb = org.Hs.eg.db, keyType="ENTREZID")
kegg_res <- data.frame(kegg_res)
kegg_res
kegg_res <- mutate(kegg_res , richFactor = Count / as.numeric(sub("/\\d+", "", BgRatio)))
kegg_res
kegg_res <- kegg_res [kegg_res $pvalue<0.05, ]
write.csv(kegg_res , file = "Q:\\TIHC_R\\gen_t\\KEGG_res.csv")
png(file="Q:\\TIHC_R\\gen_t\\KEGG.png", bg="transparent", width=2000, height=1500, res=300, units="px")
dotplot(KEGG, showCategory = 10)  # Show top 10 categories in the dotplot
dev.off()

#### enrichKEGG ####

mono_lps <- read.csv("Q:\\TIHC_R\\gen_t\\DEG_GO.csv",
                     header = T, check.names = F, stringsAsFactors = F, row.names = 1)

lps_up <- mono_lps[abs(mono_lps$log2FoldChange) > 0.25 & mono_lps$padj < 0.05, ]

lps.gene.df <- bitr(rownames(lps_up), fromType = "SYMBOL",
                    toType = c("ENSEMBL", "ENTREZID"),
                    OrgDb = org.Hs.eg.db)
lps.gene.df
# match up fc values with genes
id_fc <- match(lps.gene.df$SYMBOL, table = rownames(lps_up))
lps.gene.df$FC <- lps_up$log2FoldChange[id_fc]
lps.gene.df
lps.gene.df$FDR <- lps_up$padj[id_fc]
genes_use <- lps.gene.df$FC
names(genes_use) <- lps.gene.df$ENTREZID
ekegg <- enrichKEGG(names(genes_use), organism = "hsa", qvalueCutoff = 0.05)
## convert gene ID to Symbol
edox <- setReadable(ekegg, 'org.Hs.eg.db', 'ENTREZID')
edox_sel <- edox
edox_sel
edox_sel@result$Description

# subset the pathway results
# edox_sel@result <- edox_sel@result[edox_sel@result$Description %in% c("PI3K-Akt signaling pathway",
#                                                                       "Ras signaling pathway",
#                                                                       "MAPK signaling pathway",
#                                                                       "Retinol metabolism",
#                                                                       "Focal adhesion",
#                                                                       "Drug metabolism - cytochrome P450",
#                                                                       "Metabolism of xenobiotics by cytochrome P450",
#                                                                       "Ovarian steroidogenesis",
#                                                                       "Steroid hormone biosynthesis",
#                                                                       "Glycolysis / Gluconeogenesis")]
selected_pathways <- c("PI3K-Akt signaling pathway", 
                       "Ras signaling pathway", 
                       "MAPK signaling pathway",
                       "Retinol metabolism",
                       "Steroid hormone biosynthesis",
                       "Glycolysis / Gluconeogenesis")
edox_sel@result <- edox_sel@result[edox_sel@result$Description %in% selected_pathways, ]
edox_sel@result 
# plot by p-value of each gene in diff exp analysis
genes_use <- -log10(lps.gene.df$FDR)
id_inf <- which(is.infinite(genes_use))
genes_use[id_inf] <- 300
names(genes_use) <- lps.gene.df$ENTREZID
# identify which genes were reduced and add a signage
id_nge <- which(lps.gene.df$FC < 0)
genes_use[id_nge] <- -genes_use[id_nge]
p1 <- cnetplot(edox_sel, 
               foldChange=genes_use, 
               showCategory = length(selected_pathways), 
               circular=TRUE, 
               colorEdge=T,
               cex_label_gene = 1.0,
               cex_label_category = 1.2)+
  scale_colour_gradient2(low = "blue", mid = "white", high = "red", midpoint = 0) +
  labs(color = "-log10(FDR)",size = "size")+
  theme(text = element_text(size = 14, family = "Arial",face = 'bold'),
        legend.text = element_text(size = 12,family = "Arial",face = 'bold'),
  )
ggsave(filename = "Q:\\TIHC_R\\gen_t\\KEGG_Pathways_Monocyte.tiff", plot = p1, width = 13.5, height = 8.5, dpi = 300)
