/**
 * Module to create index
 */

process index_msdata {
    container params.docker_image_openms

    publishDir "${params.final_output_dir}/",
        mode: 'copy',
        pattern: "*.${params.output_format}",
        enabled: (!params.peak_picking_openms)

    publishDir "${params.intermediate_file_dir}/${task.process.replace(':', '/')}/",
        mode: 'copy',
        pattern: "*.${params.output_format}",
        enabled: params.peak_picking_openms && params.save_intermediate_files

    input:
        path msdata

    output:
        path indexed_msdata

    script:
    indexed_msdata = "${msdata.baseName}_indexed.${params.output_format}"
    """
    FileConverter \
        -in ${msdata} \
        -out ${indexed_msdata} \
        -threads ${task.cpus}
    """
}
