#!/usr/bin/env python3
import filecmp
import shutil
import sys
from pathlib import Path


def fail(message: str) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    sys.exit(1)


def read_manifest(manifest_path: Path) -> list[str]:
    if not manifest_path.exists():
        fail(f"Manifest not found: {manifest_path}")

    entries: list[str] = []
    for line in manifest_path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        entries.append(line)

    return entries


def files_equal(src: Path, dst: Path) -> bool:
    return src.exists() and dst.exists() and filecmp.cmp(src, dst, shallow=False)


def copy_file(src: Path, dst: Path) -> None:
    dst.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(src, dst)


def sync_directory(src_dir: Path, dst_dir: Path, copied: list[str], skipped: list[str], conflicts: list[str]) -> None:
    src_paths: set[Path] = set()
    for src_file in sorted(src_dir.rglob("*")):
        if src_file.is_dir():
            continue

        relative = src_file.relative_to(src_dir)
        src_paths.add(relative)
        dst_file = dst_dir / relative

        if not dst_file.exists():
            copy_file(src_file, dst_file)
            copied.append(str(dst_file.relative_to(Path.cwd())))
            continue

        if files_equal(src_file, dst_file):
            skipped.append(str(dst_file.relative_to(Path.cwd())))
            continue

        conflicts.append(str(dst_file.relative_to(Path.cwd())))

    if dst_dir.exists():
        for dst_file in sorted(dst_dir.rglob("*")):
            if dst_file.is_dir():
                continue

            relative = dst_file.relative_to(dst_dir)
            if relative not in src_paths:
                conflicts.append(str(dst_file.relative_to(Path.cwd())))


def sync_file(src_file: Path, dst_file: Path, copied: list[str], skipped: list[str], conflicts: list[str]) -> None:
    if not dst_file.exists():
        copy_file(src_file, dst_file)
        copied.append(str(dst_file.relative_to(Path.cwd())))
        return

    if files_equal(src_file, dst_file):
        skipped.append(str(dst_file.relative_to(Path.cwd())))
        return

    conflicts.append(str(dst_file.relative_to(Path.cwd())))


def main() -> int:
    repo_root = Path.cwd()
    shared_root = Path("/tmp/agentic-shared")
    manifest_path = shared_root / "manifests" / "agentic-coding.txt"

    manifest = read_manifest(manifest_path)
    copied: list[str] = []
    skipped: list[str] = []
    conflicts: list[str] = []

    for entry in manifest:
        src_path = shared_root / entry
        dst_path = repo_root / entry

        if not src_path.exists():
            fail(f"Missing manifest asset in agentic-shared: {entry}")

        if src_path.is_dir():
            sync_directory(src_path, dst_path, copied, skipped, conflicts)
            continue

        sync_file(src_path, dst_path, copied, skipped, conflicts)

    conflict_marker = repo_root / "agentic-shared-conflicts.txt"
    if conflicts:
        conflict_marker.write_text(
            "The following synced files differ between agentic-shared and this repository:\n\n"
            + "\n".join(conflicts)
            + "\n\n"
            + "These files were not overwritten. Please review the shared upstream version and merge manually if needed.",
            encoding="utf-8",
        )
        copied.append(str(conflict_marker.relative_to(repo_root)))
    elif conflict_marker.exists():
        conflict_marker.unlink()
        copied.append(str(conflict_marker.relative_to(repo_root)))

    print(f"Copied files: {len(copied)}")
    print(f"Skipped files: {len(skipped)}")
    print(f"Conflict files: {len(conflicts)}")

    if conflicts:
        print("WARNING: Some shared files differ from the current repository and were not overwritten.")
        print("A conflict marker file has been written to agentic-shared-conflicts.txt.")

    if not copied and not conflicts:
        print("No shared files were copied or changed.")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
