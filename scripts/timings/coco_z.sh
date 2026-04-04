#!/bin/bash

export PYTHONPATH="$PYTHONPATH:$PWD"

python -m src.zero_shot_inference.perceptionclip_two_step \
	--dataset Dissertation   \
	--data_location ./datasets/data/dissertation   \
	--model ViT-B/16   \
	--infer_mode 0   \
	--factors on,direction,weather,amount,decker  \
	--template dissertation_template  \
	--main_template dissertation_main_template   \
	--factor_templates dissertation_factor_templates   \
	--temperature 1   \
	--batch_size 128   \
	--save_name train-bus_ViT-B16_z