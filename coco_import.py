import json
import shutil
from pathlib import Path
from collections import defaultdict

# ===== EDIT THESE PATHS =====
COCO_ROOT = Path("/Users/leogaunt/Documents/COCO")
ANN_FILE = COCO_ROOT / "annotations" / "instances_train2017.json"
IMAGE_DIR = COCO_ROOT / "train2017"
OUTPUT_DIR = COCO_ROOT / "bus_dataset"
# ============================

IMAGES_OUT = OUTPUT_DIR / "images"
ANN_OUT = OUTPUT_DIR / "annotations"

IMAGES_OUT.mkdir(parents=True, exist_ok=True)
ANN_OUT.mkdir(parents=True, exist_ok=True)

# Load COCO json
with open(ANN_FILE, "r") as f:
    coco = json.load(f)

# Find bus category id
bus_cat_id = next(c["id"] for c in coco["categories"] if c["name"] == "bus")

# Map image_id -> image info
images_by_id = {img["id"]: img for img in coco["images"]}

# Collect only bus annotations, grouped by image
bus_anns_by_image = defaultdict(list)
for ann in coco["annotations"]:
    if ann["category_id"] == bus_cat_id:
        bus_anns_by_image[ann["image_id"]].append(ann)

# Copy images and save annotation json per image
count = 0
for image_id, anns in bus_anns_by_image.items():
    img_info = images_by_id[image_id]
    file_name = img_info["file_name"]

    src = IMAGE_DIR / file_name
    dst = IMAGES_OUT / file_name

    if src.exists():
        shutil.copy2(src, dst)

        # Save annotation json for this image
        out_json = ANN_OUT / f"{Path(file_name).stem}.json"
        with open(out_json, "w") as f:
            json.dump({
                "image": img_info,
                "bus_annotations": anns
            }, f, indent=2)

        count += 1

print(f"Saved {count} bus images to {IMAGES_OUT}")
print(f"Saved per-image annotations to {ANN_OUT}")