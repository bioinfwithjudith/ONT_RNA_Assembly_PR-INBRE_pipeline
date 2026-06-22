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
        module load ${params.salmon_mod}

        salmon index -t ${params.reference_rna} \
        -i salmon_index \
        -k ${params.ksize}
	"""
}

//
process SALMON_QUANTIFY {

	tag "$sample_id"
	
	publishDir "${params.outdir}/quantification/${sample_id}", mode: "copy"

	input:
	tuple val(sample_id), path(sorted_bam)
	path(index)

	output:
	tuple val(sample_id), path("${sample_id}_salmon_quant")

	script:
	"""
	module load ${params.salmon_mod}

	salmon quant \
	-i $index \
	-l A \
	-a $sorted_bam \
	-o ${sample_id}_salmon_quant \
	--threads 32

	"""
}



