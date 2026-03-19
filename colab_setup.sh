echo "Installing dependencies"
pip install open_clip_torch
pip install git+https://github.com/modestyachts/ImageNetV2_pytorch
pip install kornia
echo "Setting up datasets"
mkdir datasets
cd datasets
mkdir data
cd data
cd ..
cd ..
cd ..
echo "Setup complete"
