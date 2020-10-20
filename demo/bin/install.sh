#!/bin/bash

###------------------------------------------------------------------###
### Helper script for installing docker and Kubernetes on Ubuntu 20  ###
###------------------------------------------------------------------###

# install docker
echo "installing docker...."
apt update
apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"

apt update
apt-cache policy docker-ce
apt install docker-ce
systemctl status docker

# If you want to avoid typing sudo whenever you run the docker command, add your username to the docker group:
usermod -aG docker ${USER}
su - ${USER}
id -nG
docker info

# install kubernetes
echo "installing kubernetes...."
sudo snap install microk8s --classic
microk8s.status
snap alias microk8s.kubectl kubectl
microk8s.kubectl config view --raw > $HOME/.kube/config