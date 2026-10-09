# Pipeline tests

CSV-based integration tests load the trusted `test/csv_environment_expander.groovy` module, which expands `$NAME` and `${NAME}` references from the environment into a temporary CSV beneath `NXF_WORK`. The pipeline entry point is not involved in this expansion.

Copy `.env-template` to the ignored `.env` file and set the local test-data. Keep the pinned Nextflow version and v1 parser settings; the shared configuration modules are not yet compatible with the v2 parser that became the default in Nextflow 26.04.

```bash
bash test/run-nftest.sh test-integration-pwiz
```

An undefined variable referenced by a test CSV causes the test configuration
to fail with an explicit error.
