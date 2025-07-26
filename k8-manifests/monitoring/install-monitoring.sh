#!/bin/bash
set -e

echo "Installing kube-prometheus-stack with Helm..."

# Create namespace
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

# Install the complete monitoring stack
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --values values.yaml \
  --wait \
  --timeout 10m

echo ""
echo "✅ Monitoring stack installation complete!"
echo ""
echo "🌐 Access URLs:"
echo "  📊 Grafana:    https://grafana.isaiahmichael.com"
echo "  📈 Prometheus: https://prometheus.isaiahmichael.com"
echo ""
echo "🔑 Grafana Credentials:"
echo "  Username: admin"
echo "  Password: grafana123"
echo ""
echo "📋 What you get with this setup:"
echo "  ✅ Prometheus server with 30-day retention"
echo "  ✅ Grafana with pre-built Kubernetes dashboards"
echo "  ✅ Node Exporter for node metrics"
echo "  ✅ Kube State Metrics for Kubernetes metrics"
echo "  ✅ Alertmanager for alerting"
echo "  ✅ 50+ pre-configured alerts"
echo "  ✅ SSL certificates via cert-manager"
echo "  ✅ DNS records via external-dns"
echo ""
echo "🚀 Ready to use - no manual configuration needed!"
