#!/bin/bash
# =============================================================================
# setup_lila_felidae.sh
#
# 1. Downloads the Felidae Conservation Fund metadata ZIP from Azure
# 2. Extracts the COCO Camera Traps JSON
# 3. Parses the JSON to build per-category image lists
# 4. Downloads up to LIMIT images per category from GCS using gsutil
#
# Output structure:
#   /content/dissertation_perceptionCLIP/datasets/data/lila/
#       mule_deer/
#       gray_fox/
#       bobcat/
#       ...                <- category folders directly here
#
#   /content/dissertation_perceptionCLIP/tmp/lila_metadata/
#       felidae_conservation_fund_2020_2025.zip
#       *.json
#       gsutil_lists/      <- per-category GCS path lists (temp)
#
# Requirements:
#   - gsutil  (pre-installed on Google Colab)
#   - python3 (pre-installed on Google Colab)
#   - curl, unzip
#
# Usage:
#   bash setup_lila_felidae.sh
#   bash setup_lila_felidae.sh 500      <- override per-category limit
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
LIMIT="${1:-300}"                     # Max images to download per category
IMAGES_DIR="/content/dissertation_perceptionCLIP/datasets/data/lila"
METADATA_DIR="/content/dissertation_perceptionCLIP/tmp/lila_metadata"
ZIP_URL="https://lilawildlife.blob.core.windows.net/lila-wildlife/felidae-conservation-fund/felidae_conservation_fund_2020_2025.zip"
GCS_BASE="gs://public-datasets-lila/felidae-conservation-fund"

echo "============================================================"
echo " LILA Felidae Conservation Fund — Dataset Setup"
echo "  Per-category limit : ${LIMIT} images"
echo "  Images directory   : ${IMAGES_DIR}"
echo "============================================================"
echo ""

# ---------------------------------------------------------------------------
# Step 1: Create directories
# ---------------------------------------------------------------------------
echo "[1/5] Creating directories..."
mkdir -p "${METADATA_DIR}" "${IMAGES_DIR}"
LISTS_DIR="${METADATA_DIR}/gsutil_lists"

# ---------------------------------------------------------------------------
# Step 2: Download metadata ZIP
# ---------------------------------------------------------------------------
ZIP_PATH="${METADATA_DIR}/felidae_conservation_fund_2020_2025.zip"

if [ -f "${ZIP_PATH}" ]; then
    echo "[2/5] Metadata ZIP already exists, skipping download."
else
    echo "[2/5] Downloading metadata ZIP..."
    curl -L --progress-bar --retry 3 --retry-delay 5 \
         -o "${ZIP_PATH}" "${ZIP_URL}"
    echo "      Saved to: ${ZIP_PATH}"
fi

# ---------------------------------------------------------------------------
# Step 3: Extract ZIP
# ---------------------------------------------------------------------------
echo "[3/5] Extracting metadata ZIP..."
unzip -o "${ZIP_PATH}" -d "${METADATA_DIR}"

# Auto-detect the extracted JSON file
JSON_PATH=$(find "${METADATA_DIR}" -name "*.json" | head -n 1)
if [ -z "${JSON_PATH}" ]; then
    echo "ERROR: No JSON file found after extraction. Aborting."
    exit 1
fi
echo "      Found JSON: ${JSON_PATH}"

# ---------------------------------------------------------------------------
# Step 4: Parse JSON — build per-category image lists
# ---------------------------------------------------------------------------
echo "[4/5] Parsing COCO JSON and building category image lists..."

# This Python snippet reads the COCO JSON and writes one text file per
# category containing GCS paths — up to LIMIT paths each.
# The text files are written to a temp directory and consumed by gsutil below.
mkdir -p "${LISTS_DIR}"

python3 - <<PYEOF
import json
import os
from pathlib import Path
from collections import defaultdict

json_path   = "${JSON_PATH}"
lists_dir   = "${LISTS_DIR}"
gcs_base    = "${GCS_BASE}"
limit       = int("${LIMIT}")

print(f"  Reading {json_path} ...")
with open(json_path) as f:
    data = json.load(f)

# id → name
category_map = {c["id"]: c["name"] for c in data["categories"]}

# id → file_name
image_map = {img["id"]: img["file_name"] for img in data["images"]}

# image_id → first category_id  (use first annotation per image)
image_to_cat = {}
for ann in data["annotations"]:
    iid = ann["image_id"]
    if iid not in image_to_cat:
        image_to_cat[iid] = ann["category_id"]

# Group file_names by category
cat_files = defaultdict(list)
for img_id, cat_id in image_to_cat.items():
    fname = image_map.get(img_id)
    if fname:
        cat_files[cat_id].append(fname)

# Write one list file per category (up to limit entries)
total = 0
print(f"  Writing gsutil list files (limit={limit} per category)...")
for cat_id, files in sorted(cat_files.items()):
    cat_name = category_map[cat_id].strip().lower().replace(" ", "_").replace("/", "-")
    subset   = files[:limit]
    list_file = os.path.join(lists_dir, f"{cat_name}.txt")
    with open(list_file, "w") as lf:
        for fname in subset:
            lf.write(f"{gcs_base}/{fname}\n")
    total += len(subset)
    print(f"    {cat_name:<40} {len(subset):>5} images")

print(f"\n  Total images to download: {total:,}")
PYEOF

# ---------------------------------------------------------------------------
# Step 5: Download images per category using gsutil
# ---------------------------------------------------------------------------
echo ""
echo "[5/5] Downloading images via gsutil..."
echo "      (gsutil will skip files that already exist)"
echo ""

FAIL_COUNT=0
NUM_THREADS=$(nproc)
echo "      Using ${NUM_THREADS} threads (nproc)"
echo ""

for LIST_FILE in "${LISTS_DIR}"/*.txt; do
    CATEGORY=$(basename "${LIST_FILE}" .txt)
    DEST_DIR="${IMAGES_DIR}/${CATEGORY}"
    mkdir -p "${DEST_DIR}"

    LINE_COUNT=$(wc -l < "${LIST_FILE}")
    echo "  ► ${CATEGORY} (${LINE_COUNT} images) → ${DEST_DIR}"

    # -m  : parallel multi-threaded transfer
    # -n  : skip if destination file already exists (no-clobber)
    # -I  : read source URIs from stdin
    # parallel_thread_count: use all available CPU threads
    # parallel_process_count=1: single process, many threads (better for Colab)
    if ! gsutil -o "GSUtil:parallel_thread_count=${NUM_THREADS}" \
                -o "GSUtil:parallel_process_count=1" \
                -m cp -n -I "${DEST_DIR}/" < "${LIST_FILE}" 2>&1 | tail -3; then
        echo "    WARNING: gsutil reported errors for category '${CATEGORY}'"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi

    echo ""
done

# ---------------------------------------------------------------------------
# Remove unwanted categories
# ---------------------------------------------------------------------------
echo "Removing ambiguous/catch-all category folders..."
rm -rf "${IMAGES_DIR}/unknown"
rm -rf "${IMAGES_DIR}/prey-mammal"
rm -rf "${IMAGES_DIR}/prey-unknown"
echo "Done."

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo "============================================================"
echo " Download complete!"
echo ""
echo " Categories with errors: ${FAIL_COUNT}"
echo ""
echo " Image counts per category:"
for FOLDER in "${IMAGES_DIR}"/*/; do
    COUNT=$(find "${FOLDER}" -type f | wc -l)
    printf "   %-40s %6d images\n" "$(basename "${FOLDER}")" "${COUNT}"
done
echo ""
echo " Run  python3 verify_lila_dataset.py  to validate the dataset."
echo "============================================================"