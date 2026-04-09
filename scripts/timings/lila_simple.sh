#!/bin/bash

export PYTHONPATH="$PYTHONPATH:$PWD"

python -m src.zero_shot_inference.perceptionclip_one_step \
	--dataset Lila  \
	--data_location ./datasets/data/lila   \
	--model ViT-B/16   \
	--infer_mode 0   \
	--temperature 1   \
	--batch_size 128   \
	--save_name lila_ViT-B16_simple