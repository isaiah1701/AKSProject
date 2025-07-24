# 🔐 Secure External DNS Setup Guide

This guide shows you how to set up External DNS with automatic Cloudflare DNS management **without exposing your API token** in Git.

## 🎯 What External DNS Does

External DNS automatically:
- **Creates DNS records** when you deploy ingress resources
- **Updates records** when LoadBalancer IPs change  
- **Deletes records** when ingress resources are removed
- **Enables Cloudflare proxy** (orange cloud) for protection

## 🔑 Cloudflare API Token Setup

### Step 1: Create API Token
1. Go to [Cloudflare API Tokens](https://dash.cloudflare.com/profile/api-tokens)
2. Click **"Create Token"**
3. Use **"Custom token"** template
4. Configure permissions:
   ```
   Zone - Zone - Read
   Zone - DNS - Edit
   ```
5. Set **Zone Resources**: `Include - All zones` or `Include - Specific zone - isaiahmichael.com`
6. Click **"Continue to summary"** → **"Create Token"**
7. **Copy the token** (you won't see it again!)

### Step 2: Test Your Token
```bash
# Test the token works
curl -X GET "https://api.cloudflare.com/client/v4/zones" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json"
```

## 🚀 Deployment Options

### Option 1: Environment Variable (Recommended for CI/CD)
```bash
# Export the token in your shell
export CLOUDFLARE_API_TOKEN="your_token_here"

# Deploy External DNS
./setup-external-dns.sh
```

### Option 2: Local File (Recommended for Development)
```bash
# Save token to a secure file (already in .gitignore)
echo "your_token_here" > .cloudflare-token
chmod 600 .cloudflare-token

# Deploy External DNS
./setup-external-dns.sh
```

### Option 3: Interactive Input (Fallback)
```bash
# Just run the script - it will prompt for the token
./setup-external-dns.sh
```

## ✅ Verify External DNS is Working

### Check Deployment Status
```bash
# Check if External DNS is running
kubectl get pods -n external-dns

# Check logs for activity
kubectl logs -n external-dns deployment/external-dns -f
```

### Test Automatic DNS Creation
```bash
# Deploy an ingress with External DNS annotations
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: test-ingress
  namespace: default
  annotations:
    external-dns.alpha.kubernetes.io/hostname: test.isaiahmichael.com
    external-dns.alpha.kubernetes.io/cloudflare-proxied: "true"
spec:
  rules:
  - host: test.isaiahmichael.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: kubernetes
            port:
              number: 443
EOF

# Watch External DNS logs to see it create the record
kubectl logs -n external-dns deployment/external-dns -f
```

## 🏗️ How to Use in Your Applications

### Add Annotations to Ingress Resources
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: my-app-ingress
  annotations:
    # Required: Tell External DNS to manage this record
    external-dns.alpha.kubernetes.io/hostname: myapp.isaiahmichael.com
    
    # Optional: Enable Cloudflare proxy (recommended)
    external-dns.alpha.kubernetes.io/cloudflare-proxied: "true"
    
    # Optional: Set TTL for the DNS record
    external-dns.alpha.kubernetes.io/ttl: "300"
    
    # SSL and other annotations
    cert-manager.io/cluster-issuer: "letsencrypt-dns"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  tls:
  - hosts:
    - myapp.isaiahmichael.com
    secretName: myapp-tls
  rules:
  - host: myapp.isaiahmichael.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: my-app-service
            port:
              number: 80
```

## 🔍 Monitoring and Troubleshooting

### Check External DNS Logs
```bash
# Real-time logs
kubectl logs -n external-dns deployment/external-dns -f

# Recent logs
kubectl logs -n external-dns deployment/external-dns --tail=50
```

### Check DNS Records in Cloudflare
```bash
# List DNS records for your domain
curl -X GET "https://api.cloudflare.com/client/v4/zones/YOUR_ZONE_ID/dns_records" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" | jq '.result[] | {name, content, type}'
```

### Debug External DNS
```bash
# Check if External DNS can see your ingresses
kubectl get ingress -A

# Check External DNS configuration
kubectl describe deployment -n external-dns external-dns

# Check the secret
kubectl get secret -n external-dns cloudflare-api-token-secret
```

## 🛡️ Security Best Practices

### ✅ Do This:
- ✅ Use environment variables or secure files for tokens
- ✅ Keep tokens out of Git (use .gitignore)
- ✅ Use minimal permissions for API tokens
- ✅ Rotate tokens regularly
- ✅ Monitor External DNS logs for suspicious activity

### ❌ Never Do This:
- ❌ Put tokens directly in YAML files
- ❌ Commit tokens to Git
- ❌ Use overly broad API token permissions
- ❌ Share tokens in chat/email
- ❌ Use the same token across environments

## 🎯 Integration with Your AKS Project

Your External DNS setup will automatically manage these domains:

| Service | Domain | Managed By |
|---------|--------|------------|
| **Main App** | `aks.isaiahmichael.com` | ✅ External DNS |
| **ArgoCD** | `argocd.isaiahmichael.com` | ✅ External DNS |
| **Prometheus** | `prometheus.isaiahmichael.com` | ✅ External DNS |
| **Grafana** | `grafana.isaiahmichael.com` | ✅ External DNS |

## 🚀 Complete Deployment Workflow

```bash
# 1. Set up External DNS (one time)
./setup-external-dns.sh

# 2. Deploy your applications (they'll automatically get DNS)
kubectl apply -f k8-manifests/app/argocd.yml
kubectl apply -f k8-manifests/monitoring/ingress.yaml
kubectl apply -f k8-manifests/app/app.yml

# 3. Watch the magic happen
kubectl logs -n external-dns deployment/external-dns -f
```

## 🎉 Benefits of This Setup

1. **Zero Manual DNS Work** - Records created automatically
2. **Git-Safe** - No secrets in your repository
3. **Production Ready** - Secure token management
4. **Cloudflare Integration** - Automatic proxy protection
5. **Self-Healing** - Updates records if IPs change
6. **Easy Cleanup** - Removes records when ingresses are deleted

This is exactly how production teams manage DNS at scale! 🚀
