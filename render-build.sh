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
CHROME_VERSION="google-chrome-stable_current_amd64.deb"
wget -q "https://dl.google.com/linux/direct/${CHROME_VERSION}"

# Extract Chrome package
dpkg -x "${CHROME_VERSION}" "$CHROME_DIR"

# Copy the Chrome binary to the target directory
cp "$CHROME_DIR/opt/google/chrome/chrome" "$CHROME_LINUX_DIR/chrome"

# Set permissions
chmod +x "$CHROME_LINUX_DIR/chrome"

# Cleanup
rm -f "${CHROME_VERSION}"
rm -rf "$CHROME_DIR/opt"

# Verify installation
if [ ! -f "$CHROME_LINUX_DIR/chrome" ]; then
    echo "Chrome installation failed"
    exit 1
fi

echo "Chrome installation completed successfully"