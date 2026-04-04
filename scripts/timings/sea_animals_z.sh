#!/bin/bash

export PYTHONPATH="$PYTHONPATH:$PWD"

python -m src.zero_shot_inference.perceptionclip_two_step \
	--dataset Marine   \
	--data_location ./datasets/data/marine   \
	--model ViT-B/16   \
	--infer_mode 0   \
	--factors in,size,amount,location,state  \
	--template marine_template  \
	--main_template marine_main_template   \
	--factor_templates marine_factor_templates   \
	--temperature 1   \
	--batch_size 256   \
	--save_name marine_ViT-B16_z