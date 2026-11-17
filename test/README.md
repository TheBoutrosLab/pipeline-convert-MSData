# Pipeline tests

The integration CSVs use `sample_name,fraction_id,path` and an optional `scan`
column for WIFF inputs. The WIFF test includes two samples to exercise
sample-specific output directories.

CSV-based integration tests load the trusted `test/csv_environment_expander.groovy` module, which expands `$NAME` and `${NAME}` references from the environment into a temporary CSV beneath `NXF_WORK`. The pipeline entry point is not involved in this expansion.

Copy `.env-template` to the ignored `.env` file and set `TEST_DATA_DIR` to the
directory containing `ecoli_lfq/` and `ecoli_swath/`. Keep the pinned Nextflow
version and v1 parser settings; the shared configuration modules are not yet
compatible with the v2 parser that became the default in Nextflow 26.04.

Set `NFT_CLUSTER` in `.env` to `boutroslab_aws` or `pines`, or leave it unset
to use the normal test profiles. Only `boutroslab_aws` requires a Slurm job ID.
All runs use `NFT_RUN_ROOT` as their base directory. Relative paths are resolved
against the pipeline repository root. If it is unset, the base
defaults to the launch directory for every cluster. With no cluster selected,
no job ID directory is added. Unknown cluster names cause an explicit error.
For Pines, set
`NFT_RUN_ROOT=/data/labs/boutros_lab/czhu/pipeline_test_scratch` (or another
writable shared directory). On Blarc, the effective run root is
`$NFT_RUN_ROOT/$SLURM_JOB_ID`; on Pines, it is exactly `$NFT_RUN_ROOT`.
NFTest places final pipeline results under `<run-root>/<test-case>/`, logs under
`<run-root>/`, and temporary Nextflow files under
`<run-root>/.nftest-temp/<test-case>/work/`. Pines tests use the `apptainer` and
`pines` Nextflow profiles automatically.

```bash
python3 test/run-nftest.py test-integration-pwiz
```

An undefined variable referenced by a test CSV causes the test configuration
to fail with an explicit error.
