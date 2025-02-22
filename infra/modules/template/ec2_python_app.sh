#!/bin/bash

# Exit on any error
set -e

# Change to home directory with error handling
cd /home/ubuntu || {
    echo "Failed to cd to /home/ubuntu" >&2
    exit 1
}

# Update package list and install dependencies
sudo apt update -y
sudo apt install -y python3 python3-pip git python3-venv

# Clone the repository
git clone https://github.com/geekyrbhalala/python-rest-api.git

# Change to app directory with error handling
cd python-rest-api || {
    echo "Failed to cd to python-rest-api" >&2
    exit 1
}

# Create and activate virtual environment
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
pip install flask boto3  # Replace with -r requirements.txt if it exists and is correct

# Create systemd service for persistence
cat <<EOF | sudo tee /etc/systemd/system/flask-app.service
[Unit]
Description=Flask REST API
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/home/ubuntu/python-rest-api
ExecStart=/home/ubuntu/python-rest-api/venv/bin/python /home/ubuntu/python-rest-api/app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Start and enable the service
sudo systemctl daemon-reload
sudo systemctl enable flask-app
sudo systemctl start flask-app

echo "Setup complete. Flask app should be running."
# #! /bin/bash
# # shellcheck disable=SC2164
# cd /home/ubuntu
# yes | sudo apt update
# yes | sudo apt install python3 python3-pip
# sudo git clone https://github.com/geekyrbhalala/python-rest-api.git
# sleep 20
# # shellcheck disable=SC2164
# cd python-rest-api
# yes | sudo apt install python3.12-venv
# sudo python3 -m venv venv
# source venv/bin/activate
# yes | sudo pip3 install -r requirements.txt

# echo 'Waiting for 30 seconds before running the app.py'
# yes | sudo setsid python3 -u app.py &
# sleep 30