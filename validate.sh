#!/bin/bash

# AKS Project Validation Script
# Checks if all components are properly configured and ready

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo -e "\n${BLUE}====== $1 ======${NC}"
}

print_check() {
    echo -e "${YELLOW}Checking:${NC} $1"
}

print_pass() {
    echo -e "  ${GREEN}✓${NC} $1"
}

print_fail() {
    echo -e "  ${RED}✗${NC} $1"
}

print_warning() {
    echo -e "  ${YELLOW}⚠${NC} $1"
}

# Check prerequisites
print_header "Prerequisites"

print_check "kubectl connection"
if kubectl cluster-info &> /dev/null; then
    CLUSTER=$(kubectl config current-context)
    print_pass "Connected to cluster: $CLUSTER"
else
    print_fail "Not connected to Kubernetes cluster"
    exit 1
fi

print_check "Required files"
files=(
    "k8-manifests/app/app.yml"
    "k8-manifests/app/argocd.yml"
    "k8-manifests/cert-manager/core.yaml"
    "k8-manifests/cert-manager/tls.yaml"
    "k8-manifests/ingress/nginx.yaml"
    "k8-manifests/monitoring/prometheus.yaml"
    "k8-manifests/monitoring/grafana.yaml"
    "k8-manifests/monitoring/ingress.yaml"
)

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        print_pass "$file exists"
    else
        print_fail "$file missing"
        exit 1
    fi
done

# Check configuration
print_header "Configuration Validation"

print_check "Cloudflare API token configured"
if grep -q "your-cloudflare-api-token-here" k8-manifests/cert-manager/cloudflare-secret.yaml; then
    print_fail "Update Cloudflare API token in k8-manifests/cert-manager/cloudflare-secret.yaml"
else
    print_pass "Cloudflare API token configured"
fi

print_check "Docker registry in app.yml"
if grep -q "your-registry" k8-manifests/app/app.yml; then
    print_warning "Update Docker registry in k8-manifests/app/app.yml"
else
    print_pass "Docker registry configured"
fi

print_check "Git repository in argocd.yml"
if grep -q "isaiah1701/AKSProject" k8-manifests/app/argocd.yml; then
    print_pass "Git repository configured"
else
    print_warning "Verify Git repository URL in k8-manifests/app/argocd.yml"
fi

# Check current deployment status
print_header "Deployment Status"

namespaces=("ingress-nginx" "cert-manager" "external-dns" "monitoring" "argocd" "app")

for ns in "${namespaces[@]}"; do
    print_check "Namespace: $ns"
    if kubectl get namespace "$ns" &> /dev/null; then
        print_pass "Namespace exists"
        
        # Check pods in namespace
        pods=$(kubectl get pods -n "$ns" --no-headers 2>/dev/null | wc -l)
        running=$(kubectl get pods -n "$ns" --field-selector=status.phase=Running --no-headers 2>/dev/null | wc -l)
        
        if [ "$pods" -gt 0 ]; then
            print_pass "$running/$pods pods running"
        else
            print_warning "No pods found"
        fi
    else
        print_warning "Namespace not found (not deployed yet)"
    fi
done

# Check ingress and certificates
print_header "Ingress and SSL"

print_check "Ingress controllers"
if kubectl get deployment -n ingress-nginx ingress-nginx-controller &> /dev/null; then
    print_pass "NGINX Ingress Controller deployed"
    
    # Check LoadBalancer
    LB_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
    if [ -n "$LB_IP" ]; then
        print_pass "LoadBalancer IP: $LB_IP"
    else
        print_warning "LoadBalancer IP not assigned yet"
    fi
else
    print_warning "NGINX Ingress Controller not deployed"
fi

print_check "SSL Certificates"
if kubectl get certificates -A &> /dev/null; then
    kubectl get certificates -A --no-headers | while read line; do
        cert_name=$(echo $line | awk '{print $2}')
        cert_ready=$(echo $line | awk '{print $3}')
        if [ "$cert_ready" = "True" ]; then
            print_pass "Certificate $cert_name ready"
        else
            print_warning "Certificate $cert_name not ready"
        fi
    done
else
    print_warning "No certificates found"
fi

# Check services accessibility
print_header "Service Health"

services=(
    "aks.isaiahmichael.com"
    "argocd.isaiahmichael.com"
    "prometheus.isaiahmichael.com"
    "grafana.isaiahmichael.com"
)

for service in "${services[@]}"; do
    print_check "Testing $service"
    if curl -s --max-time 5 "https://$service" &> /dev/null; then
        print_pass "$service accessible"
    elif curl -s --max-time 5 "http://$service" &> /dev/null; then
        print_warning "$service accessible (HTTP only)"
    else
        print_warning "$service not accessible (DNS/deployment issue)"
    fi
done

# Summary
print_header "Summary"

echo "Validation complete. Check any warnings or failures above."
echo ""
echo "🚀 To deploy: ./deploy.sh"
echo "📊 To monitor: kubectl get pods -A"
echo "🔍 To debug: kubectl logs -n <namespace> <pod-name>"

# Generate DNS records helper
if [ -n "$LB_IP" ]; then
    echo ""
    echo "📋 DNS Records to configure:"
    echo "aks      IN A    $LB_IP"
    echo "argocd   IN A    $LB_IP"  
    echo "prometheus IN A  $LB_IP"
    echo "grafana  IN A    $LB_IP"
fi
