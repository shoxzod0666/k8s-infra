# Kubernetes Infrastructure Project
Production-ready Kubernetes cluster deployed on bare-metal VPS with full GitOps, CI/CD, monitoring and logging stack.
## Architecture

Internet
│
▼
Nginx Ingress Controller (HTTPS/SSL)
│
▼
┌─────────────────────────────────────┐
│ Kubernetes Cluster │
│ │
│ ┌──────────┐ ┌──────────────┐ │
│ │ node1 │ │ node2 │ │
│ │ (master) │ │ (worker) │ │
│ └──────────┘ └──────────────┘ │
│ │
│ ┌─────────────────────────────┐ │
│ │ Google Microservices Demo │ │
│ │ (10 microservices) │ │
│ └─────────────────────────────┘ │
│ │
│ ┌──────────┐ ┌────────────────┐ │
│ │Prometheus│ │ Grafana │ │
│ │ │->│ + Loki logs │ │
│ └──────────┘ └────────────────┘ │
│ │
│ ┌──────────┐ ┌────────────────┐ │
│ │ ArgoCD │ │ Longhorn │ │
│ │ (GitOps) │ │ (Storage) │ │
│ └──────────┘ └────────────────┘ │
└─────────────────────────────────────┘

## Stack

| Tool | Purpose |
|------|---------|
| Kubernetes (Kubespray) | Container orchestration |
| Nginx Ingress | Traffic routing |
| cert-manager + Let's Encrypt | SSL certificates |
| Longhorn | Distributed storage |
| Prometheus + Grafana | Monitoring & metrics |
| Loki + Promtail | Log aggregation |
| ArgoCD | GitOps deployment |
| Jenkins | CI/CD pipeline |
| Terraform | Infrastructure as Code |
| GitHub Actions | Automated CI/CD |
| Helm | Kubernetes package manager |

## Infrastructure

- **Nodes:** 2x Contabo VPS (4 vCPU, 8GB RAM, 150GB SSD)
- **OS:** Ubuntu 22.04
- **Kubernetes:** v1.32 (Kubespray)
- **Network:** Calico CNI
- **Storage:** Longhorn (distributed, 2 replicas)

## Services

| Service | URL |
|---------|-----|
| Online Boutique | https://173.249.57.192.sslip.io |
| Grafana | https://grafana.173.249.57.192.sslip.io |
| ArgoCD | https://argocd.173.249.57.192.sslip.io |
| Jenkins | https://jenkins.173.249.57.192.sslip.io |

## Repository Structure

k8s-infra/
├── terraform/ # Infrastructure as Code
├── ingress-nginx/ # Nginx Ingress Helm values
├── cert-manager/ # cert-manager config + ClusterIssuer
├── longhorn/ # Longhorn storage config
├── monitoring/ # Prometheus + Grafana Helm values
├── loki/ # Loki logging Helm values
├── promtail/ # Promtail agent config
├── argocd/ # ArgoCD Ingress
├── jenkins/ # Jenkins Helm values
└── microservices/ # Microservices Ingress

## Quick Start

### Prerequisites
- kubectl
- helm
- terraform

### Deploy infrastructure with Terraform
```bash
cd terraform
terraform init
terraform apply
```

### Deploy microservices
```bash
kubectl apply -f microservices/ingress.yaml
```

## CI/CD Flow

Developer pushes code
│
▼
GitHub Actions triggered
│
▼
Docker image built & pushed to ghcr.io
│
▼
kubectl set image (rolling update)
│
▼
ArgoCD syncs Git state to cluster

