#!/usr/bin/env bash
set -e

# Install required Python packages
pip install --upgrade pip
pip install --upgrade 'selenium>=4.15.2' 'webdriver-manager>=4.0.1'

# Create Chrome directories
CHROME_DIR="/opt/render/project/.chrome"
CHROME_LINUX_DIR="${CHROME_DIR}/chrome-linux64"
mkdir -p "$CHROME_LINUX_DIR"

# Download and extract Chrome
wget -q "https://storage.googleapis.com/chrome-for-testing-public/131.0.6778.108/linux64/chrome-linux64.zip"
unzip chrome-linux64.zip -d "$CHROME_LINUX_DIR"

# Copy the Chrome binary to the target directory
cp "$CHROME_LINUX_DIR/chrome" "$CHROME_LINUX_DIR/chrome"

# Set permissions
chmod +x "$CHROME_LINUX_DIR/chrome"

# Cleanup
rm -f chrome-linux64.zip

# Verify installation
if [ ! -f "$CHROME_LINUX_DIR/chrome" ]; then
    echo "Chrome installation failed"
    exit 1
fi

echo "Chrome installation completed successfully"
