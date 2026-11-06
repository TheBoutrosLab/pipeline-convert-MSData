/**
 * Nextflow module for converting MS data using OpenMS FileConvert
 */

process convert_msdata_OpenMS {
    container params.docker_image_openms

    publishDir { "${params.final_output_dir}/${meta.sample_name}/${params.software_dir}/output" },
        mode: 'copy',
        pattern: "*.${params.output_format}",
        enabled: params.run_index == false && params.peak_picking_openms == false

    publishDir { "${params.intermediate_file_dir}/${meta.sample_name}/${params.software_dir}/intermediate/${task.process.replace(':', '/')}" },
        mode: 'copy',
        pattern: "*.${params.output_format}",
        enabled: params.save_intermediate_files && (params.run_index || params.peak_picking_openms)

    input:
        tuple(
            val(meta),
            path(input_msdata),
            path(msdata_metadata)
        )

    output:
        tuple val(meta), path(output_file)

    script:
    output_file = "${meta.fraction_id}_${input_msdata.baseName}.${params.output_format}"
    peak_picking_vendor = params.peak_picking_vendor ? '' : '-no_peak_picking'
    """
    set -euo pipefail

    FileConverter \\
        -in ${input_msdata} \\
        -out ${output_file} \\
        ${peak_picking_vendor} \\
        -threads ${task.cpus}
    """
}
