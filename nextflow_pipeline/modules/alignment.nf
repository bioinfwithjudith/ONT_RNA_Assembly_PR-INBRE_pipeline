#!/usr/bin/env nextflow

/*
* align filtered ONT reads with minimap2 module
*/


process MINIMAP2_ALIGNMENT {

	tag "$sample_id"
	
	publishDir "${params.outdir}/minimap2/${sample_id}", mode: "copy"

	input:
	tuple val(sample_id), path(reads)

	output:
	tuple val(sample_id), path("${sample_id}_minimap2.sam")

	script:
	"""
	module load ${params.minimap2_mod}

	minimap2 -ax splice ${params.reference_genome} $reads > ${sample_id}_minimap2.sam
	"""
}

