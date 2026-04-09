import os
import random

base_dir = "/content/dissertation_perceptionCLIP/datasets/data/lila"
limit = 200

for category in os.listdir(base_dir):
    cat_path = os.path.join(base_dir, category)
    
    if not os.path.isdir(cat_path):
        continue
    
    images = [f for f in os.listdir(cat_path) if os.path.isfile(os.path.join(cat_path, f))]
    
    if len(images) > limit:
        to_delete = random.sample(images, len(images) - limit)
        
        for img in to_delete:
            os.remove(os.path.join(cat_path, img))
        
        print(f"{category}: trimmed to {limit}")
    else:
        print(f"{category}: already ≤ {limit}")