#!/bin/bash

export PYTHONPATH="$PYTHONPATH:$PWD"

python -m src.zero_shot_inference.perceptionclip_one_step \
--dataset EuroSAT  \
--data_location ./datasets/data   \
--model ViT-B/16   \
--save_name eurosat_ViT-B16_simple