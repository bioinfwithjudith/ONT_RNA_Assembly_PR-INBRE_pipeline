paste \
<(cut -f1 /Volumes/X9_Pro/lvazquez_contract/differential_expression_local_analysis/results_replicates_lowerbands_barcode4_H1299/quantification/SRR30955394_oarfish_quant.quant) \
<(cut -f3 /Volumes/X9_Pro/lvazquez_contract/differential_expression_local_analysis/results_replicates_lowerbands_barcode4_H1299/quantification/SRR30955394_oarfish_quant.quant) \
<(cut -f3 /Volumes/X9_Pro/lvazquez_contract/differential_expression_local_analysis/results_replicates_lowerbands_barcode4_H1299/quantification/SRR30955395_oarfish_quant.quant) \
<(cut -f3 /Volumes/X9_Pro/lvazquez_contract/differential_expression_local_analysis/results_replicates_lowerbands_barcode4_H1299/quantification/SRR30955396_oarfish_quant.quant) \
<(cut -f3 /Volumes/X9_Pro/lvazquez_contract/differential_expression_local_analysis/results_replicates_lowerbands_barcode5_H1299/quantification/SRR30955375_oarfish_quant.quant) \
<(cut -f3 /Volumes/X9_Pro/lvazquez_contract/differential_expression_local_analysis/results_replicates_lowerbands_barcode6_H1299/quantification/SRR30954502_oarfish_quant.quant) \
<(cut -f3 /Volumes/X9_Pro/lvazquez_contract/differential_expression_local_analysis/results_replicates_lowerbands_barcode6_H1299/quantification/SRR30954503_oarfish_quant.quant) \
<(cut -f3 /Volumes/X9_Pro/lvazquez_contract/differential_expression_local_analysis/results_replicates_lowerbands_barcode6_H1299/quantification/SRR30954504_oarfish_quant.quant) \
<(cut -f3 /Volumes/X9_Pro/lvazquez_contract/differential_expression_local_analysis/results_replicates_lowerbands_barcode6_H1299/quantification/SRR30954505_oarfish_quant.quant) \
> /Volumes/X9_Pro/lvazquez_contract/differential_expression_local_analysis/transcript_counts.tsv

sed -i '' '1s/.*/transcript\tSRR30955394\tSRR30955395\tSRR30955396\tSRR30955375\tSRR30954502\tSRR30954503\tSRR30954504\tSRR30954505/' transcript_counts.tsv

