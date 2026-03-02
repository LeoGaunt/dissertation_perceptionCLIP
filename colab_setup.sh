echo "Installing dependencies"
pip install open_clip_torch
pip install git+https://github.com/modestyachts/ImageNetV2_pytorch
pip install kornia
echo "Setting up datasets"
mkdir datasets
cd datasets
mkdir data
cd data
mkdir eurosat
cd eurosat
wget https://madm.dfki.de/files/sentinel/EuroSAT.zip --no-check-certificate
unzip EuroSAT.zip
rm EuroSAT.zip
cd ..
cd ..
cd ..
echo "Setup complete"
