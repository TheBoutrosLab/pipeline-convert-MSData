/**
 * Run OpenMS PeakPickerHiRes and generate centroid data
 */

process pick_peaks {
    container params.docker_image_openms

    publishDir { "${params.final_output_dir}/${meta.sample_name}/${params.software_dir}/output" },
        mode: 'copy',
        pattern: "*.${params.output_format}",
        enabled: params.peak_picking_openms

    input:
        tuple val(meta), path(msdata)

    output:
        tuple val(meta), path(centroid_msdata)

    script:
    centroid_msdata = "${meta.output_basename}.mzML"
    temporary_file = "centroid_${centroid_msdata}"
    """
    set -euo pipefail
    PeakPickerHiRes \
        -in ${msdata} \
        -out ${temporary_file} \
        -threads ${task.cpus}
    mv -- ${temporary_file} ${centroid_msdata}
    """
}
