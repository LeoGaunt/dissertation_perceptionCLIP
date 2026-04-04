#!/bin/bash

export PYTHONPATH="$PYTHONPATH:$PWD"

python -m src.zero_shot_inference.perceptionclip_one_step \
	--dataset Fish  \
	--data_location ./datasets/data/fish   \
	--model ViT-B/16   \
	--infer_mode 0   \
	--temperature 1   \
	--batch_size 128   \
	--save_name fish_ViT-B16_simple