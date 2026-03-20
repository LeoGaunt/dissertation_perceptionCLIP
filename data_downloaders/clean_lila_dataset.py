#!/usr/bin/env python3
"""
clean_lila_dataset.py

Scans all images in the LILA dataset folder and removes any that PIL
cannot open (corrupted, truncated, or incomplete downloads).

Run this once after setup_lila_felidae.sh, and again if you ever
re-download or add images.

Usage:
    python3 clean_lila_dataset.py
    python3 clean_lila_dataset.py --dry-run        # preview only, don't delete
    python3 clean_lila_dataset.py --workers 8      # parallel scan (default: 8)
"""

import os
import argparse
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed
from PIL import Image

IMAGES_DIR = Path("/content/dissertation_perceptionCLIP/datasets/data/lila")
SUPPORTED_EXTS = {".jpg", ".jpeg", ".png", ".JPG", ".JPEG", ".PNG"}


def check_image(path: Path) -> tuple[Path, bool, str]:
    """Try to open and verify an image. Returns (path, is_ok, reason)."""
    try:
        with Image.open(path) as img:
            img.verify()  # catches truncated files
        return path, True, ""
    except Exception as e:
        return path, False, str(e)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run",  action="store_true", help="Report bad files without deleting")
    parser.add_argument("--workers",  type=int, default=8, help="Parallel scan threads")
    parser.add_argument("--images-dir", type=Path, default=IMAGES_DIR)
    args = parser.parse_args()

    images_dir = args.images_dir

    if not images_dir.exists():
        print(f"ERROR: Directory not found: {images_dir}")
        return

    # Collect all image files
    all_files = [
        p for p in images_dir.rglob("*")
        if p.is_file() and p.suffix in SUPPORTED_EXTS
    ]

    print(f"Scanning {len(all_files):,} images in {images_dir}")
    print(f"Dry run: {args.dry_run} | Workers: {args.workers}\n")

    bad_files = []
    checked = 0

    with ThreadPoolExecutor(max_workers=args.workers) as executor:
        futures = {executor.submit(check_image, p): p for p in all_files}
        for future in as_completed(futures):
            path, is_ok, reason = future.result()
            checked += 1
            if not is_ok:
                bad_files.append((path, reason))
                print(f"  BAD: {path.relative_to(images_dir)} — {reason}")
            if checked % 1000 == 0:
                print(f"  ... {checked:,}/{len(all_files):,} scanned, {len(bad_files)} bad so far")

    print(f"\nScan complete: {checked:,} checked, {len(bad_files)} corrupt/unreadable")

    if not bad_files:
        print("All images are clean.")
        return

    if args.dry_run:
        print("\nDry run — no files deleted. Re-run without --dry-run to remove them.")
        return

    print(f"\nDeleting {len(bad_files)} bad files...")
    deleted = 0
    for path, _ in bad_files:
        try:
            path.unlink()
            deleted += 1
        except Exception as e:
            print(f"  Could not delete {path}: {e}")

    print(f"Deleted {deleted} files.")
    print("\nDone. Re-run your inference script.")


if __name__ == "__main__":
    main()
