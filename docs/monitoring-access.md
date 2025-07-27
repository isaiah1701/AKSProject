# Monitoring Access Credentials

## 🔑 **Credentials Summary**

### **Grafana**
- **URL**: `https://grafana.isaiahmichael.com`
- **Username**: `admin` 
- **Password**: `monitoring123` (nginx basic auth) → then `admin` / `grafana123` (internal Grafana auth)
- **Note**: Two-layer authentication: first nginx basic auth, then Grafana's internal login

### **Prometheus**
- **URL**: `https://prometheus.isaiahmichael.com`
- **Username**: `admin` (HTTP Basic Auth)
- **Password**: `monitoring123` (same as Grafana nginx auth)
- **Note**: Uses basic auth via ingress annotation

### **ArgoCD**
- **URL**: `https://argocd.isaiahmichael.com`
- **Username**: `admin`
- **Password**: Get with: `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`

## 🚀 **Quick Access Commands**

### **Port Forward (Alternative Access)**
```bash
# Grafana
kubectl port-forward -n monitoring service/grafana 3000:80
# Access at: http://localhost:3000

# Prometheus  
kubectl port-forward -n monitoring service/prometheus 9090:80
# Access at: http://localhost:9090

# ArgoCD
kubectl port-forward -n argocd service/argocd-server 8080:80
# Access at: http://localhost:8080
```

### **Get ArgoCD Admin Password**
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
```

## � **Creating Dashboards with Prometheus**

### **Step 1: Add Prometheus Data Source**
1. **Log into Grafana**: https://grafana.isaiahmichael.com
2. **Go to**: Configuration → Data Sources (or use the gear icon ⚙️)
3. **Click**: "Add data source"
4. **Select**: "Prometheus"
5. **Configure**:
   - **URL**: `http://prometheus:9090` (internal service name)
   - **Access**: Server (default)
   - **HTTP Method**: GET (default)
6. **Click**: "Save & Test"

### **Step 2: Create Your First Dashboard**
1. **Click**: "+" → Dashboard
2. **Add Panel**: Click "Add a new panel"
3. **Query Examples**:
   ```promql
   # CPU Usage
   100 - (avg(irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)
   
   # Memory Usage
   (1 - (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)) * 100
   
   # Pod CPU Usage
   sum(rate(container_cpu_usage_seconds_total[5m])) by (pod)
   
   # HTTP Request Rate
   sum(rate(http_requests_total[5m])) by (job)
   ```

### **Step 3: Kubernetes Monitoring Queries**
```promql
# Pods by namespace
count by (namespace) (kube_pod_info)

# Container restarts
increase(kube_pod_container_status_restarts_total[1h])

# Node status
up{job="kubernetes-nodes"}

# Ingress requests
sum(rate(nginx_ingress_controller_requests[5m])) by (ingress)
```

## �🔒 **Security Recommendations**

1. **Change Default Passwords**: Update Grafana and Prometheus passwords from defaults
2. **Enable 2FA**: Consider enabling two-factor authentication in ArgoCD
3. **Network Policies**: Implement network policies to restrict access
4. **SSL Certificates**: Ensure all endpoints use valid SSL certificates via cert-manager

## 📊 **Service Status Check**
```bash
# Check all monitoring pods
kubectl get pods -n monitoring
kubectl get pods -n argocd

# Check ingresses
kubectl get ingress -A

# Check certificates
kubectl get certificates -A
```

## � **Current Status** 

### ✅ **Working (Helm-based kube-prometheus-stack)**
- **Grafana**: `https://grafana.isaiahmichael.com` 
  - Nginx Auth: `admin` / `monitoring123`
  - Grafana Auth: `admin` / `prom-operator` (default Helm password)
  - **Features**: Full dashboards, alerting, data sources pre-configured

- **Prometheus**: Service running, ingress created, waiting for DNS propagation
  - **Direct Access**: `kubectl port-forward -n monitoring svc/kube-prometheus-stack-prometheus 9090:9090`
  - **Will be**: `https://prometheus.isaiahmichael.com` (admin / monitoring123)

### 📊 **What You Get with Helm**
- **Prometheus**: Metrics collection and storage
- **Grafana**: Pre-configured dashboards for Kubernetes monitoring
- **Alertmanager**: Alert management and routing  
- **Node Exporter**: Node/server metrics (CPU, memory, disk, network)
- **Kube State Metrics**: Kubernetes object metrics (pods, deployments, etc.)
- **Prometheus Operator**: Manages Prometheus instances

### 🚀 **Why Helm is Better**
✅ **Pre-built dashboards** for Kubernetes, nodes, pods, etc.
✅ **Automatic service discovery** and monitoring rules
✅ **Production-ready configuration** out of the box
✅ **Easy upgrades** with `helm upgrade`
✅ **Community maintained** with best practices
