#!/usr/bin/env nextflow

/*
* use salmon to quantify ONT aligned reads
*/

//
process SALMON_INDEX {


        publishDir "${params.outdir}/quantification", mode: "copy"

        output:
        path("salmon_index")

        script:
        """
        salmon index -t ${params.reference_rna} \
        -i salmon_index \
        -k ${params.ksize}
	"""
}

//
process SALMON_QUANTIFY {

	tag "$sample_id"
	
	publishDir "${params.outdir}/quantification", mode: "copy"

	input:
	tuple val(sample_id), path(sam)

	output:
	tuple val(sample_id), path("${sample_id}_salmon_quant")

	script:
	"""
	salmon quant \
	-t ${params.reference_rna} \
	-l A \
	-a $sam \
	-o ${sample_id}_salmon_quant \
	--threads 6

	"""
}


process OARFISH_QUANTIFY {
    tag "$sample_id"
    publishDir "${params.outdir}/quantification", mode: "copy"

    input:
    tuple val(sample_id), path(bam)

    output:
    tuple val(sample_id), path("${sample_id}_oarfish_quant.quant")

    script:
    """
    oarfish \
        --alignments $bam \
        --output ${sample_id}_oarfish_quant \
    """
}

