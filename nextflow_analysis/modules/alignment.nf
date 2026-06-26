#!/usr/bin/env nextflow

/*
* align filtered ONT reads with minimap2 module
*/


process MINIMAP2_ALIGNMENT {

	tag "$sample_id"
	
	publishDir "${params.outdir}/minimap2", mode: "copy"

	input:
	tuple val(sample_id), path(reads)

	output:
	tuple val(sample_id), path("${sample_id}_alignment.sam")

	script:
	"""
	minimap2 -ax splice ${params.reference_rna} $reads > ${sample_id}_alignment.sam
	"""
}

