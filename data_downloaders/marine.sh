#!/bin/bash

set -e  # exit on error

# Go to dataset directory
cd ./datasets/data || { echo "Directory not found"; exit 1; }

# Download dataset from Kaggle
echo "Downloading dataset..."
curl -L -o marine.zip https://www.kaggle.com/api/v1/datasets/download/vencerlanz09/sea-animals-image-dataste

# Unzip dataset
echo "Unzipping dataset..."
unzip -q marine.zip -d marine
rm -rf marine.zip

echo "Cleaning up..."
cd ../../

echo "✅ Dataset ready in ./datasets/data/marine"