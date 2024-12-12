#!/usr/bin/env bash

set -e # Exit on error

# Set up directories
CHROME_DIR="/opt/render/project/chrome"
DRIVER_DIR="/opt/render/project/chromedriver"

mkdir -p "$CHROME_DIR" "$DRIVER_DIR"

# Install Chrome
echo "Installing Chrome..."
wget -q https://storage.googleapis.com/chrome-for-testing-public/131.0.6778.108/linux64/chrome-linux64.zip
unzip -q chrome-linux64.zip
mv chrome-linux64/* "$CHROME_DIR/"
rm -rf chrome-linux64.zip chrome-linux64

# Install ChromeDriver
echo "Installing ChromeDriver..."
wget -q https://storage.googleapis.com/chrome-for-testing-public/131.0.6778.108/linux64/chromedriver-linux64.zip
unzip -q chromedriver-linux64.zip
mv chromedriver-linux64/chromedriver "$DRIVER_DIR/"
rm -rf chromedriver-linux64.zip chromedriver-linux64

# Set up environment
export PATH="$DRIVER_DIR:$PATH"
export CHROME_PATH="$CHROME_DIR/chrome"

# Verify installation
echo "Chrome version:"
"$CHROME_PATH" --version || echo "Chrome not found"
echo "ChromeDriver version:"
"$DRIVER_DIR/chromedriver" --version || echo "ChromeDriver not found"