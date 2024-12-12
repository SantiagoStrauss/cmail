#!/usr/bin/env bash
set -e

# Install required Python packages
pip install --upgrade pip
pip install --upgrade 'selenium>=4.15.2' 'webdriver-manager>=4.0.1'

# Create Chrome directories
CHROME_DIR="/opt/render/project/.chrome"
CHROME_LINUX_DIR="${CHROME_DIR}/chrome-linux64"
mkdir -p "$CHROME_LINUX_DIR"

# Download and install Chrome
CHROME_VERSION="131.0.6778.108"
wget -q "https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_${CHROME_VERSION}-1_amd64.deb"

# Extract Chrome package
dpkg -x google-chrome-stable_*_amd64.deb "$CHROME_DIR"

# Create chrome-linux64 directory and move binary
mkdir -p "$CHROME_LINUX_DIR"
cp "$CHROME_DIR/usr/bin/google-chrome-stable" "$CHROME_LINUX_DIR/chrome"

# Set permissions
chmod +x "$CHROME_LINUX_DIR/chrome"

# Cleanup
rm -f google-chrome-stable_*_amd64.deb
rm -rf "$CHROME_DIR/usr"

# Verify installation
if [ ! -f "$CHROME_LINUX_DIR/chrome" ]; then
    echo "Chrome installation failed"
    exit 1
fi

echo "Chrome installation completed successfully"