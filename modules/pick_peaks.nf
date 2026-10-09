/**
 * Run OpenMS PeakPickerHiRes and generate centroid data
 */

process pick_peaks {
    container params.docker_image_openms

    publishDir "${params.final_output_dir}/",
        mode: 'copy',
        pattern: "*.${params.output_format}",
        enabled: params.peak_picking_openms

    input:
        path msdata

    output:
        path centroid_msdata

    script:
    centroid_msdata = "${msdata.baseName}_centroid.mzML"
    """
    PeakPickerHiRes \
        -in ${msdata} \
        -out ${centroid_msdata} \
        -threads ${task.cpus}
    """
}
