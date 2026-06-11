#!/usr/bin/env nextflow

/*
* reference basedassemble of ONT reads 
*/


process STRINGTIE2_ASSEMBLE {

	tag "$sample_id"
	
	publishDir "${params.outdir}/stringtie2/${sample_id}", mode: "copy"

	input:
	tuple val(sample_id), path(sorted_bam)

	output:
	tuple val(sample_id), path("${sample_id}.gtf")

	script:
	"""
	module load ${params.stringtie2_mod}


	stringtie -L -p 32 -G ${params.reference_gff} $sorted_bam -o ${sample_id}.gtf

	"""
}

