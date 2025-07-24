# Kubernetes Manifests - AKS Project

This directory contains all Kubernetes manifests for deploying the complete MLOps pipeline with monitoring, GitOps, and SSL termination.

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Load Balancer (Azure)                    │
│                External IP: Your-LB-IP                      │
└─────────────────────┬───────────────────────────────────────┘
                      │
┌─────────────────────▼───────────────────────────────────────┐
│               NGINX Ingress Controller                      │
│                  (ingress-nginx)                           │
└─────┬──────┬──────┬──────┬─────────────────────────────────┘
      │      │      │      │
      ▼      ▼      ▼      ▼
   aks.* argocd.* prom.* grafana.*
      │      │      │      │
┌─────▼──┐ ┌─▼────┐ ┌▼───┐ ┌▼─────┐
│   App  │ │ArgoCD│ │Prom│ │Grafana│
│ (app)  │ │(argo)│ │ (m)│ │  (m) │
└────────┘ └──────┘ └────┘ └──────┘
```

## 📁 Directory Structure

```
k8-manifests/
├── app/
│   ├── app.yml          # Main FastAPI application
│   └── argocd.yml       # ArgoCD deployment & GitOps config
├── cert-manager/
│   ├── core.yaml        # Cert-manager deployment
│   └── tls.yaml         # SSL certificates & Cloudflare issuer
├── ingress/
│   └── nginx.yaml       # NGINX Ingress Controller
├── monitoring/
│   ├── prometheus.yaml  # Prometheus deployment
│   ├── grafana.yaml     # Grafana deployment
│   └── ingress.yaml     # Monitoring ingress rules
└── deploy.sh           # Complete deployment script
```

## 🌐 Domain Mapping

All services are accessible via subdomains of `isaiahmichael.com`:

| Service | URL | Purpose |
|---------|-----|---------|
| **Main App** | `https://aks.isaiahmichael.com` | Image classification web interface |
| **ArgoCD** | `https://argocd.isaiahmichael.com` | GitOps dashboard |
| **Prometheus** | `https://prometheus.isaiahmichael.com` | Metrics collection |
| **Grafana** | `https://grafana.isaiahmichael.com` | Monitoring dashboards |

## 🚀 Quick Deployment

### Prerequisites

1. **AKS Cluster** running and `kubectl` configured
2. **Cloudflare API Token** with DNS edit permissions
3. **Docker Registry** access (ACR recommended)
4. **DNS Control** for `isaiahmichael.com`

### Step 1: Update Configuration

1. **Update Cloudflare API Token**:
   ```bash
   # Edit k8-manifests/cert-manager/tls.yaml
   # Replace "your-cloudflare-api-token-here" with your actual token
   ```

2. **Update Docker Registry**:
   ```bash
   # Edit k8-manifests/app/app.yml
   # Replace "your-registry/image-classifier:latest" with your image
   ```

3. **Update Git Repository**:
   ```bash
   # Edit k8-manifests/app/argocd.yml
   # Replace repo URL with your GitHub repository
   ```

### Step 2: Run Deployment

```bash
# Make script executable
chmod +x deploy.sh

# Run deployment
./deploy.sh
```

### Step 3: DNS Configuration

The script will output the LoadBalancer IP. Update your DNS records:

```
Type: A Record
Name: aks
Value: [LoadBalancer-IP]
TTL: 300

Type: A Record  
Name: argocd
Value: [LoadBalancer-IP]
TTL: 300

Type: A Record
Name: prometheus  
Value: [LoadBalancer-IP]
TTL: 300

Type: A Record
Name: grafana
Value: [LoadBalancer-IP]
TTL: 300
```

## 🔐 Security & Authentication

### SSL/TLS Certificates
- **Automatic**: Let's Encrypt via Cert-Manager
- **DNS Challenge**: Cloudflare DNS-01 validation
- **Renewal**: Automatic every 60 days

### Authentication
- **ArgoCD**: Built-in admin user
- **Monitoring**: Basic HTTP auth (admin/admin)
- **App**: Public access (as intended)

### Default Credentials
```
ArgoCD:     admin / [auto-generated]
Prometheus: admin / admin  
Grafana:    admin / admin123
```

⚠️ **Change these in production!**

## 📊 Monitoring Setup

### Prometheus Targets
- Kubernetes API server
- Node metrics
- Pod metrics with annotation:
  ```yaml
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: "80"
    prometheus.io/path: "/metrics"
  ```

### Grafana Dashboards
Post-deployment, import these dashboard IDs:
- **315**: Kubernetes cluster monitoring
- **747**: Kubernetes pod monitoring  
- **6417**: Kubernetes cluster overview

## 🔄 GitOps with ArgoCD

### Application Sync
ArgoCD automatically:
- Monitors the Git repository
- Syncs changes to the cluster
- Provides drift detection
- Self-heals applications

### Adding New Applications
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-new-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/isaiah1701/AKSProject.git
    targetRevision: main
    path: k8-manifests/my-new-app
  destination:
    server: https://kubernetes.default.svc
    namespace: my-namespace
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## 🐛 Troubleshooting

### Check Deployment Status
```bash
# Check all pods
kubectl get pods -A

# Check ingress
kubectl get ingress -A

# Check certificates
kubectl get certificates -A

# Check ArgoCD applications
kubectl get applications -n argocd
```

### Common Issues

**1. Certificates not issuing**
```bash
# Check cert-manager logs
kubectl logs -n cert-manager deployment/cert-manager

# Check certificate status
kubectl describe certificate -A
```

**2. Ingress not working**
```bash
# Check NGINX controller
kubectl logs -n ingress-nginx deployment/ingress-nginx-controller

# Check service
kubectl get svc -n ingress-nginx
```

**3. ArgoCD sync issues**
```bash
# Check ArgoCD server logs
kubectl logs -n argocd deployment/argocd-server

# Manual sync
kubectl patch application image-classifier-app -n argocd --type merge -p '{"operation":{"sync":{}}}'
```

## 🔧 Customization

### Scaling Applications
```bash
# Scale app replicas
kubectl scale deployment image-classifier -n app --replicas=5

# Or update in app.yml and let ArgoCD sync
```

### Adding Monitoring Targets
```yaml
# In your deployment
annotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "8080"
  prometheus.io/path: "/metrics"
```

### Custom Ingress Rules
```yaml
# Add to existing ingress or create new
- host: api.isaiahmichael.com
  http:
    paths:
    - path: /api
      pathType: Prefix
      backend:
        service:
          name: my-api-service
          port:
            number: 8080
```

## 📈 Production Considerations

1. **Resource Limits**: Set appropriate CPU/Memory limits
2. **Persistent Storage**: Add PVCs for stateful services
3. **Backup Strategy**: Regular etcd and persistent volume backups
4. **Network Policies**: Implement pod-to-pod communication rules
5. **Image Security**: Scan images and use signed containers
6. **RBAC**: Implement least-privilege access controls

## 🎯 Next Steps

1. **Configure Azure Monitor** integration
2. **Set up Azure Key Vault** for secrets
3. **Implement Azure AD** authentication
4. **Add health checks** and alerting
5. **Configure backup policies**
6. **Set up disaster recovery**
