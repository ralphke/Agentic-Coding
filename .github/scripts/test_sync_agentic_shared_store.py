#!/usr/bin/env python3
"""Tests for resolving and checking out registered OpenSpec stores."""

from __future__ import annotations

import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

import yaml

from sync_agentic_shared import (
    checkout_store_revision,
    main,
    resolve_store_root,
)
from validate_agentic_shared_manifest import (
    ManifestValidationError,
    validate_manifest,
)


class OpenSpecStoreResolutionTests(unittest.TestCase):
    def test_manifest_accepts_registered_store_id(self) -> None:
        manifest = {
            "source": {
                "repository": "ralphke/agentic-shared",
                "store_id": "agentic-shared",
                "version": "v1.1.1",
            },
            "assets": {"skills": "managed"},
        }

        self.assertEqual(validate_manifest(manifest), manifest)

    def test_manifest_rejects_invalid_store_id(self) -> None:
        manifest = {
            "source": {
                "repository": "ralphke/agentic-shared",
                "store_id": "../other-store",
                "version": "v1.1.1",
            },
            "assets": {"skills": "managed"},
        }

        with self.assertRaisesRegex(ManifestValidationError, "source.store_id"):
            validate_manifest(manifest)

    def test_resolves_store_id_and_checks_repository_origin(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            store_root = Path(directory)
            context = {
                "root": {
                    "path": str(store_root),
                    "store_id": "agentic-shared",
                }
            }
            responses = [
                subprocess.CompletedProcess(
                    args=[], returncode=0, stdout=json.dumps(context), stderr=""
                ),
                subprocess.CompletedProcess(
                    args=[],
                    returncode=0,
                    stdout="https://github.com/ralphke/agentic-shared.git\n",
                    stderr="",
                ),
            ]

            with patch("sync_agentic_shared.subprocess.run", side_effect=responses) as run:
                resolved = resolve_store_root(
                    "agentic-shared", "ralphke/agentic-shared"
                )

            self.assertEqual(resolved, store_root)
            self.assertEqual(run.call_args_list[0].args[0][-2:], ["--store", "agentic-shared"])

    def test_rejects_store_with_different_origin(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            store_root = Path(directory)
            context = {
                "root": {
                    "path": str(store_root),
                    "store_id": "agentic-shared",
                }
            }
            responses = [
                subprocess.CompletedProcess(
                    args=[], returncode=0, stdout=json.dumps(context), stderr=""
                ),
                subprocess.CompletedProcess(
                    args=[],
                    returncode=0,
                    stdout="https://github.com/another/project.git\n",
                    stderr="",
                ),
            ]

            with patch("sync_agentic_shared.subprocess.run", side_effect=responses):
                with self.assertRaisesRegex(ValueError, "not 'ralphke/agentic-shared'"):
                    resolve_store_root("agentic-shared", "ralphke/agentic-shared")

    def test_checkouts_tag_without_changing_store_checkout(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            store_root = root / "store"
            store_root.mkdir()
            old_checkout = root / "old"
            new_checkout = root / "new"

            def git(*args: str) -> None:
                subprocess.run(
                    ["git", *args],
                    cwd=store_root,
                    check=True,
                    capture_output=True,
                    text=True,
                )

            git("init", "--quiet")
            git("config", "user.name", "OpenSpec test")
            git("config", "user.email", "openspec-test@example.invalid")
            asset = store_root / ".github" / "skills" / "sample.md"
            asset.parent.mkdir(parents=True)
            asset.write_text("old", encoding="utf-8")
            git("add", ".")
            git("commit", "--quiet", "-m", "old release")
            git("tag", "v1.0.0")
            asset.write_text("new", encoding="utf-8")
            git("commit", "--quiet", "-am", "new release")
            git("tag", "v1.1.0")

            checkout_store_revision(store_root, "v1.0.0", old_checkout)
            checkout_store_revision(store_root, "v1.1.0", new_checkout)

            relative = Path(".github/skills/sample.md")
            self.assertEqual((old_checkout / relative).read_text(encoding="utf-8"), "old")
            self.assertEqual((new_checkout / relative).read_text(encoding="utf-8"), "new")
            self.assertEqual((store_root / relative).read_text(encoding="utf-8"), "new")

    def test_explicit_release_checkouts_work_with_manifest_store_id(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            old_source = root / "old"
            new_source = root / "new"
            destination = root / "destination"
            manifest_path = root / ".agentic-shared.yml"
            relative = ".github/skills/shared.md"
            old_file = old_source / relative
            new_file = new_source / relative
            destination_file = destination / relative
            old_file.parent.mkdir(parents=True)
            new_file.parent.mkdir(parents=True)
            destination_file.parent.mkdir(parents=True)
            old_file.write_text("old", encoding="utf-8")
            new_file.write_text("new", encoding="utf-8")
            destination_file.write_text("old", encoding="utf-8")
            manifest = {
                "source": {
                    "repository": "ralphke/agentic-shared",
                    "store_id": "agentic-shared",
                    "version": "v1.0.0",
                },
                "assets": {"skills": "managed"},
                "protected_paths": [],
            }
            manifest_path.write_text(yaml.safe_dump(manifest), encoding="utf-8")
            argv = [
                "sync_agentic_shared.py",
                "--manifest",
                str(manifest_path),
                "--old-source",
                str(old_source),
                "--new-source",
                str(new_source),
                "--destination",
                str(destination),
                "--target-version",
                "v1.1.0",
            ]

            with patch.object(sys, "argv", argv), patch(
                "sync_agentic_shared.resolve_store_root",
                side_effect=AssertionError("remote mode must not resolve a local store"),
            ):
                result = main()

            updated_manifest = yaml.safe_load(manifest_path.read_text(encoding="utf-8"))
            self.assertEqual(result, 0)
            self.assertEqual(destination_file.read_text(encoding="utf-8"), "new")
            self.assertEqual(updated_manifest["source"]["version"], "v1.1.0")


if __name__ == "__main__":
    unittest.main()