#!/bin/bash

# Exit script on error
set -e

# Update the system
yum update -y

# Install required packages
yum install -y python3 python3-pip git

# Upgrade pip using yum to avoid conflicts
yum upgrade -y python3-pip

# Clone the GitHub repository
REPO_URL="https://github.com/geekyrbhalala/python-rest-api.git"
TARGET_DIR="python-rest-api"

if [ -d "$TARGET_DIR" ]; then
    echo "Directory $TARGET_DIR already exists. Deleting and re-cloning..."
    rm -rf "$TARGET_DIR"
fi

git clone "$REPO_URL"

# Ensure the repository was cloned successfully
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Failed to clone repository."
    exit 1
fi

cd "$TARGET_DIR"

# Install requirements if requirements.txt exists
REQUIREMENTS_FILE="requirements.txt"
if [ -f "$REQUIREMENTS_FILE" ]; then
    python3 -m pip install -r "$REQUIREMENTS_FILE"
else
    echo "requirements.txt not found. Skipping dependency installation."
fi

echo 'Waiting for 30 seconds before running the app.py'
yes | sudo setsid python3 -u app.py &
sleep 30

echo "Setup completed successfully!"
