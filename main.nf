/**
 * Convert Raw MS data to centroid mzML data
 */

nextflow.enable.dsl = 2

include { convert_msdata_OpenMS } from "${projectDir}/modules/convert_msdata_OpenMS"
include { convert_msdata_ProteoWizard } from "${projectDir}/modules/convert_msdata_ProteoWizard"
include { index_msdata } from "${projectDir}/modules/index_msdata"
include { pick_peaks } from "${projectDir}/modules/pick_peaks"
include { print_prelogue; validate_input_format } from "${projectDir}/modules/common"

print_prelogue()

workflow {

    raw_ms = Channel.fromPath(params.input_csv).splitCsv(header:true).toList().flatMap { rows ->
        if (!rows || !(['sample_name', 'fraction_id', 'path'].every { rows[0].containsKey(it) })) {
            throw new IllegalArgumentException('Input CSV must contain sample_name, fraction_id, and path columns and at least one row')
        }

        def seen_fractions = [] as Set
        def validated_rows = rows.collect { row ->
            def sample_name = row.sample_name?.trim()
            def fraction_id = row.fraction_id?.trim()
            def input_path = row.path?.trim()
            if (!sample_name || !(sample_name ==~ /[A-Za-z0-9][A-Za-z0-9_.-]*/)) {
                throw new IllegalArgumentException("Invalid or missing sample_name in input CSV: ${row}")
            }
            if (!fraction_id || !(fraction_id ==~ /[A-Za-z0-9][A-Za-z0-9_.-]*/)) {
                throw new IllegalArgumentException("Invalid or missing fraction_id in input CSV: ${row}")
            }
            if (!input_path) {
                throw new IllegalArgumentException("Missing path in input CSV for ${sample_name}/${fraction_id}")
            }
            if (!seen_fractions.add([sample_name, fraction_id])) {
                throw new IllegalArgumentException("Duplicate sample_name/fraction_id in input CSV: ${sample_name}/${fraction_id}")
            }
            validate_input_format(input_path)
            def msdata = file(input_path)
            def scan_path = row.scan?.trim()
            if (msdata.extension.equalsIgnoreCase('wiff') && !scan_path) {
                throw new IllegalArgumentException("A scan companion file is required for WIFF input: ${input_path}")
            }
            [sample_name: sample_name, fraction_id: fraction_id, msdata: msdata,
             scan: scan_path ? file(scan_path) : file("${projectDir}/input/NO_SCAN")]
        }

        def basename_counts = validated_rows.countBy { [it.sample_name, it.msdata.baseName] }
        def suffix_all_fractions = basename_counts.values().any { it > 1 }
        def output_names = [] as Set
        validated_rows.collect { row ->
            def input_basename = row.msdata.baseName
            def output_basename = suffix_all_fractions
                ? "${input_basename}_${row.fraction_id}" : input_basename
            if (!output_names.add([row.sample_name, output_basename])) {
                throw new IllegalArgumentException("Duplicate output basename for ${row.sample_name}: ${output_basename}")
            }
            tuple([sample_name: row.sample_name, fraction_id: row.fraction_id,
                   output_basename: output_basename], row.msdata, row.scan)
        }
    }

    if (params.convert_algorithm == 'OpenMS') {
        convert_msdata_OpenMS(raw_ms)
        msdata = convert_msdata_OpenMS.out
    } else {
        convert_msdata_ProteoWizard(raw_ms)
        msdata = convert_msdata_ProteoWizard.out
    }

    if (params.run_index) {
        index_msdata(msdata)
    }

    if (params.peak_picking_openms) {
        if (params.run_index) {
            pick_peaks(index_msdata.out)
        } else {
            pick_peaks(msdata)
        }
    }
}
