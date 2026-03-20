#!/bin/bash
set -e

cd ./datasets/data || { echo "Directory not found"; exit 1; }

echo "Downloading dataset..."
curl -L -o marine.zip https://www.kaggle.com/api/v1/datasets/download/vencerlanz09/sea-animals-image-dataste

echo "Unzipping dataset..."
unzip -q marine.zip -d marine
rm -rf marine.zip

echo "Renaming folders to singular lowercase..."
declare -A renames=(
    ["Clams"]="clam"
    ["Corals"]="coral"
    ["Crabs"]="crab"
    ["Dolphin"]="dolphin"
    ["Eel"]="eel"
    ["Fish"]="fish"
    ["Jelly Fish"]="jellyfish"
    ["Lobster"]="lobster"
    ["Nudibranchs"]="nudibranch"
    ["Octopus"]="octopus"
    ["Otter"]="otter"
    ["Penguin"]="penguin"
    ["Puffers"]="puffer fish"
    ["Seahorse"]="seahorse"
    ["Seal"]="seal"
    ["Sea Rays"]="stingray"
    ["Sea Urchins"]="sea urchin"
    ["Sharks"]="shark"
    ["Shrimp"]="shrimp"
    ["Squid"]="squid"
    ["Starfish"]="starfish"
    ["Turtle_Tortoise"]="turtle"
    ["Whale"]="whale"
)

for old in "${!renames[@]}"; do
    new="${renames[$old]}"
    if [ -d "marine/$old" ]; then
        mv "marine/$old" "marine/$new"
        echo "  Renamed: '$old' -> '$new'"
    fi
done

cd ../../
echo "✅ Dataset ready in ./datasets/data/marine"