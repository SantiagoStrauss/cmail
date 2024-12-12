#!/usr/bin/env bash
set -e  # Exit on error

# Create Chrome directory
mkdir -p /opt/render/project/chrome-linux

# Install latest stable Chrome
echo "Installing latest stable Chrome"
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
dpkg-deb -x google-chrome-stable_current_amd64.deb /opt/render/project/chrome-linux

# Get installed Chrome version
CHROME_PATH="/opt/render/project/chrome-linux/opt/google/chrome/chrome"
CHROME_VERSION=$($CHROME_PATH --version | cut -d ' ' -f 3 | cut -d '.' -f 1)
echo "Detected Chrome version: $CHROME_VERSION"

# Install matching ChromeDriver version
echo "Installing matching ChromeDriver"
CHROMEDRIVER_VERSION=$(curl -s "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_$CHROME_VERSION")
echo "Installing ChromeDriver version: $CHROMEDRIVER_VERSION"
wget "https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip"
unzip chromedriver_linux64.zip
chmod +x chromedriver
mkdir -p $HOME/bin
mv chromedriver $HOME/bin/chromedriver || echo "Could not move chromedriver to $HOME/bin"

# Add ChromeDriver to PATH
export PATH=$HOME/bin:$PATH

# Create symlink for Chrome binary
ln -s $CHROME_PATH /opt/render/project/chrome-linux/chrome || echo "Could not create symlink"

# Cleanup
rm google-chrome-stable_current_amd64.deb chromedriver_linux64.zip

# Verify installation 
echo "Chrome version:"
$CHROME_PATH --version || echo "Chrome not found"
echo "ChromeDriver version:"
chromedriver --version || echo "ChromeDriver not found"
