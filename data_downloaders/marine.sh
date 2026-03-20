#!/bin/bash

set -e  # exit on error

# Go to dataset directory
cd ./datasets/data || { echo "Directory not found"; exit 1; }

# Create marine directory
mkdir -p marine

# Download dataset from Kaggle
echo "Downloading dataset..."
curl -L -o marine.zip https://www.kaggle.com/api/v1/datasets/download/vencerlanz09/sea-animals-image-dataste

# Unzip dataset
echo "Unzipping dataset..."
unzip -q marine.zip -d marine_raw

# Navigate into extracted folder (adjust if needed)
cd marine_raw/Sea-Animals-Image-Dataset || { echo "Dataset structure not found"; exit 1; }

# Loop through train, test, val
for split in train test val; do
    if [ -d "$split" ]; then
        echo "Processing $split..."
        
        for class_dir in "$split"/*; do
            class_name=$(basename "$class_dir")
            
            # Create class folder in marine if it doesn't exist
            mkdir -p ../../marine/"$class_name"
            
            # Move images into combined folder
            mv "$class_dir"/* ../../marine/"$class_name"/ 2>/dev/null || true
        done
    fi
done

echo "Cleaning up..."
cd ../../
rm -rf marine_raw marine.zip

echo "✅ Dataset ready in ./datasets/data/marine"