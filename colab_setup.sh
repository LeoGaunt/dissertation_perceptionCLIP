echo "Installing dependencies"
pip install open_clip_torch
pip install git+https://github.com/modestyachts/ImageNetV2_pytorch
pip install kornia
echo "Setting up datasets"
mkdir datasets
cd datasets
mkdir data
cd data
cp /content/drive/MyDrive/dissertation.zip /content/dissertation_perceptionCLIP/datasets/data/dissertation.zip
unzip dissertation.zip
cd ..
cd ..
cd ..
echo "Setup complete"
