#!/usr/bin/env nextflow

/*
* use samtools to generate file conversions for stringtie2
*/

//
process SAM_TO_BAM {

	tag "$sample_id"
	
	publishDir "${params.outdir}/minimap2", mode: "copy"

	input:
	tuple val(sample_id), path(sam)

	output:
	tuple val(sample_id), path("${sample_id}_alignment.bam")

	script:
	"""
	samtools view -b -o ${sample_id}_alignment.bam $sam 
	"""
}

//
process BAM_SORT_PLEASE {

        tag "$sample_id"

        publishDir "${params.outdir}/minimap2", mode: "copy"

        input:
        tuple val(sample_id), path(bam)

        output:
        tuple val(sample_id), path("${sample_id}_alignment.sorted.bam")

        script:
        """
		samtools sort -o ${sample_id}_alignment.sorted.bam $bam 
		"""
}


process BAM_INDEX_PLEASE {

        tag "$sample_id"

        publishDir "${params.outdir}/minimap2", mode: "copy"

        input:
        tuple val(sample_id), path(bam)

        output:
        tuple val(sample_id), path("${sample_id}_alignment.sorted.bam.bai")

        script:
        """
        samtools index -o ${sample_id}_alignment.sorted.bam.bai $bam 
        """
}

process BAM_COLLATE_PLEASE {

        tag "$sample_id"

        publishDir  "${params.outdir}/minimap2", mode: "copy"

        input:
        tuple val(sample_id), path(bam)

        output:
        tuple val(sample_id), path("${sample_id}_alignment.collated.bam")

        script:
        """
        samtools collate -o ${sample_id}_alignment.collated.bam $bam
        """
}
