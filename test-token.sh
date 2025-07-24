#!/bin/bash

# Debug version to test token reading
set -e

echo "=== Debug Token Reading ==="

# Method 1: Environment Variable
if [ -n "$CLOUDFLARE_API_TOKEN" ]; then
    echo "✅ Found token in environment variable"
    echo "Token length: ${#CLOUDFLARE_API_TOKEN}"
    CF_TOKEN="$CLOUDFLARE_API_TOKEN"
    
# Method 2: Read from file
elif [ -f ".cloudflare-token" ]; then
    echo "✅ Found .cloudflare-token file"
    CF_TOKEN=$(cat .cloudflare-token | tr -d '\n\r')
    echo "Token length from file: ${#CF_TOKEN}"
    echo "First 10 chars: ${CF_TOKEN:0:10}..."
    
# Method 3: Interactive input
else
    echo "❌ No token found in environment or file"
    exit 1
fi

# Validate token format
if [ ${#CF_TOKEN} -lt 20 ]; then
    echo "❌ Token seems too short: ${#CF_TOKEN} characters"
    exit 1
else
    echo "✅ Token validation passed: ${#CF_TOKEN} characters"
fi

echo "=== Token reading successful ==="
