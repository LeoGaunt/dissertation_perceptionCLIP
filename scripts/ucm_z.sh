#!/bin/bash

export PYTHONPATH="$PYTHONPATH:$PWD"

python -m src.zero_shot_inference.perceptionclip_two_step \
--dataset UCM   \
--data_location ./datasets/data/ucm   \
--model ViT-B/16   \
--infer_mode 0   \
--factors condition,source,land \
--template ucm_template \
--main_template ucm_main_template   \
--factor_templates ucm_factor_templates   \
--temperature 1   \
--batch_size 128   \
--save_name ucm_ViT-B16_z