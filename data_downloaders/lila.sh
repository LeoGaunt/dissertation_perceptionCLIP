#!/usr/bin/env bash
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

# =============================================================================
# CONFIG
# =============================================================================

LIMIT="${1:-200}"   # Images per category; override with first argument

# Azure ZIP containing the COCO Camera Traps JSON
ZIP_URL="https://lilawildlife.blob.core.windows.net/lila-wildlife/felidae-conservation-fund/felidae_conservation_fund_2020_2025.zip"

# GCS bucket root for the Felidae Conservation Fund images
GCS_ROOT="gs://public-datasets-lila/felidae-conservation-fund"

# Local paths
OUTPUT_DIR="/content/dissertation_perceptionCLIP/datasets/data/lila"
TMP_DIR="/content/dissertation_perceptionCLIP/tmp/lila_metadata"
LISTS_DIR="${TMP_DIR}/gsutil_lists"
ZIP_FILE="${TMP_DIR}/felidae_conservation_fund_2020_2025.zip"
JSON_FILE="${TMP_DIR}/felidae_conservation_fund_2020_2025.json"

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
    for cmd in gsutil python3 curl unzip; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        err "Missing required commands: ${missing[*]}"
    fi
    ok "All dependencies found."
}

# =============================================================================
# STEP 1 — Create directories
# =============================================================================

setup_dirs() {
    info "Creating output directories..."
    mkdir -p "$OUTPUT_DIR"
    mkdir -p "$TMP_DIR"
    mkdir -p "$LISTS_DIR"
    ok "Directories ready."
}

# =============================================================================
# STEP 2 — Download metadata
# =============================================================================

download_metadata() {
    info "Downloading Felidae Conservation Fund metadata..."

    if [[ -f "$JSON_FILE" ]]; then
        warn "JSON already exists at ${JSON_FILE}, skipping download."
        return
    fi

    if [[ ! -f "$ZIP_FILE" ]]; then
        curl --fail --show-error --location \
             --progress-bar \
             --output "$ZIP_FILE" \
             "$ZIP_URL" \
        || err "Failed to download metadata ZIP. Check the URL or your internet connection."
        ok "Downloaded ZIP: ${ZIP_FILE}"
    else
        warn "ZIP already exists at ${ZIP_FILE}, skipping download."
    fi

    info "Extracting ZIP..."
    unzip -o -q "$ZIP_FILE" -d "$TMP_DIR"

    # Locate the JSON regardless of any path nesting inside the ZIP
    local found_json
    found_json=$(find "$TMP_DIR" -maxdepth 3 -name "*.json" | head -1)
    [[ -z "$found_json" ]] && err "No JSON found inside ZIP at ${TMP_DIR}."
    [[ "$found_json" != "$JSON_FILE" ]] && cp "$found_json" "$JSON_FILE"

    ok "Extracted JSON: ${JSON_FILE}"
}

# =============================================================================
# STEP 3 — Parse JSON → per-category GCS path lists
# =============================================================================

parse_metadata() {
    info "Parsing COCO Camera Traps JSON (limit: ${LIMIT} images/category)..."

    python3 - <<PYEOF
import json, os, sys, re

JSON_FILE   = "${JSON_FILE}"
LISTS_DIR   = "${LISTS_DIR}"
GCS_ROOT    = "${GCS_ROOT}"
LIMIT       = int("${LIMIT}")

print(f"  Loading {JSON_FILE} ...")
with open(JSON_FILE) as f:
    data = json.load(f)

# ---- Build lookup tables ------------------------------------------------
# id → category name
categories = {c["id"]: c["name"] for c in data.get("categories", [])}
# image id → file path (relative to dataset root)
images = {img["id"]: img["file_name"] for img in data.get("images", [])}

if not categories:
    sys.exit("ERROR: No categories found in JSON. Check the dataset format.")
if not images:
    sys.exit("ERROR: No images found in JSON. Check the dataset format.")

print(f"  Found {len(categories)} categories, {len(images)} images.")

# ---- Group image paths by category --------------------------------------
cat_images: dict[str, list[str]] = {name: [] for name in categories.values()}

for ann in data.get("annotations", []):
    cat_name = categories.get(ann.get("category_id"))
    img_path = images.get(ann.get("image_id"))
    if cat_name and img_path and len(cat_images[cat_name]) < LIMIT:
        cat_images[cat_name].append(img_path)

# ---- Write per-category GCS path lists ----------------------------------
os.makedirs(LISTS_DIR, exist_ok=True)
written = 0
for cat_name, paths in cat_images.items():
    if not paths:
        print(f"  [SKIP] '{cat_name}' — no annotations found.")
        continue
    # Sanitise category name for filesystem use
    safe_name = re.sub(r"[^a-zA-Z0-9_\-]", "_", cat_name.strip().lower())
    list_path = os.path.join(LISTS_DIR, f"{safe_name}.txt")
    with open(list_path, "w") as lf:
        for p in paths[:LIMIT]:
            # Ensure we don't double-slash
            gcs_path = GCS_ROOT.rstrip("/") + "/" + p.lstrip("/")
            lf.write(gcs_path + "\n")
    print(f"  [LIST] '{cat_name}' ({safe_name}) → {len(paths[:LIMIT])} paths")
    written += 1

print(f"  Wrote {written} category list(s) to {LISTS_DIR}")
PYEOF

    ok "JSON parsed. Category lists written to ${LISTS_DIR}."
}

# =============================================================================
# STEP 4 — Download images via gsutil
# =============================================================================

download_images() {
    info "Downloading images (up to ${LIMIT}/category) via gsutil..."

    local list_files
    list_files=(${LISTS_DIR}/*.txt)

    if [[ ${#list_files[@]} -eq 0 || ! -f "${list_files[0]}" ]]; then
        err "No category list files found in ${LISTS_DIR}. Did Step 3 succeed?"
    fi

    local total_cats=${#list_files[@]}
    local idx=0

    for list_file in "${list_files[@]}"; do
        idx=$(( idx + 1 ))
        local cat_name
        cat_name=$(basename "$list_file" .txt)
        local cat_dir="${OUTPUT_DIR}/${cat_name}"

        log "[${idx}/${total_cats}] Category: ${cat_name}"
        mkdir -p "$cat_dir"

        # Count lines (images requested)
        local n_requested
        n_requested=$(wc -l < "$list_file")

        # Count already-downloaded images
        local n_existing
        n_existing=$(find "$cat_dir" -maxdepth 1 -type f | wc -l)

        if (( n_existing >= n_requested )); then
            warn "  Already have ${n_existing}/${n_requested} images — skipping."
            continue
        fi

        # gsutil -m cp reads the source URIs line by line via a manifest.
        # We use a subshell to pass each URI; gsutil -m parallelises transfers.
        gsutil -m cp \
            -I \
            "$cat_dir/" \
            < "$list_file" \
        && ok "  Downloaded to ${cat_dir}/" \
        || warn "  Some files may have failed for '${cat_name}'. Check gsutil output above."
    done

    ok "Image downloads complete."
}

# =============================================================================
# STEP 5 — Summary
# =============================================================================

print_summary() {
    echo ""
    echo "============================================================"
    echo "  LILA Felidae Dataset — Setup Complete"
    echo "============================================================"
    echo "  Output dir  : ${OUTPUT_DIR}"
    echo "  Tmp/metadata: ${TMP_DIR}"
    echo ""
    echo "  Per-category image counts:"
    for cat_dir in "${OUTPUT_DIR}"/*/; do
        [[ -d "$cat_dir" ]] || continue
        local count
        count=$(find "$cat_dir" -maxdepth 1 -type f | wc -l)
        printf "    %-30s %d images\n" "$(basename "$cat_dir")" "$count"
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
    echo "  Per-category limit: ${LIMIT}"
    echo "============================================================"
    echo ""

    check_deps
    setup_dirs
    download_metadata
    parse_metadata
    download_images
    print_summary
}

main "$@"