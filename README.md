# pipeline-convert-MSData

[![Prepare release](https://img.shields.io/badge/Action-Create%20New%20Release-blue)](https://github.com/TheBoutrosLab/pipeline-convert-MSData/actions/workflows/prepare-release.yaml)

- [pipeline-convert-MSData](#pipeline-convert-msdata)
  - [Overview](#overview)
  - [How To Run](#how-to-run)
  - [Pipeline Steps](#pipeline-steps)
  - [Inputs](#inputs)
    - [Input CSV](#input-csv)
    - [Config](#config)
  - [Outputs](#outputs)
  - [References](#references)
  - [License](#license)
## Overview

This pipeline converts between different data formats of mass spectrometry based proteomics studies. The input data can be either vendor specific raw data or other common file format such as mzML or mzXML. Vendor specific peak picking is supported. When the output format is mzML, it's possible to use OpenMS' peak picking algorithm [PeakPickerHiRes](https://abibuilder.informatik.uni-tuebingen.de/archive/openms/Documentation/nightly/html/TOPP_PeakPickerHiRes.html). The resulted centroid mzML files are then ready for downstream analysis such as library searching and/or quantification.

---

## How To Run

1. Download `source_code_with_submodules.tar.gz` from the [release assets](https://github.com/TheBoutrosLab/pipeline-convert-MSData/releases). This archive includes the pipeline's submodules.

    ```bash
    tar -xzf source_code_with_submodules.tar.gz
    ```

    You can also clone the repository with its submodules.

    ```bash
    git clone --recurse-submodules https://github.com/TheBoutrosLab/pipeline-convert-MSData.git
    ```

    For an existing Git checkout, run `git submodule update --init --recursive` from the repository root. Run the following steps from the directory containing `pipeline-convert-MSData/`.

2. Copy the ProteoWizard configuration and input CSV templates.

    ```bash
    cp pipeline-convert-MSData/config/template_pwiz.config run.config
    cp pipeline-convert-MSData/input/template_input.csv input.csv
    ```

    Edit `input.csv` with your sample names, fraction IDs, and input paths.
    Set `input_csv` and `output_dir` in `run.config` to your CSV path and desired
    output directory. Keep the `includeConfig` lines and `methods.setup()` call.
    For OpenMS conversion, use `config/template_openms.config` instead.

3. Use the supported Nextflow version and parser. These settings must be exported when launching Nextflow directly.

    ```bash
    export NXF_VER=24.10.6
    export NXF_SYNTAX_PARSER=v1
    ```

4. Run from the directory containing `pipeline-convert-MSData/` with your edited configuration. Choose the profile for your installed container runtime.

    ```bash
    nextflow run pipeline-convert-MSData/main.nf -c run.config -profile docker
    ```

    Use `apptainer` profile to use apptainer instead of docker.

    ```bash
    nextflow run pipeline-convert-MSData/main.nf -c run.config -profile apptainer
    ```

---

## Pipeline Steps

![alt text](img/flow-diagram.drawio.svg?raw=true)

The input MS data is converted using either msconvert from ProteoWizard, followed by a call to the `FileConverter` command from OpenMS (which can be turned off by setting `run_index` to `false`). This is to remove errors from files (e.g. the index), to update file formats to new versions, or to check whether information is lost upon reading or writing (see [here](https://abibuilder.informatik.uni-tuebingen.de/archive/openms/Documentation/nightly/html/TOPP_FileConverter.html)). For mzML, the `PeakPickerHiRes` command from OpenMS can used to convert it into centroid mzML as an alternative to the vendor specific peak picking. However only one pick picking algorithm should run.

This pipeline supports all file formats that OpenMS and ProteoWizard supports. For OpenMS, find the list of formats [here](https://abibuilder.informatik.uni-tuebingen.de/archive/openms/Documentation/nightly/html/TOPP_FileConverter.html), and for ProteoWizard [here](https://proteowizard.sourceforge.io/tools.shtml). The `PeakPickerHiRes` from OpenMS only supports output format as mzML.

---

## Inputs

### Input CSV

| Field  | Required | Description              |
| ------ | -------- | ------------------------ |
| `sample_name` | yes | Sample or plex name; used as an output directory. |
| `fraction_id` | yes | Fraction identifier; appended to every output basename if any sample has overlapping input basenames. |
| `path` | yes      | Path to the input MS file. |
| `scan` | no       | Path to the MS scan file. Required only when the input files are in Sciex WIFF format. |

Each `(sample_name, fraction_id)` pair must be unique in the CSV. Names and IDs
may contain letters, numbers, underscores, periods, and hyphens.

### Config

| Parameter  | Type | Description |
| ---------- | ---- | ----------- |
| `input_csv` | string(path) | Path to the input CSV file. |
| `output_dir` | string(path) | Path to the output directory. |
| `convert_algorithm` | string | The algorithm used for conversion. Must be either `OpenMS` or `ProteoWizard`. Defaults to `ProteoWizard`. |
| `output_format` | string | Output format, *e.g.* mzML, mzXML, mgf. |
| `peak_picking_vendor` | bool | Whether to use vendor peak picking. |
| `peak_picking_openms` | bool | Whether to run `PeakPickerHiRes`. |
| `pwiz_extra_args` | string | Extra arguments to be passed to `MSConvert` (*e.g.* '--zlib', '--zlib --64 --inten64'). |
| `ucla_cds` | bool | Compatibility flag required by the shared work-directory setup. Keep `false` outside the legacy UCLA-CDS environment. |
| `work_dir` | string(path) | Optional location for Nextflow intermediate files. |
| `base_resource_update` | namespace | Optional per-process CPU and memory multipliers applied to the default allocations. |
| `run_index` | bool | Whether to run the indexing step for the output file using OpenMS' `FileConverter` command to clean up and update file version. |

> [!NOTE]
> We recommend only one of `peak_picking_vendor` or `peak_picking_openms` to be set to true.

> [!WARNING]
> If the input raw files are in Sciex's WIFF format, `--ignoreUnknownInstrumentError` may have to be added to `pwiz_extra_args` to avoid error from ProteoWizard.

---

## Outputs

Final files are saved under `<output_dir>/convert-MSData-<version>/<sample_name>/<tool-version>/output/`. If input basenames are unique within every sample, each file retains its original basename: `LFQ_Orbitrap_AIF_Ecoli_01.raw` becomes `LFQ_Orbitrap_AIF_Ecoli_01.mzML`. If any sample contains overlapping input basenames, every file in the CSV receives a `_<fraction_id>` suffix, including files from other samples, so naming is consistent across the experiment. Indexing and peak picking retain the chosen basename. The pipeline rejects any remaining output-name collision. Downstream tools must recognize suffixed names when they occur. Pipeline logs for the whole run are stored under the timestamped `log-convert-MSData-*` directory at the version root.

---

## References

1. Röst et al. OpenMS: A flexible open-source software platform for mass spectrometry data analysis. *Nature Methods*, vol. 13, 2016. doi:10.1038/nmeth.3959
2. Weisser et al. An Automated Pipeline for High-Throughput Label-Free Quantitative Proteomics. *Journal of Proteome Research*, 2013, 12, 4, 1628–1644. doi.org/10.1021/pr300992u

---

## License

The code in pipeline-convert-MSData is licensed under the
BSD 3-Clause License (`BSD-3-Clause`). See [LICENSE](LICENSE) for the terms.

Shared code and third-party tools retain their respective licenses.

Copyright (C) 2026 Sanford Burnham Prebys Medical Discovery Institute ("Boutros Lab")
