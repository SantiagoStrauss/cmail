#!/usr/bin/env bash
set -e

# Install required Python packages
pip install --upgrade pip
pip install --upgrade 'selenium>=4.15.2' 'webdriver-manager>=4.0.1'

# Create Chrome directory in writable location 
CHROME_DIR="/opt/render/project/.chrome"
mkdir -p "$CHROME_DIR"

# Install specific Chrome version
CHROME_VERSION=