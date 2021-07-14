#!/bin/bash

# Install Minikube if not present

if ! type "minikube" > /dev/null; then
  sudo apt-get update -y
  sudo apt-get upgrade -y
  sudo apt install virtualbox virtualbox-ext-pack
  wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
  sudo cp minikube-linux-amd64 /usr/local/bin/minikube
  sudo chmod 755 /usr/local/bin/minikube
fi

# Start Minikube
minikube start

# Build Docker image
eval $(minikube docker-env)
docker build -t python-app:1.0 .

# Set image previously built
sed -i "s/image: */image: python-app:1.0/" k8s/python-microservice.yaml

# Deploy on Minikube
kubectl apply -f k8s/mongodb-microservice.yaml
kubectl apply -f k8s/python-microservice.yaml