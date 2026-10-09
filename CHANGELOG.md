# Changelog

All notable changes to the pipeline-convert-MSData pipeline.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Changed

- Migrate the pipeline from the UCLA repository into the Sanford Burnham Prebys pipeline template.
- Adopt the current shared Nextflow configuration, logging, and container profiles.
- Replace legacy node-specific resource configs with the shared resource handler and an infrastructure-neutral default profile.
- Retain `ucla_cds = false` as a compatibility parameter required by the shared work-directory setup.

---

## [1.1.0] - 2024-05-13

### Changed

- Update config files to follow UCLA-CDS standards.

- Docker images are transferred from DockerHub to GitHub.

## [1.0.0] - 2022-03-21

### Added

- Config parameter `pwiz_extra_args` added to accept extra arguments to msconvert

- F2 node specific config file added.

- ProteoWizard specific config template added.

### Changed

- Output directory updated to follow UCLA-CDS standard

- Allowed skipping indexing if OpenMS' `PeakPickerHiRes` is not used.

- Default is set to use vendor specific peak picking for both algorithms. #25

- OpenMS version updated to 2.8.0 #33

---

## [1.0.0-rc1] - 2021-10-25

### Added

- Initial draft of the pipeline added. Using OpenMS and ProteoWizard to convert Raw data to centroid mzML.
