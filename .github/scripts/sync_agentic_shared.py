#!/usr/bin/env python3
"""Synchronize declared shared assets while preserving consumer extensions."""

from __future__ import annotations

import argparse
import fnmatch
import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Iterable

import yaml

from validate_agentic_shared_manifest import (
    ManifestValidationError,
    validate_manifest,
)

ASSET_ROOTS = {
    "agents": Path(".github/agents"),
    "skills": Path(".github/skills"),
    "prompts": Path(".github/prompts"),
    "instructions": Path(".github/instructions"),
    "workflows": Path(".github/workflows"),
    "issue_templates": Path(".github/ISSUE_TEMPLATE"),
    "specs": Path("openspec"),
}


class SyncConflictError(RuntimeError):
    """Raised when a managed consumer file cannot be updated safely."""


def resolve_store_root(store_id: str, expected_repository: str) -> Path:
    """Resolve a registered OpenSpec store and verify its upstream repository."""
    openspec_command = ["openspec", "context", "--json", "--store", store_id]
    if os.name == "nt":
        openspec_command = ["cmd.exe", "/c", *openspec_command]
    result = subprocess.run(
        openspec_command,
        check=True,
        capture_output=True,
        text=True,
    )
    context = json.loads(result.stdout)
    root = context.get("root", {})
    if root.get("store_id") != store_id:
        raise ValueError(f"OpenSpec resolved a different store than {store_id!r}")

    root_path = root.get("path")
    if not isinstance(root_path, str) or not root_path:
        raise ValueError(f"OpenSpec did not return a path for store {store_id!r}")
    store_root = Path(root_path)
    if not store_root.is_dir():
        raise ValueError(f"OpenSpec store path does not exist: {store_root}")

    remote_result = subprocess.run(
        ["git", "-C", str(store_root), "remote", "get-url", "origin"],
        check=True,
        capture_output=True,
        text=True,
    )
    remote = remote_result.stdout.strip()
    for prefix in ("https://github.com/", "http://github.com/", "git@github.com:"):
        if remote.startswith(prefix):
            remote = remote[len(prefix):]
            break
    else:
        raise ValueError(f"OpenSpec store has an unsupported origin URL: {remote}")
    remote = remote.removesuffix(".git").strip("/")
    if remote.casefold() != expected_repository.casefold():
        raise ValueError(
            f"OpenSpec store {store_id!r} points to {remote!r}, "
            f"not {expected_repository!r}"
        )
    return store_root


def checkout_store_revision(store_root: Path, revision: str, destination: Path) -> None:
    """Create an isolated temporary checkout of a store revision."""
    subprocess.run(
        ["git", "clone", "--quiet", "--shared", "--no-checkout", str(store_root), str(destination)],
        check=True,
        capture_output=True,
        text=True,
    )
    subprocess.run(
        ["git", "-C", str(destination), "checkout", "--quiet", "--detach", revision],
        check=True,
        capture_output=True,
        text=True,
    )


def _is_protected(path: Path, protected_patterns: Iterable[str]) -> bool:
    normalized = path.as_posix()
    return any(fnmatch.fnmatch(normalized, pattern) for pattern in protected_patterns)


def _relative_files(root: Path, asset_root: Path) -> set[Path]:
    directory = root / asset_root
    if not directory.exists():
        return set()
    return {
        path.relative_to(root)
        for path in directory.rglob("*")
        if path.is_file()
    }


def _same_file(left: Path, right: Path) -> bool:
    if not left.exists() or not right.exists():
        return False
    left_content = left.read_bytes().replace(b"\r\n", b"\n").replace(b"\r", b"\n")
    right_content = right.read_bytes().replace(b"\r\n", b"\n").replace(b"\r", b"\n")
    return left_content == right_content


def merge_three_way(
    local_path: Path,
    base_path: Path,
    upstream_path: Path,
) -> tuple[bool, bytes]:
    """Merge local and upstream changes against their base using Git merge-file."""
    local_content = local_path.read_bytes()
    base_content = base_path.read_bytes()
    upstream_content = upstream_path.read_bytes()
    newline = b"\r\n" if b"\r\n" in local_content else b"\n"

    with tempfile.TemporaryDirectory(prefix="agentic-shared-merge-") as temp_dir:
        temp = Path(temp_dir)
        local_temp = temp / "local"
        base_temp = temp / "base"
        upstream_temp = temp / "upstream"

        local_temp.write_bytes(local_content.replace(b"\r\n", b"\n").replace(b"\r", b"\n"))
        base_temp.write_bytes(base_content.replace(b"\r\n", b"\n").replace(b"\r", b"\n"))
        upstream_temp.write_bytes(
            upstream_content.replace(b"\r\n", b"\n").replace(b"\r", b"\n")
        )

        result = subprocess.run(
            [
                "git",
                "merge-file",
                "--diff3",
                "-p",
                str(local_temp),
                str(base_temp),
                str(upstream_temp),
            ],
            check=False,
            capture_output=True,
        )
        if result.returncode == 255:
            detail = result.stderr.decode("utf-8", errors="replace").strip()
            raise RuntimeError(
                detail
                or f"git merge-file failed with exit code {result.returncode}"
            )

        merged_content = result.stdout.replace(b"\r\n", b"\n").replace(b"\r", b"\n")
        if newline == b"\r\n":
            merged_content = merged_content.replace(b"\n", b"\r\n")
        return result.returncode == 0, merged_content


def synchronize(
    manifest: dict,
    old_root: Path,
    new_root: Path,
    destination_root: Path,
    target_version: str,
    force: bool = False,
) -> list[Path]:
    """Apply a three-way sync and return changed destination paths."""
    protected_patterns = manifest.get("protected_paths", [])
    conflicts: list[Path] = []
    operations: list[tuple[str, Path, Path | bytes | None]] = []

    for asset_group, ownership_mode in manifest["assets"].items():
        if ownership_mode == "local":
            continue

        asset_root = ASSET_ROOTS[asset_group]
        candidate_paths = (
            _relative_files(old_root, asset_root)
            | _relative_files(new_root, asset_root)
        )

        for relative_path in sorted(candidate_paths):
            if _is_protected(relative_path, protected_patterns):
                continue

            old_path = old_root / relative_path
            new_path = new_root / relative_path
            destination_path = destination_root / relative_path
            old_exists = old_path.exists()
            new_exists = new_path.exists()
            destination_exists = destination_path.exists()

            if not old_exists:
                if new_exists:
                    if not destination_exists:
                        operations.append(("copy", destination_path, new_path))
                    elif not _same_file(destination_path, new_path):
                        if force:
                            operations.append(("copy", destination_path, new_path))
                        else:
                            conflicts.append(relative_path)
                continue

            if old_exists and not destination_exists:
                if new_exists:
                    if force:
                        operations.append(("copy", destination_path, new_path))
                    else:
                        conflicts.append(relative_path)
                continue

            if not new_exists:
                if not destination_exists:
                    continue
                if _same_file(destination_path, old_path):
                    operations.append(("delete", destination_path, None))
                elif force:
                    operations.append(("delete", destination_path, None))
                else:
                    conflicts.append(relative_path)
                continue

            # The upstream version did not change. Preserve the consumer edit.
            if _same_file(new_path, old_path):
                continue

            # The consumer version did not change. Apply the upstream version.
            if _same_file(destination_path, old_path):
                operations.append(("copy", destination_path, new_path))
                continue

            # Both sides changed. Merge them when the hunks are independent.
            if destination_exists:
                if force:
                    operations.append(("copy", destination_path, new_path))
                else:
                    merged, merged_content = merge_three_way(
                        destination_path,
                        old_path,
                        new_path,
                    )
                    if merged:
                        if merged_content != destination_path.read_bytes():
                            operations.append(("write", destination_path, merged_content))
                    else:
                        if merged_content != destination_path.read_bytes():
                            operations.append(("write", destination_path, merged_content))
                        conflicts.append(relative_path)
                continue

            operations.append(("copy", destination_path, new_path))

    changed_paths: list[Path] = []
    for operation, destination_path, source_path in operations:
        if operation == "delete":
            destination_path.unlink()
        elif operation == "write":
            if not isinstance(source_path, bytes):
                raise RuntimeError("write operation is missing its content")
            destination_path.parent.mkdir(parents=True, exist_ok=True)
            destination_path.write_bytes(source_path)
        else:
            if not isinstance(source_path, Path):
                raise RuntimeError("copy operation is missing its source path")
            destination_path.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(source_path, destination_path)
        changed_paths.append(destination_path.relative_to(destination_root))

    if conflicts:
        paths = "\n".join(f"- {path.as_posix()}" for path in conflicts)
        raise SyncConflictError(
            "managed synchronization conflicts detected; clean hunks were applied and "
            "conflict markers were written:\n"
            + paths
        )

    manifest["source"]["version"] = target_version
    return changed_paths


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", type=Path, default=Path(".agentic-shared.yml"))
    parser.add_argument("--store", help="registered OpenSpec store ID for local sync")
    parser.add_argument("--old-source", type=Path)
    parser.add_argument("--new-source", type=Path)
    parser.add_argument("--destination", type=Path, default=Path("."))
    parser.add_argument("--target-version", required=True)
    parser.add_argument(
        "--force",
        action="store_true",
        help="overwrite managed files with conflicts using the target release",
    )
    args = parser.parse_args()

    try:
        with args.manifest.open(encoding="utf-8") as manifest_file:
            manifest = yaml.safe_load(manifest_file)
        validate_manifest(manifest)

        if args.store and manifest["source"].get("store_id") not in (None, args.store):
            raise ValueError(
                f"--store {args.store!r} does not match manifest store_id "
                f"{manifest['source']['store_id']!r}"
            )

        if bool(args.old_source) != bool(args.new_source):
            raise ValueError("--old-source and --new-source must be provided together")
        if args.store and (args.old_source or args.new_source):
            raise ValueError("--store cannot be combined with --old-source or --new-source")

        use_store = not (args.old_source or args.new_source)
        if use_store:
            store_id = args.store or manifest["source"].get("store_id")
            if not store_id:
                raise ValueError(
                    "provide --store or both --old-source and --new-source"
                )
            store_root = resolve_store_root(store_id, manifest["source"]["repository"])
            with tempfile.TemporaryDirectory(prefix="agentic-shared-sync-") as temp_dir:
                old_source = Path(temp_dir) / "old"
                new_source = Path(temp_dir) / "new"
                checkout_store_revision(store_root, manifest["source"]["version"], old_source)
                checkout_store_revision(store_root, args.target_version, new_source)
                changed_paths = synchronize(
                    manifest,
                    old_source,
                    new_source,
                    args.destination,
                    args.target_version,
                    args.force,
                )
        else:
            changed_paths = synchronize(
                manifest,
                args.old_source,
                args.new_source,
                args.destination,
                args.target_version,
                args.force,
            )

        with args.manifest.open("w", encoding="utf-8", newline="\n") as manifest_file:
            yaml.safe_dump(manifest, manifest_file, sort_keys=False)
    except FileNotFoundError as error:
        print(f"Required path not found: {error.filename}", file=sys.stderr)
        return 1
    except (ManifestValidationError, SyncConflictError, ValueError, json.JSONDecodeError) as error:
        print(f"Sync failed: {error}", file=sys.stderr)
        return 1
    except subprocess.CalledProcessError as error:
        detail = error.stderr.strip() if error.stderr else str(error)
        print(f"Sync failed: {detail}", file=sys.stderr)
        return 1

    print(f"Synchronized {len(changed_paths)} path(s) to {args.target_version}.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
