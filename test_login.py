import requests
import json

# Test admin login
url = "http://localhost:8000/auth/login"
data = {
    "email": "admin@jobsify.com",
    "password": "admin123"
}

try:
    response = requests.post(url, json=data)
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.text}")
except Exception as e:
    print(f"Error: {e}")
