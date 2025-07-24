# AKS MLOps Pipeline with FastAPI Image Classification

A production-ready Azure Kubernetes Service (AKS) MLOps pipeline featuring FastAPI image classification, comprehensive monitoring, GitOps deployment, SSL certificates, and automatic DNS management.

## 🚀 Features

- **🤖 AI/ML Application**: FastAPI service with MobileNetV2 image classification
- **📊 Monitoring Stack**: Prometheus & Grafana with custom dashboards
- **🔄 GitOps**: ArgoCD for automatic deployment and synchronization
- **🔒 SSL/TLS**: Automatic certificate management with Let's Encrypt
- **🌐 DNS Management**: Automatic DNS record creation with Cloudflare
- **☁️ Cloud Infrastructure**: Terraform-managed AKS cluster
- **🛡️ Security**: Secure secrets management and ingress configuration

## 🏗️ Architecture

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
│ Image Classify │    │ Prometheus/Grafana  │    │   GitOps      │
│ aks.domain    │    │ prometheus.domain   │    │ argocd.domain │
└───────────────┘    └─────────────────────┘    └───────────────┘
```

## 🎯 Subdomains

The application uses the following subdomains under `isaiahmichael.com`:

- **`aks.isaiahmichael.com`** - FastAPI image classification service
- **`prometheus.isaiahmichael.com`** - Prometheus monitoring dashboard
- **`grafana.isaiahmichael.com`** - Grafana visualization dashboard  
- **`argocd.isaiahmichael.com`** - ArgoCD GitOps interface

## 🚀 Quick Start

### Prerequisites

1. **Azure CLI** and **kubectl** installed
2. **Terraform** installed
3. **Docker** installed (for building images)
4. **Cloudflare account** with API token
5. **Domain** managed by Cloudflare (`isaiahmichael.com`)

### 1. Infrastructure Setup

```bash
# Navigate to terraform directory
cd terraform

# Initialize and plan
terraform init
terraform plan

# Apply infrastructure
terraform apply
```

### 2. Connect to AKS Cluster

```bash
# Get cluster credentials
az aks get-credentials --resource-group <resource-group> --name <cluster-name>

# Verify connection
kubectl cluster-info
```

### 3. Secure External DNS Setup

**Important**: Never commit your Cloudflare API token to Git!

```bash
# Method 1: Environment variable (recommended for CI/CD)
export CLOUDFLARE_API_TOKEN="your_cloudflare_api_token"
./setup-external-dns.sh

# Method 2: Secure file (recommended for local development)
echo "your_cloudflare_api_token" > .cloudflare-token
./setup-external-dns.sh
```

See [`EXTERNAL-DNS-GUIDE.md`](./EXTERNAL-DNS-GUIDE.md) for detailed setup instructions.

### 4. Deploy the Complete Stack

```bash
# Run the automated deployment script
./deploy.sh
```

This script will:
- Deploy ingress-nginx controller
- Set up cert-manager and External DNS (with secure token injection)
- Configure SSL certificates for all subdomains
- Deploy monitoring stack (Prometheus & Grafana)
- Deploy ArgoCD for GitOps
- Deploy the FastAPI application

### 5. Validation

```bash
# Run validation script
./validate.sh
```

This checks:
- Cluster connectivity
- Pod health across all namespaces
- SSL certificate status
- DNS record creation
- Service accessibility

## 📂 Project Structure

```
AKSProject/
├── app/                          # FastAPI application
│   ├── src/                      # Python source code
│   │   ├── main.py              # FastAPI application
│   │   ├── model.py             # MobileNetV2 model
│   │   └── utils.py             # Utility functions
│   ├── static/                   # Static web assets
│   ├── requirements.txt          # Python dependencies
│   ├── Dockerfile               # Container image
│   └── test_app.py              # Unit tests
├── k8-manifests/                # Kubernetes manifests
│   ├── app/                     # Application deployment
│   ├── monitoring/              # Prometheus & Grafana
│   ├── ingress/                 # Ingress NGINX controller
│   └── cert-manager/            # SSL & DNS management
├── terraform/                   # Infrastructure as Code
│   ├── modules/                 # Terraform modules
│   └── *.tf                     # Main configuration
├── deploy.sh                    # Automated deployment
├── validate.sh                  # Validation script
├── setup-external-dns.sh        # Secure DNS setup
└── EXTERNAL-DNS-GUIDE.md        # DNS security guide
```

## 🔧 Manual Configuration Steps

### 1. Update Container Image

Update the image reference in [`k8-manifests/app/app.yml`](./k8-manifests/app/app.yml):

```yaml
spec:
  containers:
  - name: fastapi-app
    image: your-registry/fastapi-image-classifier:latest  # Update this
```

### 2. Build and Push Docker Image

```bash
cd app
docker build -t your-registry/fastapi-image-classifier:latest .
docker push your-registry/fastapi-image-classifier:latest
```

### 3. DNS Configuration

After deployment, External DNS will automatically create DNS records. However, you may need to:

1. Verify records in Cloudflare dashboard
2. Ensure proper proxy settings (orange cloud)
3. Check propagation: `dig aks.isaiahmichael.com`

## 🔍 Monitoring & Observability

### Prometheus
- **URL**: https://prometheus.isaiahmichael.com
- **Metrics**: Application, infrastructure, and Kubernetes metrics
- **Alerting**: Configure alerts for critical thresholds

### Grafana  
- **URL**: https://grafana.isaiahmichael.com
- **Default Login**: admin/admin (change on first login)
- **Dashboards**: Pre-configured for Kubernetes and application monitoring

### Application Logs
```bash
# View application logs
kubectl logs -n default deployment/fastapi-app -f

# View all pod logs in namespace
kubectl logs -n default -l app=fastapi-app --tail=100
```

## 🔒 Security Features

- **TLS Everywhere**: All services protected with Let's Encrypt certificates
- **Secret Management**: Secure handling of Cloudflare API tokens
- **Network Policies**: Planned for enhanced pod-to-pod security
- **RBAC**: Service accounts with minimal required permissions
- **Ingress Security**: Rate limiting and DDoS protection via Cloudflare

## 🔄 GitOps with ArgoCD

ArgoCD automatically syncs your application from Git:

1. **Access**: https://argocd.isaiahmichael.com
2. **Default Login**: admin/[get-password-from-secret]
3. **Auto-sync**: Enabled for continuous deployment
4. **Self-healing**: Automatically corrects configuration drift

```bash
# Get ArgoCD admin password
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d
```

## 🛠️ Development Workflow

1. **Make Changes**: Update code in `app/` or manifests in `k8-manifests/`
2. **Build Image**: `docker build -t your-registry/fastapi-image-classifier:tag .`
3. **Push Image**: `docker push your-registry/fastapi-image-classifier:tag`
4. **Update Manifests**: Update image tag in `k8-manifests/app/app.yml`
5. **Commit Changes**: ArgoCD will automatically sync and deploy

## 🚨 Troubleshooting

### External DNS Issues
```bash
# Check External DNS logs
kubectl logs -n external-dns deployment/external-dns -f

# Verify DNS records
kubectl describe configmap external-dns-txt-registry -n external-dns
```

### SSL Certificate Issues
```bash
# Check certificate status
kubectl describe certificaterequests

# Check cert-manager logs
kubectl logs -n cert-manager deployment/cert-manager -f
```

### Application Issues
```bash
# Check pod status
kubectl get pods -n default

# Check service and ingress
kubectl get svc,ingress -n default

# View detailed pod info
kubectl describe pod <pod-name> -n default
```

## 📚 Additional Resources

- [External DNS Security Guide](./EXTERNAL-DNS-GUIDE.md)
- [FastAPI Documentation](./app/README.md)
- [Terraform Modules Documentation](./terraform/README.md)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and test thoroughly
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

---

**Note**: This is a demonstration project for learning AKS, MLOps, and cloud-native technologies. For production use, additional security hardening, monitoring, and operational procedures should be implemented.