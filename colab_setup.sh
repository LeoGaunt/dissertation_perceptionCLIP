echo "Installing dependencies"
pip install open_clip_torch
pip install git+https://github.com/modestyachts/ImageNetV2_pytorch
pip install kornia
echo "Installing Grad-CAM dependencies"
pip install git+https://github.com/openai/CLIP.git
pip install torchray
echo "Setting up datasets"
mkdir datasets
cd datasets
mkdir data
cd data
cd ..
cd ..
cd ..
echo "Setup complete"
