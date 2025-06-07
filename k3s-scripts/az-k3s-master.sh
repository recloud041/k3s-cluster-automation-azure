#!/bin/bash

set -e

if systemctl is-active --quiet k3s; then
  echo "[INFO] K3s is already running. Skipping..."
  exit 0
fi

echo "[INFO] Updating system..."
sudo apt-get update -y
sudo apt-get upgrade -y

echo "[INFO] Installing dependencies..."
sudo apt-get install -y curl wget apt-transport-https

echo "[INFO] Disabling swap..."
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

echo "[INFO] Installing K3s master node..."
curl -sfL https://get.k3s.io | sh -

echo "[INFO] Waiting for K3s to stabilize..."
sleep 10

echo "[INFO] Node status:"
sudo k3s kubectl get node

echo "[INFO] Node token:"
sudo cat /var/lib/rancher/k3s/server/node-token

echo "[INFO] Setting up kubeconfig for local use..."
mkdir -p $HOME/.kube
sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

echo "[INFO] Replacing 127.0.0.1 with Azure public IP in kubeconfig..."
AZURE_IP=$(curl -H Metadata:true "http://169.254.169.254/metadata/instance/network/interface/0/ipv4/ipAddress/0/publicIpAddress?api-version=2021-02-01&format=text" || echo "127.0.0.1")
sed -i "s/127.0.0.1/$AZURE_IP/" $HOME/.kube/config

echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> ~/.bashrc

sudo chmod 644 /etc/rancher/k3s/k3s.yaml
