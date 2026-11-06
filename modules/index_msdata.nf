/**
 * Module to create index
 */

process index_msdata {
    container params.docker_image_openms

    publishDir { "${params.final_output_dir}/${meta.sample_name}/${params.software_dir}/output" },
        mode: 'copy',
        pattern: "*.${params.output_format}",
        enabled: (!params.peak_picking_openms)

    publishDir { "${params.intermediate_file_dir}/${meta.sample_name}/${params.software_dir}/intermediate/${task.process.replace(':', '/')}" },
        mode: 'copy',
        pattern: "*.${params.output_format}",
        enabled: params.peak_picking_openms && params.save_intermediate_files

    input:
        tuple val(meta), path(msdata)

    output:
        tuple val(meta), path(indexed_msdata)

    script:
    indexed_msdata = "${msdata.baseName}_indexed.${params.output_format}"
    """
    FileConverter \
        -in ${msdata} \
        -out ${indexed_msdata} \
        -threads ${task.cpus}
    """
}
