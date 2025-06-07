# 🚀 K3s‑on‑Azure Automation

This repository provisions **one master + two worker** Ubuntu VMs on Microsoft Azure with **Terraform** and turns them into a highly‑available **K3s** cluster – all driven by a single GitHub Actions workflow.

> **Why K3s?**
> K3s is a super‑lightweight, CNCF‑conformant Kubernetes distribution that boots fast and has a tiny footprint – perfect for edge labs, PoCs, or spot‑priced playgrounds where you still want the full Kubernetes API without the bloat.

---

## 🏗️ High‑Level Architecture

```text
┌────────────────────┐     GitHub Actions     ┌──────────────────┐
│  terraform-az-k3s  │ ─────────────────────▶ │  Azure Resource  │
│    (IaC code)      │                        │     Manager      │
└────────────────────┘                        └──────────────────┘
        │                                              │
        ▼ (apply)                                      ▼ (create)
┌────────────────────────────────────────────────────────────────┐
│                 3× Ubuntu VMs (spot/pre‑emptible)             │
│    • k3s-master (public IP)                                   │
│    • k3s-worker‑1 (public IP)                                 │
│    • k3s-worker‑2 (public IP)                                 │
└────────────────────────────────────────────────────────────────┘
         ▲              ▲
         │ SSH & SCP    │
         └──────────────┘
   k3s‑install scripts harden the nodes & bootstrap the cluster
```

---

## 📂 Repo Layout

| Path                           | Purpose                                                                            |
| ------------------------------ | ---------------------------------------------------------------------------------- |
| `terraform-az-k3s/`            | Terraform module that creates the RG, VNet, NSG, 3 VMs & outputs their public IPs. |
| `k3s-scripts/az-k3s-master.sh` | Installs K3s **server** (control‑plane) on the master.                             |
| `k3s-scripts/az-k3s-worker.sh` | Installs K3s **agent** on a worker and joins it to the master.                     |
| `.github/workflows/deploy.yml` | GitHub Actions workflow (shown below).                                             |

---

## 🔐 Required Secrets / Env Vars

| Secret name                          | What it is                                                                                                     | How to create                                                                                                              |
| ------------------------------------ | -------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `AZURE_CREDENTIALS`                  | JSON output of `az ad sp create-for-rbac --sdk-auth` with at least **Contributor** on the target subscription. | [https://github.com/azure/login#configure-azure-credentials](https://github.com/azure/login#configure-azure-credentials)   |
| `AZURE_SSH_PRIVATE_KEY`              | **Private** half of an RSA keypair allowed on the VMs (`$HOME/.ssh/id_rsa`).                                   | `ssh-keygen -t rsa -b 4096 -C "k3s-gha"`                                                                                   |
| (optional) self‑hosted runner labels | `ubuntu-spot-runner` in the workflow – change or remove if you’re using `ubuntu-latest`.                       | [https://docs.github.com/en/actions/hosting-your-own-runners](https://docs.github.com/en/actions/hosting-your-own-runners) |

Add them in **Repo → Settings → Secrets & Variables → Actions → New secret**.

---

## 🎯 Git Workflow Triggers

The pipeline decides what to do from the **latest commit message** **or** a manual dispatch:

| Trigger method                                            | What to write / select                                      | Result                                                                                                                           |
| --------------------------------------------------------- | ----------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| Commit message contains `terraform apply`                 | `git commit -m "feat: terraform apply – add node size var"` | • `terraform init`  → `terraform apply`<br>• Extract public IPs<br>• Install K3s master + workers<br>• Print `kubectl get nodes` |
| Commit message contains `terraform plan`                  | "terraform plan – dry‑run"                                  | `terraform plan` only                                                                                                            |
| Commit message contains `terraform destroy`               | "chore: terraform destroy"                                  | `terraform destroy` – tears down the RG & VMs                                                                                    |
| Any other commit                                          | Terraform won't be running                                                           | Workflow exits (noop)                                                                                                            |
| **Manual** – `Actions → Deploy Azure VMs… → Run workflow` | Choose **Action**=`plan`/`apply`/`destroy`                  | Same as above, but no commit needed                                                                                              |

Pro‑tip: you can alias these in your shell:

```bash
alias tf-apply='git commit --allow-empty -m "terraform apply" && git push'
alias tf-destroy='git commit --allow-empty -m "terraform destroy" && git push'
```

---

##  Next Steps

1. **Fork / clone** this repo.
2. Add the **two secrets** (and runner label if self‑hosting).
3. Push an empty commit with the message `terraform apply`.
4. Grab the kubeconfig from the master (`~/.kube/config` on the VM) or port‑forward your apps and enjoy.

Need to tear it all down?

```bash
git commit --allow-empty -m "terraform destroy" && git push
```

Everything—RG, NICs, disks, IPs—will vanish. 

---

## 🙋‍♂️ FAQ

| Question                       | Answer                                                                                                                            |
| ------------------------------ | --------------------------------------------------------------------------------------------------------------------------------- |
| *Why not AKS?*                 | K3s gives full control, spins up in < 2 min, costs only the VM price—no control‑plane fee. Great for demos & cost‑sensitive labs. |
| *Can I scale to more workers?* | Yes – tweak the `count` variable in Terraform, the script loops over all IP outputs automatically.                                |
| *Where are the logs?*          | GitHub Actions → select your run → **deploy\_k3s\_cluster** job. Each step is timestamped & downloadable.                         |

---

Happy hacking & may your pods always be **Running**! 🥑
