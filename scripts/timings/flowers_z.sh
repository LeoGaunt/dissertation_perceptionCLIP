#!/bin/bash

export PYTHONPATH="$PYTHONPATH:$PWD"

python -m src.zero_shot_inference.perceptionclip_two_step \
--dataset Flowers   \
--data_location ./datasets/data/flowers   \
--model ViT-B/16   \
--infer_mode 0   \
--factors background,illumination,petals,quality \
--template flowers_template \
--main_template flowers_main_template   \
--factor_templates flowers_factor_templates   \
--temperature 1   \
--batch_size 128   \
--save_name ucm_ViT-B16_z