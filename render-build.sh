#!/usr/bin/env bash
set -e

# Update package lists and install dependencies for Chrome
apt-get update
apt-get install -y libnss3 libxss1 libappindicator3-1 libindicator7 fonts-liberation libasound2 libatk1.0-0 libatk-bridge2.0-0 libc6 libcairo2 libcups2 libdbus-1-3 libexpat1 libfontconfig1 libgbm1 libglib2.0-0 libgtk-3-0 libnspr4 libnss3 libx11-6 libx11-xcb1 libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 libxtst6 ca-certificates xdg-utils wget unzip

# Upgrade pip and install Python packages
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