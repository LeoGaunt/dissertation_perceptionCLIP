# GradCAM visualizations

### Setup

After the use of `colab_setup.sh` there you may need to download the 2 commented packages.

```bash
pip install git+https://github.com/openai/CLIP.git
pip install torchray
```

### Analyze the results

In this part you can check the ratio between the usage of core and spurious features in prediction. 
Now, by running the "analysis.iypnb" notebook you can create the segmentation masks and analyze the percentage of core and spurious regions used in classification. And also see the Grad-CAMs and values used in the paper.

