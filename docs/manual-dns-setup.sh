#!/bin/bash

echo "=== Manual DNS Setup for AKS MLOps Pipeline ==="
echo ""
echo "Since External DNS is having connectivity issues, please manually create these DNS records in Cloudflare:"
echo ""
echo "📋 DNS Records to Create:"
echo "============================"

# Get the external IP
EXTERNAL_IP="74.177.117.202"

echo "Record Type: A"
echo "Name: aks"
echo "Content: ${EXTERNAL_IP}"
echo "TTL: Auto"
echo "Proxy status: DNS only (grey cloud)"
echo ""

echo "Record Type: A" 
echo "Name: argocd"
echo "Content: ${EXTERNAL_IP}"
echo "TTL: Auto"
echo "Proxy status: DNS only (grey cloud)"
echo ""

echo "Record Type: A"
echo "Name: prometheus" 
echo "Content: ${EXTERNAL_IP}"
echo "TTL: Auto"
echo "Proxy status: DNS only (grey cloud)"
echo ""

echo "Record Type: A"
echo "Name: grafana"
echo "Content: ${EXTERNAL_IP}"
echo "TTL: Auto"
echo "Proxy status: DNS only (grey cloud)"
echo ""

echo "🔗 Cloudflare Dashboard:"
echo "https://dash.cloudflare.com/"
echo ""

echo "📝 Instructions:"
echo "1. Log into Cloudflare Dashboard"
echo "2. Select your domain: isaiahmichael.com"
echo "3. Go to DNS tab"
echo "4. Add the above A records"
echo "5. Make sure Proxy status is 'DNS only' (grey cloud, not orange)"
echo ""

echo "✅ Once added, your services will be available at:"
echo "- FastAPI App: https://aks.isaiahmichael.com"
echo "- ArgoCD: https://argocd.isaiahmichael.com" 
echo "- Prometheus: https://prometheus.isaiahmichael.com"
echo "- Grafana: https://grafana.isaiahmichael.com"
echo ""

echo "🔍 Test DNS propagation:"
echo "dig +short aks.isaiahmichael.com"
echo "nslookup aks.isaiahmichael.com"
