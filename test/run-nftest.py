#!/usr/bin/env python3
"""Launch one pipeline integration test from the repository root."""

import argparse
import os
from pathlib import Path
import subprocess
import sys

import yaml
from dotenv import load_dotenv


def resolve_run_root(repo: Path, cluster: str) -> Path:
    """Apply the selected cluster's output layout."""
    root = Path(os.environ.get("NFT_RUN_ROOT") or str(repo)).expanduser()
    root = (repo / root).resolve()

    if cluster == "boutroslab_aws":
        job_id = os.environ.get("SLURM_JOB_ID")
        if not job_id:
            raise ValueError("boutroslab_aws requires SLURM_JOB_ID. Run inside a Slurm job.")
        root /= job_id

    return root


def prepare_config(repo: Path, test_case: str, test_dir: Path, cluster: str) -> Path:
    """Validate the test case and add the profiles needed on Pines."""
    config_path = repo / "nftest.yml"
    config = yaml.safe_load(config_path.read_text(encoding="utf-8"))
    matches = [case for case in config["cases"] if case["name"] == test_case]
    test_dir.mkdir(parents=True, exist_ok=True)
    if cluster == "pines":
        profiles = list(matches[0].get("profiles") or [])
        for profile in ("apptainer", "pines"):
            if profile not in profiles:
                profiles.append(profile)
        matches[0]["profiles"] = profiles
        config_path = test_dir / "nftest.yml"
        config_path.write_text(yaml.safe_dump(config, sort_keys=False), encoding="utf-8")

    return config_path


def run_test(repo: Path, test_case: str, root: Path, cluster: str) -> int:
    """Launch NFTest using this Python environment and return its exit status."""
    test_dir = root / ".nftest-temp" / test_case
    config_path = prepare_config(repo, test_case, test_dir, cluster)
    env = {
        **os.environ,
        "NFT_INIT": str(repo),
        "NFT_PIPELINE": str(repo),
        "NFT_TESTDIR": str(repo),
        "NFT_OUTPUT": str(root),
        "NFT_TEMP": str(test_dir),
    }
    print(f"Repository:  {repo}", flush=True)
    print(f"Test case:   {test_case}", flush=True)
    print(f"Cluster:     {cluster or 'default'}", flush=True)
    print(f"Work dir:    {test_dir}", flush=True)
    print(f"Output root: {root}", flush=True)

    result = subprocess.run(
        [sys.executable, "-m", "nftest", "run", "-c", config_path, test_case],
        cwd=test_dir,
        env=env,
    )
    return result.returncode if result.returncode >= 0 else 128 - result.returncode


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("test_case")
    args = parser.parse_args()

    repo = Path.cwd()
    load_dotenv(repo / ".env", override=True)
    cluster = os.environ.get("NFT_CLUSTER", "").strip()

    try:
        root = resolve_run_root(repo, cluster)
        return run_test(repo, args.test_case, root, cluster)
    except (ValueError, OSError, yaml.YAMLError) as error:
        parser.error(str(error))


if __name__ == "__main__":
    sys.exit(main())
