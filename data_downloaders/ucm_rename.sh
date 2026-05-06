#!/bin/bash

declare -A renames=(
    ["agricultural"]="agricultural land"
    ["airplane"]="airplane(s)"
    ["baseballdiamond"]="baseball diamond"
    ["beach"]="beach"
    ["buildings"]="buildings"
    ["chaparral"]="chaparral"
    ["denseresidential"]="dense residential"
    ["forest"]="forest"
    ["freeway"]="freeway"
    ["golfcourse"]="golf course"
    ["harbor"]="harbor"
    ["intersection"]="intersection"
    ["mediumresidential"]="medium residential"
    ["mobilehomepark"]="mobile home park"
    ["overpass"]="overpass"
    ["parkinglot"]="parking lot"
    ["river"]="river"
    ["runway"]="runway"
    ["sparseresidential"]="sparse residential"
    ["storagetanks"]="storage tanks"
    ["tenniscourt"]="tennis court"
)

for old in "${!renames[@]}"; do
    new="${renames[$old]}"
    if [ -d "$old" ]; then
        mv "$old" "$new"
        echo "  $old → $new"
    else
        echo "  SKIP (not found): $old"
    fi
done

echo "Done."