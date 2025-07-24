#!/usr/bin/env python3
"""
Simple test script to verify the FastAPI image classification app
"""

import requests
import sys
import os

def test_health_endpoint():
    """Test the health check endpoint"""
    try:
        response = requests.get("http://localhost:80/health")
        if response.status_code == 200:
            print("✅ Health check passed")
            print(f"Response: {response.json()}")
            return True
        else:
            print(f"❌ Health check failed: {response.status_code}")
            return False
    except requests.exceptions.ConnectionError:
        print("❌ Cannot connect to the application. Is it running?")
        return False

def test_main_page():
    """Test the main page endpoint"""
    try:
        response = requests.get("http://localhost:80/")
        if response.status_code == 200 and "Image Classification" in response.text:
            print("✅ Main page loads correctly")
            return True
        else:
            print(f"❌ Main page test failed: {response.status_code}")
            return False
    except requests.exceptions.ConnectionError:
        print("❌ Cannot connect to the application. Is it running?")
        return False

def main():
    print("🧪 Testing FastAPI Image Classification App")
    print("-" * 50)
    
    # Test endpoints
    health_ok = test_health_endpoint()
    main_page_ok = test_main_page()
    
    print("-" * 50)
    if health_ok and main_page_ok:
        print("🎉 All tests passed! The application is working correctly.")
        print("\n📝 Next steps:")
        print("1. Open http://localhost:80 in your browser")
        print("2. Upload an image to test the classification")
        sys.exit(0)
    else:
        print("❌ Some tests failed. Check the application logs.")
        sys.exit(1)

if __name__ == "__main__":
    main()
