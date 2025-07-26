#!/bin/bash
set -e

echo "Installing ArgoCD using Helm..."

# Add ArgoCD Helm repository
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

# Create namespace
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -

# Install ArgoCD with custom values
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --values values.yaml \
  --wait

echo "ArgoCD installation complete!"
echo ""
echo "Getting admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
echo ""
echo "Access ArgoCD at: https://argocd.isaiahmichael.com"
echo "Username: admin"
