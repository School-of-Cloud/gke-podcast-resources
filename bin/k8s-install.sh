#!/bin/bash

###------------------------------------------------------------------###
### Helper script for installing Kubernetes on Ubuntu 20  ###
###------------------------------------------------------------------###

echo "installing kubernetes...."
snap install microk8s --classic
microk8s.status
snap alias microk8s.kubectl kubectl
microk8s.kubectl config view --raw > $HOME/.kube/config