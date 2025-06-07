#!/bin/bash
set -e

if systemctl is-active --quiet k3s-agent; then
  echo "[INFO] K3s agent already running. Skipping..."
  exit 0
fi

MASTER_IP="$1"
NODE_TOKEN="$2"

if [ -z "$MASTER_IP" ] || [ -z "$NODE_TOKEN" ]; then
  echo "[ERROR] Usage: $0 <MASTER_IP> <NODE_TOKEN>"
  exit 1
fi

echo "[INFO] Updating system..."
sudo apt-get update -y
sudo apt-get upgrade -y

echo "[INFO] Installing required dependencies..."
sudo apt-get install -y curl wget apt-transport-https ntpdate

echo "[INFO] Syncing time to avoid cert issues..."
sudo ntpdate pool.ntp.org

echo "[INFO] Disabling swap..."
sudo swapoff -a
sudo sed -i '/ swap / s/^/#/' /etc/fstab

echo "[INFO] Cleaning old K3s installs if any..."
sudo systemctl stop k3s-agent || true
sudo rm -rf /etc/rancher /var/lib/rancher /var/lib/kubelet /etc/systemd/system/k3s*

echo "[INFO] Installing K3s agent and joining the cluster..."
curl -sfL https://get.k3s.io | \
  K3S_URL="https://${MASTER_IP}:6443" \
  K3S_TOKEN="${NODE_TOKEN}" \
  sh -s - --node-name k3s-worker-$(hostname)

echo "[INFO] Verifying k3s-agent service..."
sudo systemctl status k3s-agent.service || true
sudo journalctl -xeu k3s-agent.service --no-pager -n 50 || true

echo "[SUCCESS] Worker node joined the K3s cluster!"
