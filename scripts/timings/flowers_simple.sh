#!/bin/bash

export PYTHONPATH="$PYTHONPATH:$PWD"

python -m src.zero_shot_inference.perceptionclip_one_step \
--dataset Flowers  \
--data_location ./datasets/data/flowers   \
--model ViT-B/16   \
--save_name flowers_ViT-B16_simple