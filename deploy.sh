#!/bin/bash

# AKS Project Deployment Script
# This script deploys the complete MLOps pipeline with monitoring, GitOps, and SSL

set -e

echo "🚀 Starting AKS Project Deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed or not in PATH"
    exit 1
fi

# Check if we're connected to a cluster
if ! kubectl cluster-info &> /dev/null; then
    print_error "Not connected to a Kubernetes cluster"
    exit 1
fi

print_status "Connected to cluster: $(kubectl config current-context)"

# 1. Deploy NGINX Ingress Controller
print_status "Deploying NGINX Ingress Controller..."
kubectl apply -f k8-manifests/ingress/nginx.yaml
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=ingress-nginx \
  --timeout=300s

# Get LoadBalancer IP
print_status "Waiting for LoadBalancer IP..."
EXTERNAL_IP=""
while [ -z "$EXTERNAL_IP" ]; do
    EXTERNAL_IP=$(kubectl get svc ingress-nginx-controller -n ingress-nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    if [ -z "$EXTERNAL_IP" ]; then
        print_status "Waiting for external IP..."
        sleep 10
    fi
done

print_success "LoadBalancer External IP: $EXTERNAL_IP"
print_warning "Please update your DNS records:"
echo "  aks.isaiahmichael.com      -> $EXTERNAL_IP"
echo "  argocd.isaiahmichael.com   -> $EXTERNAL_IP"
echo "  prometheus.isaiahmichael.com -> $EXTERNAL_IP"
echo "  grafana.isaiahmichael.com  -> $EXTERNAL_IP"

read -p "Press Enter after updating DNS records..."

# 2. Deploy Cert-Manager and External DNS
print_status "Deploying Cert-Manager..."
kubectl apply -f k8-manifests/cert-manager/core.yaml
kubectl wait --namespace cert-manager \
  --for=condition=ready pod \
  --selector=app=cert-manager \
  --timeout=300s

print_status "Deploying External DNS with secure token injection..."
if [ ! -f "setup-external-dns.sh" ]; then
    print_error "setup-external-dns.sh not found. Please ensure the script exists."
    exit 1
fi

# Make sure the script is executable
chmod +x setup-external-dns.sh

# Run the secure External DNS setup
./setup-external-dns.sh

print_success "Cert-Manager and External DNS deployed"

# 3. Deploy TLS Certificates (secrets are now handled by setup-external-dns.sh)
kubectl apply -f k8-manifests/cert-manager/tls.yaml
print_success "TLS certificates requested and External DNS will auto-manage DNS records"

# 4. Deploy Monitoring Stack
print_status "Deploying Monitoring Stack..."
kubectl apply -f k8-manifests/monitoring/prometheus.yaml
kubectl apply -f k8-manifests/monitoring/grafana.yaml
kubectl apply -f k8-manifests/monitoring/ingress.yaml

kubectl wait --namespace monitoring \
  --for=condition=ready pod \
  --selector=app=prometheus \
  --timeout=300s

kubectl wait --namespace monitoring \
  --for=condition=ready pod \
  --selector=app=grafana \
  --timeout=300s

print_success "Monitoring stack deployed"

# 5. Deploy ArgoCD
print_status "Deploying ArgoCD..."
kubectl apply -f k8-manifests/app/argocd.yml

kubectl wait --namespace argocd \
  --for=condition=ready pod \
  --selector=app=argocd-server \
  --timeout=300s

# Get ArgoCD admin password
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d || echo "admin")

print_success "ArgoCD deployed"
print_status "ArgoCD Admin Password: $ARGOCD_PASSWORD"

# 6. Deploy the Application
print_status "Deploying Image Classification App..."
kubectl apply -f k8-manifests/app/app.yml

kubectl wait --namespace app \
  --for=condition=ready pod \
  --selector=app=image-classifier \
  --timeout=300s

print_success "Application deployed"

# Final status
print_success "🎉 AKS Project Deployment Complete!"
echo ""
echo "📊 Access your services:"
echo "  Main App:    https://aks.isaiahmichael.com"
echo "  ArgoCD:      https://argocd.isaiahmichael.com (admin/$ARGOCD_PASSWORD)"
echo "  Prometheus:  https://prometheus.isaiahmichael.com (admin/admin)"
echo "  Grafana:     https://grafana.isaiahmichael.com (admin/admin123)"
echo ""
echo "🔧 Next steps:"
echo "  1. Update Docker image in app.yml with your registry"
echo "  2. Push your image to the registry"
echo "  3. Update ArgoCD Application source.repoURL"
echo "  4. Configure Grafana dashboards"
echo "  5. Set up proper authentication for monitoring services"

# Check certificate status
print_status "Checking certificate status..."
kubectl get certificates -A
