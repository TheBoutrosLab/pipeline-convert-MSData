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

1. Create a `.config` using this template [here](config/template_pwiz.config) for ProteoWizard and this template [here](config/template_openms.config) for OpenMS.

2. Create an input CSV file using the template [here](input/template_input.csv)

3. Run the pipeline with Nextflow, for example:

   ```bash
   nextflow run TheBoutrosLab/pipeline-convert-MSData -r <version> -c config/template_pwiz.config
   ```

   The supplied configuration templates default to Docker. Use `-profile apptainer` or `-profile singularity` when appropriate for the execution environment.

> :warning: We recommend running one sample or plex at a time because all outputs from a run share the same destination directory.

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
| `path` | yes      | Path to the input MS file. |
| `scan` | no       | Path to the MS scan file. Required only when the input files are in Sciex WIFF format. |

### Config

| Parameter  | Type | Description |
| ---------- | ---- | ----------- |
| `input_csv` | string(path) | Path to the input CSV file. |
| `output_dir` | string(path) | Path to the output directory. |
| `sample_id` | string | Sample or plex (for TMT) name. |
| `convert_algorithm` | string | The algorithm used for conversion. Must be either `OpenMS` or `ProteoWizard`. Defaults to `ProteoWizard`. |
| `output_format` | string | Output format, *e.g.* mzML, mzXML, mgf. |
| `peak_picking_vendor` | bool | Whether to use vendor peak picking. |
| `peak_picking_openms` | bool | Whether to run `PickPeaksHiRes`. |
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

The output files depend on the selected input and output formats. Final files are saved under `<output_dir>/convert-MSData-<version>/<sample_id>/<tool-version>/output/`. Pipeline and process logs are stored in the corresponding timestamped `log-convert-MSData-*` directory.

---

## References

1. Röst et al. OpenMS: A flexible open-source software platform for mass spectrometry data analysis. *Nature Methods*, vol. 13, 2016. doi:10.1038/nmeth.3959
2. Weisser et al. An Automated Pipeline for High-Throughput Label-Free Quantitative Proteomics. *Journal of Proteome Research*, 2013, 12, 4, 1628–1644. doi.org/10.1021/pr300992u

---

## License

pipeline-convert-MSData is licensed under the GNU General Public License version 2. See [LICENSE](LICENSE) for the terms of the GNU GPL license.

pipeline-convert-MSData

Convert between different file formats of mass spectrometry based proteomics studies.

Copyright (C) 2026 Sanford Burnham Prebys Medical Discovery Institute ("Boutros Lab")

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
