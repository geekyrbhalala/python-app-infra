# #! /bin/bash
# cd /home/ubuntu
# yes | sudo yum update
# yes | sudo apt install python3 python3-pip
# sudo git clone https://github.com/geekyrbhalala/python-rest-api.git
# sleep 20
# cd python-rest-api
# yes | sudo pip3 install -r requirements.txt
# echo 'Waiting for 30 seconds before running the app.py'
# yes | sudo setsid python3 -u app.py &
# sleep 30

#!/bin/bash

# Update the system
yum update -y

# Install Python 3 and pip
yum install -y python3 python3-pip

# Ensure pip is upgraded
pip3 install --upgrade pip

git clone https://github.com/geekyrbhalala/python-rest-api.git

sleep 20
cd python-rest-api

# Install requirements if requirements.txt exists
REQUIREMENTS_FILE="requirements.txt"
if [ -f "$REQUIREMENTS_FILE" ]; then
    pip3 install -r "$REQUIREMENTS_FILE"
else
    echo "requirements.txt not found. Skipping dependency installation."
fi

# Verify installation
python3 --version
pip3 --version
git --version