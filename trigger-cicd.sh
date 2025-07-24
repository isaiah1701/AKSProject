#!/bin/bash

# Script to trigger CI/CD pipeline by making a commit to the app

set -e

echo "🚀 Triggering CI/CD Pipeline..."

# Ensure we're on the main branch
git checkout main

# Make a small change to trigger the pipeline
echo "# Last updated: $(date)" >> app/src/main.py

# Add, commit, and push changes
git add .
git commit -m "🚀 Trigger CI/CD pipeline - $(date '+%Y-%m-%d %H:%M:%S')"

echo "📤 Pushing to GitHub..."
git push origin main

echo "✅ Pipeline triggered!"
echo ""
echo "🔗 Check the progress at:"
echo "   GitHub Actions: https://github.com/imich/AKSProject/actions"
echo "   ArgoCD UI: https://argocd.isaiahmichael.com"
echo ""
echo "📋 What happens next:"
echo "   1. GitHub Actions builds and scans the Docker image"
echo "   2. Image is pushed to ghcr.io"
echo "   3. K8s manifest is updated with new image tag"
echo "   4. ArgoCD detects the change and deploys automatically"
echo "   5. App becomes available at: https://aks.isaiahmichael.com"
