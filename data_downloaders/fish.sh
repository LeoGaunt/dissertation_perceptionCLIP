#!/bin/bash

set -e  # exit on error

# Go to dataset directory
cd ./datasets/data || { echo "Directory not found"; exit 1; }

# Create fish directory
mkdir -p fish

# Download dataset from Kaggle
echo "Downloading dataset..."
curl -L -o fish.zip https://www.kaggle.com/api/v1/datasets/download/markdaniellampa/fish-dataset

# Unzip dataset
echo "Unzipping dataset..."
unzip -q fish.zip -d fish_raw

# Navigate into extracted folder (adjust if needed)
cd fish_raw/FishImgDataset || { echo "Dataset structure not found"; exit 1; }

# Loop through train, test, val
for split in train test val; do
    if [ -d "$split" ]; then
        echo "Processing $split..."
        
        for class_dir in "$split"/*; do
            class_name=$(basename "$class_dir")
            
            # Create class folder in fish if it doesn't exist
            mkdir -p ../../fish/"$class_name"
            
            # Move images into combined folder
            mv "$class_dir"/* ../../fish/"$class_name"/ 2>/dev/null || true
        done
    fi
done

echo "Cleaning up..."
cd ../../
rm -rf fish_raw fish.zip

echo "✅ Dataset ready in ./datasets/data/fish"