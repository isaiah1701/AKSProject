#!/bin/bash

# Secure External DNS Setup Script
# This script safely configures External DNS without exposing your API token in Git

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

print_header "Secure External DNS Setup"

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

# Method 1: Environment Variable (Recommended for CI/CD)
if [ -n "$CLOUDFLARE_API_TOKEN" ]; then
    print_status "Using Cloudflare API token from environment variable"
    CF_TOKEN="$CLOUDFLARE_API_TOKEN"
    
# Method 2: Read from file (for local development)
elif [ -f ".cloudflare-token" ]; then
    print_status "Reading Cloudflare API token from .cloudflare-token file"
    CF_TOKEN=$(cat .cloudflare-token | tr -d '\n\r')
    
# Method 3: Interactive input (fallback)
else
    print_warning "No API token found in environment or .cloudflare-token file"
    echo ""
    echo "🔑 Cloudflare API Token Setup:"
    echo "   1. Go to https://dash.cloudflare.com/profile/api-tokens"
    echo "   2. Create a token with permissions:"
    echo "      - Zone:Zone:Read"
    echo "      - Zone:DNS:Edit"
    echo "      - Zone Resources: Include All zones"
    echo ""
    read -s -p "Enter your Cloudflare API token: " CF_TOKEN
    echo ""
fi

# Validate token format (basic check)
if [ ${#CF_TOKEN} -lt 20 ]; then
    print_error "API token seems too short. Please check your token."
    exit 1
fi

# Create a temporary file with the token
TEMP_FILE=$(mktemp)
trap "rm -f $TEMP_FILE" EXIT

# Use a more secure approach with environment variable passed to sed
# This avoids exposing the token in process lists or command history
export TEMP_CF_TOKEN="$CF_TOKEN"

# Replace the placeholder in the YAML using envsubst for secure substitution
sed 's/REPLACE_WITH_YOUR_TOKEN/$TEMP_CF_TOKEN/g' k8-manifests/cert-manager/external-dns.yaml | \
  envsubst '$TEMP_CF_TOKEN' > "$TEMP_FILE"

# Remember if we got token from environment (for cleanup logic later)
TOKEN_FROM_ENV=""
if [ -n "$CLOUDFLARE_API_TOKEN" ]; then
    TOKEN_FROM_ENV="yes"
fi

# Clear the token from memory for security
unset CF_TOKEN
unset TEMP_CF_TOKEN

print_status "Deploying External DNS with secure token..."

# Apply the configuration
kubectl apply -f "$TEMP_FILE"

print_success "External DNS deployed successfully"

# Force a rollout restart to ensure clean deployment
print_status "Restarting External DNS deployment..."
kubectl rollout restart deployment/external-dns -n external-dns

# Wait for deployment to be ready
print_status "Waiting for External DNS to be ready..."
kubectl wait --namespace external-dns \
  --for=condition=available deployment/external-dns \
  --timeout=300s

print_success "External DNS is running"

# Show the status
print_status "External DNS status:"
kubectl get pods -n external-dns
kubectl get services -n external-dns

# Show logs for verification
print_status "Recent External DNS logs:"
kubectl logs -n external-dns deployment/external-dns --tail=10

print_header "Setup Complete"
echo ""
echo "✅ External DNS is now configured and running"
echo "✅ It will automatically manage DNS records for ingresses with annotations"
echo "✅ API token is securely stored in Kubernetes secrets"
echo ""
echo "🔍 Monitor External DNS:"
echo "   kubectl logs -n external-dns deployment/external-dns -f"
echo ""
echo "📋 To enable automatic DNS for an ingress, add these annotations:"
echo "   external-dns.alpha.kubernetes.io/hostname: your-domain.isaiahmichael.com"
echo "   external-dns.alpha.kubernetes.io/cloudflare-proxied: \"true\""

# Cleanup: Offer to save token to .gitignore file for future use
if [ ! -f ".cloudflare-token" ] && [ "$TOKEN_FROM_ENV" != "yes" ]; then
    echo ""
    read -p "Save token to .cloudflare-token file for future deployments? (y/N): " save_token
    if [[ $save_token =~ ^[Yy]$ ]]; then
        # We need to recreate the token for saving since we cleared it
        echo "Token was cleared for security. Please enter it again to save:"
        read -s -p "Cloudflare API Token: " SAVE_TOKEN
        echo ""
        echo "$SAVE_TOKEN" > .cloudflare-token
        chmod 600 .cloudflare-token
        unset SAVE_TOKEN
        
        # Add to .gitignore if not already there
        if ! grep -q ".cloudflare-token" .gitignore 2>/dev/null; then
            echo ".cloudflare-token" >> .gitignore
            print_success "Added .cloudflare-token to .gitignore"
        fi
        
        print_success "Token saved to .cloudflare-token (secure file permissions set)"
        print_warning "Keep this file secure and never commit it to Git"
    fi
fi
