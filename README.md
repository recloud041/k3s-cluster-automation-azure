# k3s-cluster-automation-azure

This repository contains Terraform scripts and shell automation for deploying a **lightweight Kubernetes cluster (K3s)** on Azure VMs, including:

- 💠 One **Master Node**
- 🛠️ Multiple **Worker Nodes**

## 🔍 Why K3s?

K3s is a lightweight Kubernetes distribution, designed for:

- 💡 Low resource environments (perfect for VMs or edge devices)
- 🚀 Quick deployment and faster boot times
- 🧼 Reduced overhead by removing unnecessary components from standard Kubernetes

It's ideal for:

- Dev/Test Environments
- Edge Computing
- CI/CD Pipelines
- Lightweight cloud-native workloads

## 🔧 What This Project Does

This repo automates the full lifecycle of a K3s cluster on Azure:

1. **Provisioning Azure VMs** using Terraform
2. **Bootstrap scripts** to:
   - Install K3s on the master
   - Join worker nodes using the K3s token
3. **Remote Execution** of setup via shell scripts
4. Creates backend storage for Terraform state using an Azure storage account (configured in `backend.tf`)

## 📁 Folder Structure

```bash
k3s-cluster-automation-azure/
├── k3s-scripts/
│   ├── az-k3s-master.sh        # Installs K3s master
│   └── az-k3s-worker.sh        # Installs K3s agent and joins the cluster
├── terraform-az-k3s/
│   ├── backend.tf              # Remote state backend config
│   ├── main.tf                 # VM provisioning and network
│   └── variables.tf            # Variables and input values
└── README.md
