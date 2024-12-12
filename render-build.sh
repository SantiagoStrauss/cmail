#!/usr/bin/env bash
set -e

# Install required Python packages
pip install --upgrade pip
pip install --upgrade 'selenium>=4.15.2' 'webdriver-manager>=4.0.1'

# Create Chrome directory in writable location 
CHROME_DIR="/opt/render/project/.chrome"
mkdir -p "$CHROME_DIR"

# Download and install Chrome
CHROME_VERSION="131.0.6778.108"
wget -q "https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${CHROME_VERSION}-1_amd64.deb"
dpkg -x google-chrome-stable_*_amd64.deb "$CHROME_DIR"
mv "$CHROME_DIR/usr/bin/google-chrome-stable" "$CHROME_DIR/chrome-linux64/chrome"
chmod +x "$CHROME_DIR/chrome-linux64/chrome"
rm google-chrome-stable_*_amd64.deb