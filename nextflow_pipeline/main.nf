#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { FILTLONG_FILTER } from './modules/filter.nf'
include { MINIMAP2_ALIGNMENT } from './modules/alignment.nf'
include { SAM_TO_BAM; SAM_SORT_PLEASE; SAM_INDEX_PLEASE } from "./modules/samming.nf"
include { STRINGTIE2_ASSEMBLE } from "./modules/assemble.nf"
include { SALMON_INDEX; SALMON_QUANTIFY } from "./modules/quantification.nf"

workflow {

	Channel
		.of( tuple(params.sample_id, file(params.reads)) )
		.set { reads_ch }

	// filter reads, review current parameters in nextflow.config file
	filtlong_ch = FILTLONG_FILTER(reads_ch)

	// align filtered reads using minimap2
	minimap2_ch = MINIMAP2_ALIGNMENT(filtlong_ch)

	// use samtools to convert sam file generated with MINIMAP2_ALIGN process to a sorted.bam file as input for stringtie2
	bam_ch = SAM_TO_BAM(minimap2_ch)
	sort_bam_ch = SAM_SORT_PLEASE(minimap2_ch)
	SAM_INDEX_PLEASE(bam_ch)
	
	// reference based assembly of ONT alignment using stringtie2
	STRINGTIE2_ASSEMBLE(sort_bam_ch)

	// quantify aligned ONT reads using salmon
	index_ch = SALMON_INDEX()
	SALMON_QUANTIFY(sort_bam_ch, index_ch) 
}

