#! /bin/bash
# shellcheck disable=SC2164
cd /home/ubuntu
yes | sudo apt update
yes | sudo apt install python3 python3-pip
sudo git clone https://github.com/geekyrbhalala/python-rest-api.git
sleep 20
# shellcheck disable=SC2164
cd python-rest-api
yes | sudo pip3 install -r requirements.txt
echo 'Waiting for 30 seconds before running the app.py'
yes | sudo setsid python3 -u app.py &
sleep 30