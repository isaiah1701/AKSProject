#!/bin/bash

echo "🚀 Port Forward Script for AKS MLOps Services"
echo "=============================================="
echo ""
echo "This script creates port-forwards for immediate access while DNS is being configured."
echo ""

# Function to start port forward in background
start_port_forward() {
    local service=$1
    local namespace=$2
    local local_port=$3
    local service_port=$4
    
    echo "🔄 Starting port-forward for $service..."
    kubectl port-forward -n $namespace service/$service $local_port:$service_port > /dev/null 2>&1 &
    PID=$!
    echo "   → Access at: http://localhost:$local_port (PID: $PID)"
}

echo "Starting port-forwards..."
echo ""

# FastAPI App
start_port_forward "image-classifier" "app" "8080" "80"

# ArgoCD 
start_port_forward "argocd-server" "argocd" "8081" "80"

# Prometheus
start_port_forward "prometheus" "monitoring" "8082" "9090"

# Grafana (if available)
start_port_forward "grafana" "monitoring" "8083" "3000"

echo ""
echo "✅ Port-forwards active! Access your services:"
echo "=============================================="
echo "🔗 FastAPI App:  http://localhost:8080"
echo "🔗 ArgoCD:       http://localhost:8081"  
echo "🔗 Prometheus:   http://localhost:8082"
echo "🔗 Grafana:      http://localhost:8083"
echo ""
echo "📝 Note: Keep this terminal open to maintain the port-forwards"
echo "📝 Press Ctrl+C to stop all port-forwards"
echo ""

# Wait for interrupt
trap 'echo ""; echo "🛑 Stopping all port-forwards..."; kill $(jobs -p) 2>/dev/null; exit 0' INT

# Keep script running
echo "⏳ Port-forwards running... Press Ctrl+C to stop"
wait
