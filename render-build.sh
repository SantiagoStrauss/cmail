#!/usr/bin/env bash

set -e # Exit on error

# Create Chrome directories
mkdir -p /opt/render/project/chrome

# Download and install Chrome
echo "Installing Google Chrome..."
wget -q https://storage.googleapis.com/chrome-for-testing-public/131.0.6778.108/linux64/chrome-linux64.zip
unzip -q chrome-linux64.zip
mv chrome-linux64/* /opt/render/project/chrome/
rm -rf chrome-linux64.zip chrome-linux64

# Install ChromeDriver
echo "Installing ChromeDriver..."
wget -q https://storage.googleapis.com/chrome-for-testing-public/131.0.6778.108/linux64/chromedriver-linux64.zip
unzip -q chromedriver-linux64.zip
chmod +x chromedriver-linux64/chromedriver
mkdir -p /opt/render/project/bin
mv chromedriver-linux64/chromedriver /opt/render/project/bin/
rm -rf chromedriver-linux64.zip chromedriver-linux64

# Add ChromeDriver to PATH
export PATH="/opt/render/project/bin:$PATH"

# Create symlink for Chrome binary
ln -sf /opt/render/project/chrome/chrome /usr/bin/chrome

# Verify installation
echo "Chrome version:"
/opt/render/project/chrome/chrome --version || echo "Chrome not found"
echo "ChromeDriver version:"
chromedriver --version || echo "ChromeDriver not found"