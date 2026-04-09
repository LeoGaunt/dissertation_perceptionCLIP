#!/bin/bash

export PYTHONPATH="$PYTHONPATH:$PWD"

python -m src.zero_shot_inference.perceptionclip_one_step \
--dataset UCM  \
--data_location ./datasets/data/ucm   \
--model ViT-B/16   \
--save_name ucm_ViT-B16_simple