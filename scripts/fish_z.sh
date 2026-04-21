#!/bin/bash

export PYTHONPATH="$PYTHONPATH:$PWD"

python -m src.zero_shot_inference.perceptionclip_two_step \
--dataset Fish   \
--data_location ./datasets/data/fish   \
--model ViT-B/16   \
--infer_mode 0   \
--factors in,size,amount,location,liveness  \
--template fish_template \
--main_template fish_main_template   \
--factor_templates fish_factor_templates   \
--temperature 1   \
--batch_size 128   \
--save_name fish_ViT-B16_z