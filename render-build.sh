#!/usr/bin/env bash
set -e

# Update package lists
apt-get update

# Install required libraries for Chrome
apt-get install -y \
    libnss3 \
    libxss1 \
    libappindicator3-1 \
    libindicator7 \
    libgtk-3-0 \
    libgbm1 \
    libasound2 \
    libxcomposite1 \
    libxcursor1 \
    libxi6 \
    libxtst6 \
    libglib2.0-0

# Install required Python packages
pip install --upgrade pip
pip install --upgrade selenium webdriver-manager

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

# Ensure Chrome binary exists and is executable
if [ ! -f /opt/render/project/chrome/chrome ]; then
    echo "Chrome binary not found!"
    exit 1
fi

if [ ! -x /opt/render/project/chrome/chrome ]; then
    echo "Chrome binary is not executable!"
    exit 1
fi