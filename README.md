# AKS MLOps Pipeline Infrastructure with GitOps, CI/CD, Security, and Monitoring

## Overview

This project provisions a production-grade Kubernetes cluster on Azure using AKS (Azure Kubernetes Service) to deploy and manage a FastAPI-based machine learning application. The app is hosted at `aks.isaiahmichael.com` and includes endpoints for image classification using MobileNetV2, health checks, and API documentation.

The infrastructure is built using Terraform, GitHub Actions, and ArgoCD for GitOps-based deployment. It includes automated TLS certificates, DNS management with Cloudflare, RBAC access control, and a full observability stack using Prometheus and Grafana for comprehensive monitoring.

The goal was to build a secure, scalable, and fully automated MLOps environment that reflects real-world DevOps workflows used in production AI/ML teams.

> **Note**: This is a production-ready demonstration project showcasing AKS, MLOps, and cloud-native technologies.

Source code available at: [github.com/isaiah1701/AKSProject](https://github.com/isaiah1701/AKSProject)

## Key Features

• **Azure AKS** - A fully managed Kubernetes platform on Azure ☁️, used here to run the ML application with built-in scaling, high availability, and native Azure service integration.

• **Terraform Infrastructure as Code** - Modular Terraform code 📦 provisions all infrastructure components — including VNet, resource groups, AKS cluster, ACR — with remote state stored in Azure Storage backend.

• **CI/CD Pipelines**
  ◦ Terraform validation pipeline validates, plans, and applies infrastructure configurations with automated error handling ⚙️.
  ◦ Application pipeline handles:
   ■ Checkov 🔍 for static analysis of Terraform security and compliance.
   ■ Docker image builds 🛠️ and publishing to Azure Container Registry (ACR).
   ■ Trivy 🧪 to scan images for vulnerabilities.
   ■ Deployment to AKS using Kubernetes manifests 🚀.

• **GitOps with ArgoCD** - ArgoCD syncs application state from Git to the cluster 🔁. This powers consistent, version-controlled updates to the ML application with no manual intervention.

• **Helm Charts** - Used to install and configure Kubernetes tools like ArgoCD, Cert-Manager, Prometheus, and Grafana 🧩 — making the environment easy to reproduce.

• **Cert-Manager** - Handles HTTPS certificate issuance and renewal automatically 🔐 via Let's Encrypt, securing public-facing services without manual effort.

• **ExternalDNS** - Automatically manages DNS records in Cloudflare 🌍 based on Kubernetes ingress resources — keeping domain routing up to date during deployments.

• **Prometheus and Grafana** - Delivers observability 📊 with real-time metrics collection and dashboards tracking pod health, resource usage, ML model performance, and system metrics.

• **RBAC (Role-Based Access Control)** - Access to the cluster is restricted 🛡️ using namespace-level and cluster-wide permissions, following least privilege principles.

## Architecture

### System Overview

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Cloudflare    │────│   External DNS   │────│   cert-manager  │
│   DNS & Proxy   │    │   Auto DNS Mgmt  │    │   SSL Certs     │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                │
                    ┌──────────────────┐
                    │  Ingress NGINX   │
                    │  Load Balancer   │
                    └──────────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        │                       │                       │
┌───────▼───────┐    ┌──────────▼──────────┐    ┌───────▼───────┐
│   FastAPI     │    │     Monitoring      │    │    ArgoCD     │
│ ML Classifier │    │ Prometheus/Grafana  │    │   GitOps      │
│ aks.domain    │    │ prometheus.domain   │    │ argocd.domain │
└───────────────┘    └─────────────────────┘    └───────────────┘
```

### Key Architectural Components

**Control Plane (Azure Managed)**
• AKS master nodes managed by Azure
• API server, etcd, scheduler, and controller manager

**Data Plane (Customer Managed)**
• Azure VM worker nodes in private subnets
• FastAPI ML application pods and system components
• Load balancers and ingress controllers

**Application Layer**
• FastAPI ML application at aks.isaiahmichael.com
• Image classification API using MobileNetV2
• Health checks and API documentation endpoints
• Docker containerized microservices

**GitOps Layer**
• ArgoCD for declarative deployments
• Git repositories as single source of truth
• Automated synchronization and rollback capabilities

**Security & Access**
• Azure AD integration and service principals
• RBAC for fine-grained permissions
• Network security groups and policies

**Observability Stack**
• Prometheus for metrics collection from FastAPI app and infrastructure
• Grafana for visualization and ML model monitoring
• Centralized logging and performance tracking

**Automation & DNS**
• Cert-Manager for automatic SSL/TLS certificates
• ExternalDNS for dynamic DNS record management with Cloudflare
• Helm for package management and application deployments

## CI/CD Pipeline Architecture

This project implements two complementary GitHub Actions workflows that automate infrastructure provisioning, security scanning, and ML application deployment.

### Pipeline 1: Infrastructure Validation & Deployment

**File**: `.github/workflows/TerraformCheck.yaml`

#### What it does:
This pipeline handles the infrastructure layer - creating and managing your AKS cluster and Azure resources.

#### Workflow Steps:
1. **Security Scanning with Checkov** 🔍
   ◦ Scans Terraform code for misconfigurations and security violations
   ◦ Checks for Azure best practices (encrypted storage, proper IAM, etc.)
   ◦ Continues deployment even if issues found (warnings only)

2. **Terraform Infrastructure Management** 🏗️
   ◦ Validates Terraform syntax and configuration
   ◦ Plans changes to show what will be created/modified
   ◦ Applies changes to provision AKS cluster, VNet, Resource Groups, ACR, etc.
   ◦ Uses Azure Storage backend for state management

3. **Error Handling** ⚠️
   ◦ Gracefully handles existing resources
   ◦ Continues workflow even if some steps fail
   ◦ Provides detailed status summaries

#### Triggers:
• Pushes to `main` or `develop` branches
• Changes to any Terraform files or workflow

### Pipeline 2: Application Build & Deployment

**File**: `.github/workflows/docker-build.yaml` (if exists)

#### What it does:
This pipeline handles the application layer - building, scanning, and deploying your FastAPI ML application.

#### Workflow Steps:
1. **Docker Image Build** 🐳
   ◦ Builds Docker image from `app/`
   ◦ Tags with commit SHA for version tracking
   ◦ Pushes to Azure Container Registry (ACR)

2. **Security Scanning with Trivy** 🧪
   ◦ Scans Docker images for vulnerabilities
   ◦ Checks for known CVEs in ML dependencies
   ◦ Reports CRITICAL, HIGH, MEDIUM, LOW severity issues
   ◦ Never blocks deployment (security awareness, not gates)

3. **Kubernetes Deployment** 🚀
   ◦ Updates Kubernetes manifests with new image tag
   ◦ ArgoCD syncs changes from Git to AKS cluster
   ◦ Forces pod restart to pull new ML model image
   ◦ Waits for successful rollout

#### Triggers:
• Pushes to `main` branch
• Only when files in `app/` directory change

### Key Pipeline Features

#### Security-First Approach 🔒
• Checkov scans infrastructure code for Azure security best practices
• Trivy scans container images for known vulnerabilities in ML libraries
• Both tools provide warnings without blocking deployment

#### Automated State Management 📊
• Terraform state stored in Azure Storage with state locking
• Prevents concurrent modifications and state corruption
• Enables team collaboration on infrastructure

#### GitOps Integration ⚡
• Pipeline updates Git repository with new image tags
• ArgoCD automatically syncs changes to AKS cluster
• Full audit trail of deployments through Git history

#### Environment Isolation 🏗️
• Each pipeline has specific triggers and permissions
• Infrastructure and application deployments are independent
• Supports different ML development workflows

## Monitoring Stack

### Demo Videos

#### Application Overview - Complete FastAPI ML Application Walkthrough

https://github.com/isaiah1701/AKSProject/assets/your-user-id/docs/AKS.mp4

*Complete walkthrough of the FastAPI ML application showing image classification endpoints, health checks, and API documentation.*

#### ArgoCD GitOps - Deployment Synchronization and Management  

https://github.com/isaiah1701/AKSProject/assets/your-user-id/docs/aksArgoCD.mp4

*Demonstration of ArgoCD sync processes, configuration management, and GitOps workflow for continuous deployment.*

#### Grafana Dashboards - Real-time Monitoring and Visualization

https://github.com/isaiah1701/AKSProject/assets/your-user-id/docs/aksGrafana.mp4

*Real-time monitoring dashboards showing application metrics, infrastructure performance, and ML model monitoring.*

#### Prometheus Metrics - Data Collection and Alerting

https://github.com/isaiah1701/AKSProject/assets/your-user-id/docs/aksPrometheus.mp4

*Metrics collection setup, custom alerts configuration, and performance monitoring for the ML application.*

### Prometheus
- **URL**: https://prometheus.isaiahmichael.com
- **Metrics**: Application, infrastructure, ML model performance, and Kubernetes metrics
- **Alerting**: Configure alerts for critical thresholds and ML model drift

### Grafana  
- **URL**: https://grafana.isaiahmichael.com
- **Default Login**: admin/[generated-password]
- **Dashboards**: Pre-configured for Kubernetes, application monitoring, and ML metrics

### Application Logs
```bash
# View ML application logs
kubectl logs -n default deployment/fastapi-app -f

# View all pod logs in namespace
kubectl logs -n default -l app=fastapi-app --tail=100
```

## Setup Instructions

### Prerequisites
• Azure CLI configured with appropriate permissions
• kubectl installed
• Helm 3.x installed
• Terraform installed
• Valid domain name with Cloudflare DNS management

### 1. Repository Setup
```bash
git clone https://github.com/isaiah1701/AKSProject
cd AKSProject
```

### 2. Infrastructure Provisioning
```bash
# Initialize and apply Terraform configuration
cd terraform
terraform init
terraform plan
terraform apply

# Configure kubectl to connect to your new cluster
az aks get-credentials --resource-group <resource-group> --name <cluster-name>

# Verify cluster connectivity
kubectl get nodes
```

### 3. ArgoCD Installation
```bash
# Run the automated ArgoCD installation script
./k8-manifests/argocd/install-argocd.sh

# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

### 4. Certificate Management
```bash
# Apply cert-manager configuration
kubectl apply -f k8-manifests/cert-manager/

# Verify installation
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=cert-manager -n cert-manager --timeout=300s
```

### 5. Monitoring Stack
```bash
# Install Prometheus and Grafana using Helm
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

kubectl create namespace monitoring
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring

# Apply monitoring ingresses
kubectl apply -f k8-manifests/monitoring/
```

### 6. DNS Automation
```bash
# Configure ExternalDNS with Cloudflare
kubectl apply -f k8-manifests/cert-manager/external-dns.yaml

# Verify DNS automation is working
kubectl logs -n external-dns deployment/external-dns --tail=20
```

### Verification & Access

Once all components are deployed, you can access:

| Service | URL | Credentials |
|---------|-----|-------------|
| FastAPI ML App | https://aks.isaiahmichael.com | - |
| ArgoCD | https://argocd.isaiahmichael.com | admin / [password from step 3] |
| Grafana | https://grafana.isaiahmichael.com | admin / [generated-password] |
| Prometheus | https://prometheus.isaiahmichael.com | - |

#### Health Checks
```bash
# Verify all pods are running
kubectl get pods --all-namespaces

# Check certificate status
kubectl get certificates --all-namespaces

# Verify ingress configurations
kubectl get ingress --all-namespaces
```

## Troubleshooting

### Common Issues:
• **Certificate not ready**: Wait 2-3 minutes for Let's Encrypt validation
• **DNS records not created**: Verify Cloudflare API token permissions
• **Pod startup failures**: Check resource limits and node capacity
• **Access denied**: Verify RBAC configuration and Azure service principal permissions

### Useful Commands:
```bash
# Check pod logs
kubectl logs -f <pod-name> -n <namespace>

# Describe resources for troubleshooting
kubectl describe <resource-type> <resource-name> -n <namespace>

# Check cluster events
kubectl get events --sort-by='.lastTimestamp' -A
```

### Cleanup
To tear down the entire infrastructure:
```bash
# Remove Kubernetes resources first
helm uninstall monitoring -n monitoring
kubectl delete -f k8-manifests/

# Destroy Azure infrastructure
cd terraform
terraform destroy
```

## Why This Setup Adds Real Value in a Production Environment

**ArgoCD for Reliable, Versioned Deployments** - ArgoCD enables consistent, auditable deployments directly from Git. It reduces manual errors, supports rollback, and fits cleanly into CI/CD workflows for team-based ML delivery.

**AKS for Scalability and Azure Integration** - Using Azure AKS provides a managed, production-grade Kubernetes environment. It handles scaling and availability out of the box, while integrating with other Azure services like Azure AD, VNet, and Azure Monitor.

**HTTPS and Access Control Built In** - Cert-Manager automates certificate management using Let's Encrypt, removing the need for manual renewal or provisioning. RBAC is used to control access at both the namespace and cluster level.

**CI/CD Pipelines with Security Checks** - Pipelines are set up to:
• Scan Terraform code with Checkov for misconfigurations
• Build and push Docker images to ACR
• Scan those images with Trivy before deployment
• Deploy to AKS via GitOps with ArgoCD

This approach helps catch security issues early and keeps ML deployments consistent.

**Automated DNS with ExternalDNS** - ExternalDNS integrates with Cloudflare to update DNS records automatically based on Kubernetes ingress changes. It removes the need for manual updates and speeds up ML model deployments.

**Monitoring with Prometheus and Grafana** - Prometheus collects application and infrastructure metrics, including ML model performance, and Grafana displays them in real-time dashboards. This makes it easier to track model performance and catch issues before they impact users.

## Infrastructure Components

**VNet (Virtual Network)**: Provides a secure, isolated network environment for the cluster
**AKS (Azure Kubernetes Service)**: Manages the Kubernetes control plane and worker nodes
**ACR (Azure Container Registry)**: Stores and manages Docker container images
**ArgoCD**: Manages application deployments based on Git repositories
**Helm**: Deploys and manages Kubernetes resources using Helm charts
**Cert-Manager**: Handles SSL/TLS certificate issuance and renewal
**ExternalDNS**: Automates DNS record updates in Cloudflare