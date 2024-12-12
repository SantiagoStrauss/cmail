#!/usr/bin/env bash
set -e

# Install required packages
pip install webdriver-manager

# Install Google Chrome
echo "Installing Google Chrome..."
wget -q https://storage.googleapis.com/chrome-for-testing-public/131.0.6778.108/linux64/chrome-linux64.zip
unzip -q chrome-linux64.zip
mkdir -p /opt/render/project/chrome
mv chrome-linux64/chrome /opt/render/project/chrome/
chmod +x /opt/render/project/chrome/chrome
rm -rf chrome-linux64.zip chrome-linux64

# Verify Chrome installation
echo "Verifying Chrome installation..."
/opt/render/project/chrome/chrome --version