# Does Adding Contextual Data to Images Increase Object Recognition Performance?
by Leo Gaunt

## Fork of the Paper: PerceptionCLIP: Visual Classification by Inferring and Conditioning on Contexts

by [Bang An*](https://bangann.github.io/), [Sicheng Zhu*](https://schzhu.github.io/)
, [Michael-Andrei Panaitescu-Liess](https://scholar.google.se/citations?user=MOP6lhkAAAAJ&hl=lv)
, [Chaithanya Kumar Mummadi](https://scholar.google.com/citations?user=XJLtaG4AAAAJ&hl=en)
, [Furong Huang](http://furong-huang.com/)

[[PerceptionCLIP Paper](https://arxiv.org/pdf/2308.01313.pdf)]

## About

This codebase is in addition to the Dissertation 'Does Adding Contextual Data to Images Increase Object Recognition Performance?' which acts as an evaluation of the Ff

## Setup

This experiment was made to be run in Google Colab, I would recommend using it on there, however with some minro adjustements it should 
run well as long as the machine has CUDA support. 

Once downloaded to Google Colab `./colab_setup.sh` should install the necessary packages and set up the environment correctly.

### Code structure

Here's a brief intro of the major components of the code:

* `./src/datasets` contains the code for all the Datasets and Dataloaders.
* `./src/templates` contains all the text prompts.
* `./src/zero_shot_inference` contains the major code for the PerceptionCLIP method and experiments.
* `./scripts` contains the running scripts.
* `./data_downloaders` contains the major install and formatting scripts for the datasets required if they were not standardised or cmae in a different wormat to how PerceptionCLIP would accept.
* `./visualizations` contains the code for visualizations.
