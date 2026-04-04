#!/bin/bash

export PYTHONPATH="$PYTHONPATH:$PWD"

python -m src.zero_shot_inference.perceptionclip_two_step \
--dataset EuroSAT   \
--data_location ./datasets/data   \
--model ViT-B/16   \
--infer_mode 0   \
--factors condition,source  \
--template eurosat_template \
--main_template eurosat_main_template   \
--factor_templates eurosat_factor_templates   \
--temperature 1   \
--batch_size 128   \
--save_name eurosat_ViT-B16_z