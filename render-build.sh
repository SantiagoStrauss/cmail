#!/usr/bin/env bash

# Create Chrome directory
mkdir -p /opt/render/project/chrome-linux

# Download and install Google Chrome v114
echo "Installing Google Chrome v114"
wget https://dl.google.com/linux/chrome/deb/pool/main/g/google-chrome-stable/google-chrome-stable_114.0.5735.90-1_amd64.deb
dpkg-deb -x google-chrome-stable_114.0.5735.90-1_amd64.deb /opt/render/project/chrome-linux

# Install ChromeDriver v114
echo "Installing ChromeDriver v114"
wget https://chromedriver.storage.googleapis.com/114.0.5735.90/chromedriver_linux64.zip
unzip chromedriver_linux64.zip
chmod +x chromedriver
mkdir -p $HOME/bin
mv chromedriver $HOME/bin/chromedriver || echo "Could not move chromedriver to $HOME/bin"

# Add ChromeDriver to PATH
export PATH=$HOME/bin:$PATH

# Create symlink for Chrome binary
CHROME_PATH="/opt/render/project/chrome-linux/opt/google/chrome/chrome"
ln -s $CHROME_PATH /opt/render/project/chrome-linux/chrome || echo "Could not create symlink"

# Cleanup
rm google-chrome-stable_114.0.5735.90-1_amd64.deb chromedriver_linux64.zip

# Verify installation 
echo "Chrome version:"
$CHROME_PATH --version || echo "Chrome not found"
echo "ChromeDriver version:"
chromedriver --version || echo "ChromeDriver not found"