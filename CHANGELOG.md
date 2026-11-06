# Changelog

All notable changes to `pipeline-convert-MSData` are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2026-11-06

### Added

- Support multiple samples and fractions in one CSV, with sample-specific output
  directories and fraction-prefixed filenames.

## [1.0.0] - 2026-10-09

### Added

- Reimplemented raw mass-spectrometry data conversion as an independently
  released Nextflow pipeline.
- Added conversion with ProteoWizard and OpenMS, including vendor-specific and
  OpenMS `PeakPickerHiRes` peak picking.
- Added optional mzML rewriting and indexing with OpenMS `FileConverter`.
- Added CSV input support for mass-spectrometry data and WIFF scan companion
  files, including early validation of required WIFF companions.
- Added configurable intermediate-file retention and pipeline run reports.
- Added Docker, Apptainer, and Singularity execution profiles.
- Added infrastructure-neutral resource allocation through the shared resource
  handler, including per-process resource multipliers.
- Added configuration templates for ProteoWizard and OpenMS workflows.
- Added NFTest integration cases for conversion, scan companions, indexing,
  and OpenMS peak picking.
- Added environment-variable expansion for integration-test CSV files and a
  Slurm scratch-directory test runner.
- Added pipeline metadata, parameter schema, documentation, and workflow diagram.

[1.0.0]: https://github.com/TheBoutrosLab/pipeline-convert-MSData/releases/tag/v1.0.0
[1.1.0]: https://github.com/TheBoutrosLab/pipeline-convert-MSData/compare/v1.0.0...v1.1.0
[unreleased]: https://github.com/TheBoutrosLab/pipeline-convert-MSData/compare/v1.1.0...HEAD
