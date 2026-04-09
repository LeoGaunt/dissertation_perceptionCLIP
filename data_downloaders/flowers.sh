#!/bin/bash
# Oxford 17 Flowers Dataset Downloader
# Organises images into class-named subdirectories under flowers/
# Target: /content/dissertation_perceptionCLIP/datasets/data/flowers

set -e

DEST="/content/dissertation_perceptionCLIP/datasets/data/flowers"
URL_BASE="http://www.robots.ox.ac.uk/~vgg/data/flowers/17"

# Class names (0-indexed, 80 images each, sequential ordering)
CLASSES=(
    "daffodil"
    "snowdrop"
    "lily_valley"
    "bluebell"
    "crocus"
    "iris"
    "tigerlily"
    "tulip"
    "fritillary"
    "sunflower"
    "daisy"
    "colts_foot"
    "dandelion"
    "cowslip"
    "buttercup"
    "windflower"
    "pansy"
)

echo "Creating directory..."
mkdir -p "$DEST"
cd "$DEST"

echo "Downloading images..."
wget -q --show-progress -O 17flowers.tgz "$URL_BASE/17flowers.tgz"

echo "Downloading split file..."
wget -q --show-progress -O datasplits.mat "$URL_BASE/datasplits.mat"

echo "Extracting archive..."
tar -xzf 17flowers.tgz
rm 17flowers.tgz

echo "Organising into class folders..."
for i in "${!CLASSES[@]}"; do
    CLASS="${CLASSES[$i]}"
    CLASS_DIR="$DEST/$CLASS"
    mkdir -p "$CLASS_DIR"

    # Images are 1-indexed: class i covers images (i*80+1) to ((i+1)*80)
    START=$(( i * 80 + 1 ))
    END=$(( (i + 1) * 80 ))

    for n in $(seq "$START" "$END"); do
        FILENAME=$(printf "image_%04d.jpg" "$n")
        mv "$DEST/jpg/$FILENAME" "$CLASS_DIR/$FILENAME"
    done

    echo "  [$((i+1))/17] $CLASS — images $START to $END"
done

# Remove now-empty jpg dir
rmdir "$DEST/jpg"

echo ""
echo "Done. Structure:"
for CLASS in "${CLASSES[@]}"; do
    COUNT=$(find "$DEST/$CLASS" -name "*.jpg" | wc -l)
    echo "  $CLASS/ ($COUNT images)"
done
echo ""
echo "datasplits.mat ready at $DEST/datasplits.mat"