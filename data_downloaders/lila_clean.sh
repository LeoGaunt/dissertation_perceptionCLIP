echo "Renaming folders to singular lowercase..."
declare -A renames=(
    ["acorn_woodpecker"]="acorn woodpecker"
    ["american_crow"]="american crow"
    ["american_robin"]="american robin"
    ["barn_owl"]="barn owl"
    ["black-tailed_jackrabbit"]="black-tailed jackrabbit"
    ["bobcat"]="bobcat"
    ["brush_rabbit"]="brush rabbit"
    ["california_quail"]="california quail"
    ["california_thrasher"]="california thrasher"
    ["california_towhee"]="california towhee"
    ["cattle"]="cattle"
    ["common_raven"]="common raven"
    ["cottontail_rabbit"]="cottontail rabbit"
    ["coyote"]="coyote"
    ["duck_species"]="duck"
    ["eastern_grey_squirrel"]="eastern grey squirrel"
    ["elk_or_deer"]="elk"
    ["gray_fox"]="gray fox"
    ["merriam's_chipmunk"]="chipmunk"
    ["mourning_dove"]="mourning dove"
    ["mouse_or_rat"]="rodent"
    ["mule_deer"]="mule deer"
    ["puma"]="puma"
    ["rabbit"]="rabbit"
    ["raccoon"]="raccoon"
    ["spotted_skunk"]="spotted skunk"
    ["steller's_jay"]="steller's jay"
    ["striped_skunk"]="striped skunk"
    ["tule_elk"]="tule elk"
    ["turkey"]="turkey"
    ["turkey_vulture"]="turkey vulture"
    ["western_grey_squirrel"]="western grey squirrel"
    ["western_scrub-jay"]="western scrub-jay"
    ["wild_boar"]="wild boar"
    ["virginia_opossum"]="virginia opossum"
)

for old_name in "${!renames[@]}"; do
    new_name="${renames[$old_name]}"
    if [ -d "$old_name" ]; then
        mv "$old_name" "$new_name"
        echo "Renamed: $old_name -> $new_name"
    else
        echo "Skipped (not found): $old_name"
    fi
done

echo "Done. Deleting unknown_* folders..."
for dir in unknown_*/; do
    if [ -d "$dir" ]; then
        rm -rf "$dir"
        echo "Deleted: $dir"
    fi
done
echo "Complete."