#!/usr/bin/env bash
set -e

# Install required Python packages
pip install --upgrade pip
pip install --upgrade selenium webdriver-manager

# Create Chrome directory in writable location 
CHROME_DIR="/opt/render/project/.chrome"
mkdir -p "$CHROME_DIR"

# Install Chrome
echo "Installing Chrome..."
wget -q https://storage.googleapis.com/chrome-for-testing-public/131.0.6778.108/linux64/chrome-linux64.zip
unzip -q chrome-linux64.zip -d "$CHROME_DIR"
chmod +x "$CHROME_DIR/chrome-linux64/chrome"

# Export Chrome path
export CHROME_BINARY="$CHROME_DIR/chrome-linux64/chrome"

# Verify Chrome
echo "Verifying Chrome installation..."
"$CHROME_BINARY" --version || echo "Chrome verification failed"

# Cleanup
rm -f chrome-linux64.zip