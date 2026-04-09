#!/bin/bash

export PYTHONPATH="$PYTHONPATH:$PWD"

python -m src.zero_shot_inference.perceptionclip_two_step \
--dataset Lila   \
--data_location ./datasets/data/lila   \
--model ViT-B/16   \
--infer_mode 0   \
--factors in,time,activity,camera_view,image_quality  \
--template lila_template  \
--main_template lila_main_template   \
--factor_templates lila_factor_templates   \
--temperature 1   \
--batch_size 128   \
--save_name lila_ViT-B16_z