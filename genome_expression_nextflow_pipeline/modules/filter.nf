#!/usr/bin/env nextflow

/*
* Filter raw ONT reads with filtlong module
*/


process FILTLONG_FILTER {

	tag "$sample_id"
	
	publishDir "${params.outdir}/filtlong/${sample_id}", mode: "copy"

	input:
	tuple val(sample_id), path(reads)

	output:
	tuple val(sample_id), path("${sample_id}_filtlong.fastq")

	script:
	"""
	module load filtlong/c56f02b

	filtlong \
		--min_mean_q ${params.phred_filter} \
		--min_length ${params.length_filter} \
		$reads > ${sample_id}_filtlong.fastq
	"""
}

