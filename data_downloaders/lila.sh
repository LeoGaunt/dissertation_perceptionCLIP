#!/usr/bin/env bash
# =============================================================================
# setup_lila_felidae.sh
#
# 1. Downloads the Felidae Conservation Fund images ZIP from Azure
# 2. Extracts all images into a flat tmp directory
# 3. Parses the bundled metadata JSON
# 4. Copies up to LIMIT images per category into named output folders
#
# Output structure:
#   /content/dissertation_perceptionCLIP/datasets/data/lila/
#       bobcat/
#       gray_fox/
#       mule_deer/
#       ...
#
#   /content/dissertation_perceptionCLIP/tmp/lila_images/
#       <raw extracted images>   <- deleted after sorting if --clean passed
#
# Requirements:
#   - python3, curl, unzip  (all pre-installed on Google Colab)
#   - No gsutil required
#
# Usage:
#   bash setup_lila_felidae.sh              # default 200 images/category
#   bash setup_lila_felidae.sh 500          # override per-category limit
#   bash setup_lila_felidae.sh 500 --clean  # also delete tmp after sorting
# =============================================================================

set -euo pipefail

# =============================================================================
# CONFIG
# =============================================================================

LIMIT="${1:-200}"
CLEAN="${2:-}"   # pass --clean to remove tmp images dir after sorting

# Single ZIP containing both images and metadata JSON
ZIP_URL="https://lilawildlife.blob.core.windows.net/lila-wildlife/felidae-conservation-fund/felidae_conservation_fund_2020_2025.zip"

# Local paths
OUTPUT_DIR="/content/dissertation_perceptionCLIP/datasets/data/lila"
TMP_DIR="/content/dissertation_perceptionCLIP/tmp/lila_images"
META_DIR="/content/dissertation_perceptionCLIP/tmp/lila_metadata"
IMAGES_ZIP="${META_DIR}/felidae_conservation_fund_2020_2025.zip"
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
    for cmd in python3 curl unzip; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done
    [[ ${#missing[@]} -gt 0 ]] && err "Missing required commands: ${missing[*]}"
    ok "All dependencies found (no gsutil needed)."
}

# =============================================================================
# STEP 1 — Directories
# =============================================================================

setup_dirs() {
    info "Creating directories..."
    mkdir -p "$OUTPUT_DIR" "$TMP_DIR" "$META_DIR"
    ok "Directories ready."
}

# =============================================================================
# STEP 2 — Download & extract the ZIP
# =============================================================================

download_and_extract() {
    info "Downloading images ZIP..."

    if [[ ! -f "$IMAGES_ZIP" ]]; then
        curl --fail --show-error --location \
             --progress-bar \
             --output "$IMAGES_ZIP" \
             "$ZIP_URL" \
        || err "Download failed. Check the URL or your internet connection."
        ok "Downloaded: ${IMAGES_ZIP}"
    else
        warn "ZIP already exists, skipping download."
    fi

    # Count already-extracted image files
    local n_extracted
    n_extracted=$(find "$TMP_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" \) 2>/dev/null | wc -l)

    if (( n_extracted > 0 )); then
        warn "Found ${n_extracted} already-extracted images in ${TMP_DIR}, skipping extraction."
    else
        info "Extracting ZIP to ${TMP_DIR} (this may take a while)..."
        unzip -o -q "$IMAGES_ZIP" -d "$TMP_DIR" \
        || err "Extraction failed."
        ok "Extracted all files."
    fi

    # Locate the metadata JSON (may be bundled inside the ZIP)
    if [[ ! -f "$JSON_FILE" ]]; then
        local found_json
        found_json=$(find "$TMP_DIR" "$META_DIR" -maxdepth 5 -name "*.json" 2>/dev/null | head -1)
        [[ -z "$found_json" ]] && err "No JSON metadata found. The ZIP may not contain a metadata file — check the LILA dataset page."
        cp "$found_json" "$JSON_FILE"
        ok "Located metadata JSON: ${JSON_FILE}"
    else
        warn "JSON already exists at ${JSON_FILE}, skipping."
    fi
}

# =============================================================================
# STEP 3 — Sort images into category folders
# =============================================================================

sort_images() {
    info "Sorting images into category folders (limit: ${LIMIT}/category)..."

    python3 - <<PYEOF
import json, os, sys, re, shutil
from pathlib import Path

JSON_FILE  = "${JSON_FILE}"
TMP_DIR    = "${TMP_DIR}"
OUTPUT_DIR = "${OUTPUT_DIR}"
LIMIT      = int("${LIMIT}")

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

# ---- Index all extracted files by basename ----------------------------------
# The ZIP may extract into subdirectories, so we walk the full tree.
print(f"  Indexing extracted files in {TMP_DIR} ...")
extracted: dict[str, Path] = {}
for p in Path(TMP_DIR).rglob("*"):
    if p.is_file() and p.suffix.lower() in {".jpg", ".jpeg", ".png"}:
        extracted[p.name] = p

print(f"  Indexed {len(extracted)} image files on disk.")

# ---- Build deduplicated per-category image lists ----------------------------
# Key by image_id so multiple annotations on the same image don't inflate counts.
cat_image_sets: dict[str, dict] = {name: {} for name in categories.values()}

for ann in data.get("annotations", []):
    cat_name = categories.get(ann.get("category_id"))
    img_id   = ann.get("image_id")
    img_path = images.get(img_id)
    if cat_name and img_id and img_path:
        cat_image_sets[cat_name][img_id] = img_path

# ---- Copy files into OUTPUT_DIR/category/ -----------------------------------
total_copied  = 0
total_missing = 0

for cat_name, img_dict in cat_image_sets.items():
    if not img_dict:
        print(f"  [SKIP] '{cat_name}' — no annotations.")
        continue

    safe_name = re.sub(r"[^a-zA-Z0-9_\-]", "_", cat_name.strip().lower())
    cat_dir   = Path(OUTPUT_DIR) / safe_name
    cat_dir.mkdir(parents=True, exist_ok=True)

    # Skip categories already at the limit (idempotent re-runs)
    existing = sum(1 for f in cat_dir.iterdir() if f.is_file())
    paths    = list(img_dict.values())[:LIMIT]

    if existing >= len(paths):
        print(f"  [SKIP] '{cat_name}' — already has {existing}/{len(paths)} images.")
        continue

    copied  = 0
    missing = 0
    for rel_path in paths:
        fname = Path(rel_path).name
        src   = extracted.get(fname)
        if src is None:
            missing += 1
            continue
        dst = cat_dir / fname
        if not dst.exists():
            shutil.copy2(src, dst)
            copied += 1

    status = f"{copied} copied"
    if missing:
        status += f", {missing} not found on disk"
    print(f"  [DONE] '{cat_name}' ({safe_name}) → {status}")
    total_copied  += copied
    total_missing += missing

print(f"\n  Total copied : {total_copied}")
if total_missing:
    print(f"  Total missing: {total_missing} (in metadata but not in ZIP)")
PYEOF

    ok "Sorting complete."
}

# =============================================================================
# STEP 4 — Optional cleanup of tmp extracted images
# =============================================================================

cleanup() {
    if [[ "$CLEAN" == "--clean" ]]; then
        info "Removing tmp images directory (${TMP_DIR})..."
        rm -rf "$TMP_DIR"
        ok "Cleaned up."
    else
        info "Tmp images kept at ${TMP_DIR}. Pass --clean to remove after sorting."
    fi
}

# =============================================================================
# STEP 5 — Summary
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
    echo "  Cleanup after sort : ${CLEAN:-no}"
    echo "============================================================"
    echo ""

    check_deps
    setup_dirs
    download_and_extract
    sort_images
    cleanup
    print_summary
}

main "$@"