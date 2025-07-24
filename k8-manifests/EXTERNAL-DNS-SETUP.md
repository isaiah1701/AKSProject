# External DNS Setup Guide

External DNS will automatically manage your DNS records in Cloudflare based on your Kubernetes ingress annotations.

## ⚡ Quick Setup

1. **Get your Cloudflare API Token**:
   - Go to https://dash.cloudflare.com/profile/api-tokens
   - Click "Create Token"
   - Use "Custom token" with these permissions:
     ```
     Zone - Zone Settings:Read
     Zone - Zone:Read  
     Zone - DNS:Edit
     ```
   - Add zone resource: `Include - All zones`

2. **Update the secret**:
   ```bash
   # Edit the file
   nano k8-manifests/cert-manager/cloudflare-secret.yaml
   
   # Replace "your-cloudflare-api-token-here" with your actual token
   ```

3. **Deploy External DNS**:
   ```bash
   kubectl apply -f k8-manifests/cert-manager/external-dns.yaml
   kubectl apply -f k8-manifests/cert-manager/cloudflare-secret.yaml
   ```

## 📋 How It Works

External DNS watches for ingress resources with these annotations:
```yaml
annotations:
  external-dns.alpha.kubernetes.io/hostname: subdomain.isaiahmichael.com
  external-dns.alpha.kubernetes.io/cloudflare-proxied: "true"
```

When it finds them, it automatically:
1. ✅ Creates DNS A records pointing to your LoadBalancer IP
2. ✅ Enables Cloudflare proxy (orange cloud)
3. ✅ Updates records when LoadBalancer IP changes
4. ✅ Removes records when ingress is deleted

## 🔍 Monitoring External DNS

```bash
# Check External DNS logs
kubectl logs -n external-dns deployment/external-dns

# Check what records it's managing
kubectl logs -n external-dns deployment/external-dns | grep "CREATE\|UPDATE\|DELETE"

# Check if it's running
kubectl get pods -n external-dns
```

## 🎯 DNS Records Created

Once deployed, External DNS will automatically create:
- `aks.isaiahmichael.com` → LoadBalancer IP
- `argocd.isaiahmichael.com` → LoadBalancer IP  
- `prometheus.isaiahmichael.com` → LoadBalancer IP
- `grafana.isaiahmichael.com` → LoadBalancer IP

## 🚫 No Manual DNS Needed!

With External DNS configured, you **don't need to manually create DNS records**. Just deploy your ingress resources with the correct annotations and External DNS handles the rest.

## 🐛 Troubleshooting

**External DNS not creating records?**
```bash
# Check permissions
kubectl logs -n external-dns deployment/external-dns | grep -i error

# Verify API token
kubectl get secret cloudflare-api-token-secret -n external-dns -o yaml
```

**Records not updating?**
```bash
# Force sync (delete and recreate External DNS pod)
kubectl delete pod -n external-dns -l app=external-dns
```

**Wrong IP in DNS?**
```bash
# Check LoadBalancer IP
kubectl get svc -n ingress-nginx ingress-nginx-controller
```
