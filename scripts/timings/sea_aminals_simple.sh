#!/bin/bash

export PYTHONPATH="$PYTHONPATH:$PWD"

python -m src.zero_shot_inference.perceptionclip_one_step \
	--dataset Marine  \
	--data_location ./datasets/data/marine   \
	--model ViT-B/16   \
	--infer_mode 0   \
	--temperature 1   \
	--batch_size 256   \
	--save_name marine_ViT-B16_simple