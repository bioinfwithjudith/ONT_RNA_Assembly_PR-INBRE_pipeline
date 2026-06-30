#!/bin/bash

# Directory containing the quant files
QUANT_DIR="/Volumes/X9_Pro/lvazquez_contract/differential_expression_local_analysis_larger_dataset/results/quantification"

# Output file
OUTFILE="/Volumes/X9_Pro/lvazquez_contract/differential_expression_local_analysis_larger_dataset/transcript_counts.tsv"

# Find all quant files and sort them
files=("$QUANT_DIR"/*_oarfish_quant.quant)

# Exit if no files found
if [ ${#files[@]} -eq 0 ]; then
    echo "No quant files found in $QUANT_DIR"
    exit 1
fi

# Build the paste command
cmd="paste <(cut -f1 \"${files[0]}\")"

# Collect sample names for the header
header="transcript"

for f in "${files[@]}"; do
    cmd+=" <(cut -f3 \"$f\")"

    # Remove the suffix to get the sample name
    sample=$(basename "$f" "_oarfish_quant.quant")
    header+="\t$sample"
done

# Execute the paste command
eval "$cmd > \"$OUTFILE\""

# Replace the first line with the desired header
sed -i '' "1s/.*/$header/" "$OUTFILE"

echo "Created $OUTFILE"

