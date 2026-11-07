/**
 * Nextflow module for converting MS data using ProteoWizard msconvert
 */

process convert_msdata_ProteoWizard {
    container params.docker_image_pwiz
    containerOptions { workflow.containerEngine == 'docker' ? '-u root -e WINEDEBUG=-all' : '' }

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
            path(input_scan)
        )

    output:
        tuple val(meta), path(output_file)

    script:
    output_file = "${meta.output_basename}.${params.output_format}"
    temporary_file = "converted_${output_file}"
    peak_picking_vendor = params.peak_picking_vendor ? '--filter "peakPicking true 1-"' : ''
    """
    set -euo pipefail

    wine msconvert \\
        ${input_msdata} \\
        -o . \\
        --outfile ${temporary_file} \\
        --${params.output_format} \\
        ${peak_picking_vendor} \\
        --filter "titleMaker <RunId>.<ScanNumber>.<ScanNumber>.<ChargeState>" \\
        ${params.pwiz_extra_args}
    mv -- ${temporary_file} ${output_file}
    if [ "\$(id -u)" -eq 0 ]; then
        chown "\$(stat -c '%u' ${input_msdata})":"\$(stat -c '%g' ${input_msdata})" ${output_file}
    fi
    """
}
