#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { FILTLONG_FILTER } from './modules/filter.nf'
include { MINIMAP2_ALIGNMENT } from './modules/alignment.nf'
include { SAM_TO_BAM; BAM_SORT_PLEASE; BAM_INDEX_PLEASE; BAM_COLLATE_PLEASE } from "./modules/samming.nf"
include { OARFISH_QUANTIFY } from "./modules/quantification.nf"

workflow {

    // Extracts the filename (e.g., SRR30955394) as the sample_id automatically
    	Channel
        	.fromPath(params.reads_pattern)
        	.map { file -> tuple(file.baseName.replaceAll(/\.fastq$/, ''), file) }
        	.set { reads_ch }

	// filter reads, review current parameters in nextflow.config file
	filtlong_ch = FILTLONG_FILTER(reads_ch)

	// align filtered reads using minimap2
	minimap2_ch = MINIMAP2_ALIGNMENT(filtlong_ch)

	// use samtools to convert sam file generated with MINIMAP2_ALIGN process to a sorted.bam file as input for stringtie2
	bam_ch = SAM_TO_BAM(minimap2_ch)
	collate_bam_ch = BAM_COLLATE_PLEASE(bam_ch)
	//sort_bam_ch = BAM_SORT_PLEASE(bam_ch)
	//BAM_INDEX_PLEASE(sort_bam_ch)

    // quantify aligned ONT reads using salmon
    OARFISH_QUANTIFY(collate_bam_ch)
}

