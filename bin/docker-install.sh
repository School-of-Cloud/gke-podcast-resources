#!/bin/bash

###------------------------------------------------------------------###
### Helper script for installing docker on Ubuntu 20  ###
###------------------------------------------------------------------###

# install docker
echo "installing docker...."
apt update
apt install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"

apt update
apt-cache policy docker-ce
apt install -y docker-ce
systemctl status docker

# If you want to avoid typing sudo whenever you run the docker command, add your username to the docker group:
usermod -aG docker ${USER}
su - ${USER}
id -nG
docker info