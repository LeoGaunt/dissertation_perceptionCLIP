#!/bin/bash

export PYTHONPATH="$PYTHONPATH:$PWD"

python -m src.zero_shot_inference.perceptionclip_one_step \
	--dataset Dissertation  \
	--data_location ./datasets/data/dissertation   \
	--model ViT-B/16   \
	--infer_mode 0   \
	--temperature 1   \
	--batch_size 128   \
	--save_name train-bus_ViT-B16_simple