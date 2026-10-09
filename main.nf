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

    raw_ms = Channel.fromPath(params.input_csv).splitCsv(header:true).map{
        validate_input_format(it.path)
        msdata = file(it.path)
        scan_path = it.scan?.trim()
        if (msdata.extension.equalsIgnoreCase('wiff') && !scan_path) {
            throw new Exception("A scan companion file is required for WIFF input: ${it.path}")
        }
        scan = scan_path ? file(scan_path) : file("${projectDir}/input/NO_SCAN")
        return tuple(msdata, scan)
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
