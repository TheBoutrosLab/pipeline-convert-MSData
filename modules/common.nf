/**
 * Common groovy functions
 */

VALID_INPUT_FORMAT_OPENMS = [
    'mzML', 'mzXML', 'mgf', 'raw', 'cachedMzML', 'mzData', 'dta', 'dta2d', 'featureXML',
    'consensusXML', 'ms2', 'fid', 'tsv', 'peplist', 'kroenik', 'edta'
]
VALID_INPUT_FORMAT_PWIZ = [
    'mzML', 'mzXML', 'mgf', 'ms2', 'mzIdentML', 't2d', 'd', 'raw', 'tep', 'wiff', 'lcd', 'wiff2'
]

/**
 * Print prelogue message.
 */
def print_prelogue() {
    log.info """\
    =============================================
    P I P E L I N E - C O N V E R T - M S D A T A
    =============================================
    Boutros Lab

    Current Configuration:
    - pipeline:
        name: ${workflow.manifest.name}
        version: ${workflow.manifest.version}

    - input:
        input input_csv: ${params.input_csv}

    - output:
        output_dir: ${params.output_dir}

    - options:
        output_format: ${params.output_format}
        peak_picking_vendor: ${params.peak_picking_vendor}
        peak_picking_openms: ${params.peak_picking_openms}
        save_intermediate_files: ${params.save_intermediate_files}
        convert_algorithm: ${params.convert_algorithm}

    Tools Used:
        OpenMS: ${params.docker_image_openms}
        ProteoWizard: ${params.docker_image_pwiz}

    ------------------------------------
    Starting workflow...
    ------------------------------------
    """
    .stripIndent()
}

/**
 * Check wehether the input file format is valid
 */
def validate_input_format(String path) {
    format = file(path).extension
    if (params.convert_algorithm == 'OpenMS') {
        if (!(format in VALID_INPUT_FORMAT_OPENMS)) {
            throw new Exception("Input file format ${format} not supported by OpenMS")
        }
    } else {
        if (!(format in VALID_INPUT_FORMAT_PWIZ)) {
            throw new Exception("Input file format ${format} not supported by ProteoWizard")
        }
    }
}
