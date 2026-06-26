paste \
<(cut -f1 SRR30955394_oarfish_quant.quant) \
<(cut -f3 SRR30955394_oarfish_quant.quant) \
<(cut -f3 SRR30955395_oarfish_quant.quant) \
<(cut -f3 SRR30955396_oarfish_quant.quant) \
<(cut -f3 SRR30955397_oarfish_quant.quant) \
<(cut -f3 SRR30955398_oarfish_quant.quant) \
<(cut -f3 SRR30955399_oarfish_quant.quant) \
> transcript_counts.tsv

sed -i '' '1s/.*/transcript\tSRR30955394\tSRR30955395\tSRR30955396\tSRR30955397\tSRR30955398\tSRR30955399/' transcript_counts.tsv
