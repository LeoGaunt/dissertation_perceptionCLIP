#!/usr/bin/env bash
# =============================================================================
# setup_lila_felidae.sh
#
# 1. Downloads the Felidae Conservation Fund metadata JSON from Azure
# 2. Parses the COCO Camera Traps JSON
# 3. Downloads up to LIMIT images per category directly via HTTPS
#    (no gsutil, no giant ZIP — individual image files only)
#
# Output structure:
#   /content/dissertation_perceptionCLIP/datasets/data/lila/
#       bobcat/
#       gray_fox/
#       mule_deer/
#       ...
#
#   /content/dissertation_perceptionCLIP/tmp/lila_metadata/
#       felidae_conservation_fund_2020_2025.json
#
# Requirements:
#   - python3, curl  (both pre-installed on Google Colab)
#   - No gsutil, no AzCopy, no ZIP required
#
# Usage:
#   bash setup_lila_felidae.sh              # default 200 images/category
#   bash setup_lila_felidae.sh 500          # override per-category limit
#   bash setup_lila_felidae.sh 200 4        # 200 images, 4 parallel workers
# =============================================================================

set -euo pipefail

# =============================================================================
# CONFIG
# =============================================================================

LIMIT="${1:-200}"    # Images per category
WORKERS="${2:-8}"    # Parallel download threads (increase if bandwidth allows)

# Metadata JSON (direct download, small file ~50MB)
METADATA_URL="https://lilawildlife.blob.core.windows.net/lila-wildlife/felidae-conservation-fund/felidae_conservation_fund_2020_2025.json"

# Base URL for individual image downloads
IMAGE_BASE_URL="https://lilawildlife.blob.core.windows.net/lila-wildlife/felidae-conservation-fund"

# Local paths
OUTPUT_DIR="/content/dissertation_perceptionCLIP/datasets/data/lila"
META_DIR="/content/dissertation_perceptionCLIP/tmp/lila_metadata"
JSON_FILE="${META_DIR}/felidae_conservation_fund_2020_2025.json"

# =============================================================================
# HELPERS
# =============================================================================

log()  { echo "[$(date '+%H:%M:%S')] $*"; }
info() { echo -e "\033[1;34m[INFO]\033[0m  $*"; }
ok()   { echo -e "\033[1;32m[ OK ]\033[0m  $*"; }
warn() { echo -e "\033[1;33m[WARN]\033[0m  $*"; }
err()  { echo -e "\033[1;31m[ERR ]\033[0m  $*" >&2; exit 1; }

check_deps() {
    info "Checking dependencies..."
    local missing=()
    for cmd in python3 curl; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done
    [[ ${#missing[@]} -gt 0 ]] && err "Missing required commands: ${missing[*]}"
    ok "All dependencies found."
}

# =============================================================================
# STEP 1 — Directories
# =============================================================================

setup_dirs() {
    info "Creating directories..."
    mkdir -p "$OUTPUT_DIR" "$META_DIR"
    ok "Directories ready."
}

# =============================================================================
# STEP 2 — Download metadata JSON
# =============================================================================

download_metadata() {
    info "Downloading metadata JSON..."

    if [[ -f "$JSON_FILE" ]]; then
        warn "JSON already exists at ${JSON_FILE}, skipping download."
        return
    fi

    curl --fail --show-error --location \
         --progress-bar \
         --output "$JSON_FILE" \
         "$METADATA_URL" \
    || err "Metadata download failed. Check the URL or your connection."

    ok "Downloaded metadata: ${JSON_FILE}"
}

# =============================================================================
# STEP 3 — Parse JSON and download images via HTTPS
# =============================================================================

download_images() {
    info "Parsing metadata and downloading images (limit: ${LIMIT}/category, workers: ${WORKERS})..."

    python3 - <<PYEOF
import json, os, re, sys
from pathlib import Path
from urllib.request import urlretrieve
from urllib.error import URLError, HTTPError
from concurrent.futures import ThreadPoolExecutor, as_completed
import threading

JSON_FILE      = "${JSON_FILE}"
OUTPUT_DIR     = "${OUTPUT_DIR}"
IMAGE_BASE_URL = "${IMAGE_BASE_URL}"
LIMIT          = int("${LIMIT}")
WORKERS        = int("${WORKERS}")

# ---- Load metadata ----------------------------------------------------------
print(f"  Loading {JSON_FILE} ...")
with open(JSON_FILE) as f:
    data = json.load(f)

categories = {c["id"]: c["name"] for c in data.get("categories", [])}
images     = {img["id"]: img["file_name"] for img in data.get("images", [])}

if not categories:
    sys.exit("ERROR: No categories found in JSON.")
if not images:
    sys.exit("ERROR: No images found in JSON.")

print(f"  Found {len(categories)} categories, {len(images)} images in metadata.")

# ---- Build deduplicated per-category image lists ----------------------------
cat_image_sets: dict[str, dict] = {name: {} for name in categories.values()}

for ann in data.get("annotations", []):
    cat_name = categories.get(ann.get("category_id"))
    img_id   = ann.get("image_id")
    img_path = images.get(img_id)
    if cat_name and img_id and img_path:
        cat_image_sets[cat_name][img_id] = img_path   # dedup by image_id

# ---- Build download task list -----------------------------------------------
# Each task: (url, destination_path)
tasks: list[tuple[str, Path]] = []

for cat_name, img_dict in cat_image_sets.items():
    if not img_dict:
        continue
    safe_name = re.sub(r"[^a-zA-Z0-9_\-]", "_", cat_name.strip().lower())
    cat_dir   = Path(OUTPUT_DIR) / safe_name
    cat_dir.mkdir(parents=True, exist_ok=True)

    # Skip categories already fully downloaded
    existing  = {f.name for f in cat_dir.iterdir() if f.is_file()}
    rel_paths = list(img_dict.values())[:LIMIT]
    needed    = [p for p in rel_paths if Path(p).name not in existing]

    if not needed:
        print(f"  [SKIP] '{cat_name}' — already complete ({len(existing)} images).")
        continue

    for rel_path in needed:
        url = IMAGE_BASE_URL.rstrip("/") + "/" + rel_path.lstrip("/")
        dst = cat_dir / Path(rel_path).name
        tasks.append((url, dst))

if not tasks:
    print("  Nothing to download — all categories already complete.")
    sys.exit(0)

print(f"  Queued {len(tasks)} images across {len(cat_image_sets)} categories.")
print(f"  Downloading with {WORKERS} parallel workers...\n")

# ---- Threaded download ------------------------------------------------------
lock          = threading.Lock()
completed     = 0
failed        = 0
total         = len(tasks)
REPORT_EVERY  = max(1, total // 20)   # print progress ~every 5%

def download_one(args: tuple[str, Path]) -> tuple[bool, str]:
    url, dst = args
    try:
        urlretrieve(url, dst)
        return True, ""
    except (HTTPError, URLError, OSError) as e:
        return False, f"{dst.name}: {e}"

with ThreadPoolExecutor(max_workers=WORKERS) as pool:
    futures = {pool.submit(download_one, t): t for t in tasks}
    for future in as_completed(futures):
        success, msg = future.result()
        with lock:
            if success:
                completed += 1
            else:
                failed += 1
                print(f"  [WARN] {msg}")
            done = completed + failed
            if done % REPORT_EVERY == 0 or done == total:
                pct = 100 * done // total
                print(f"  [{pct:3d}%] {done}/{total} done  "
                      f"({completed} ok, {failed} failed)")

print(f"\n  Download complete: {completed} succeeded, {failed} failed.")
PYEOF

    ok "Image downloads complete."
}

# =============================================================================
# STEP 4 — Summary
# =============================================================================

print_summary() {
    echo ""
    echo "============================================================"
    echo "  LILA Felidae Dataset — Setup Complete"
    echo "============================================================"
    echo "  Output dir : ${OUTPUT_DIR}"
    echo "  Limit      : ${LIMIT} images/category"
    echo ""
    echo "  Per-category image counts:"
    for cat_dir in "${OUTPUT_DIR}"/*/; do
        [[ -d "$cat_dir" ]] || continue
        local count
        count=$(find "$cat_dir" -maxdepth 1 -type f | wc -l)
        printf "    %-35s %d images\n" "$(basename "$cat_dir")" "$count"
    done
    echo "============================================================"
}

# =============================================================================
# MAIN
# =============================================================================

main() {
    echo ""
    echo "============================================================"
    echo "  LILA Felidae Conservation Fund — Dataset Setup"
    echo "  Per-category limit : ${LIMIT}"
    echo "  Parallel workers   : ${WORKERS}"
    echo "============================================================"
    echo ""

    check_deps
    setup_dirs
    download_metadata
    download_images
    print_summary
}

main "$@"