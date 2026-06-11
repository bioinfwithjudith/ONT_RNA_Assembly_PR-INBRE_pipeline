#!/usr/bin/env nextflow

/*
* use samtools to generate file conversions for stringtie2
*/

//
process SAM_TO_BAM {

	tag "$sample_id"
	
	publishDir "${params.outdir}/minimap2/${sample_id}", mode: "copy"

	input:
	tuple val(sample_id), path(sam)

	output:
	tuple val(sample_id), path("${sample_id}.bam")

	script:
	"""
	module load ${params.samtools_mod}

	samtools view -bS $sam > ${sample_id}.bam 
	"""
}

//
process SAM_SORT_PLEASE {

        tag "$sample_id"

        publishDir "${params.outdir}/minimap2/${sample_id}", mode: "copy"

        input:
        tuple val(sample_id), path(sam)

        output:
        tuple val(sample_id), path("${sample_id}.sorted.bam")

        script:
        """
        module load ${params.samtools_mod}

	samtools sort $sam  > ${sample_id}.sorted.bam 
	"""
}


process SAM_INDEX_PLEASE {

        tag "$sample_id"

        publishDir "${params.outdir}/minimap2/${sample_id}", mode: "copy"

        input:
        tuple val(sample_id), path(bam)

        output:
        tuple val(sample_id), path("${sample_id}.sorted.bam.bai")

        script:
        """
        module load ${params.samtools_mod}

        samtools index $bam
        """
}

