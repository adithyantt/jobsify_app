import requests
import json

# Test admin login
url = 'http://localhost:8000/auth/login'
data = {
    'email': 'admin@jobsify.com',
    'password': 'admin123'
}

try:
    response = requests.post(url, json=data)
    print(f'Status Code: {response.status_code}')
    print(f'Response: {response.text}')
    if response.status_code == 200:
        token = json.loads(response.text).get('access_token')
        print(f'Token: {token}')
        headers = {'Authorization': f'Bearer {token}'}

        # Test admin stats
        stats_response = requests.get('http://localhost:8000/admin/stats', headers=headers)
        print(f'Stats Status: {stats_response.status_code}')
        print(f'Stats Response: {stats_response.text}')

        # Test pending jobs
        jobs_response = requests.get('http://localhost:8000/jobs/admin/pending', headers=headers)
        print(f'Pending Jobs Status: {jobs_response.status_code}')
        print(f'Pending Jobs Response: {jobs_response.text}')

        # Test pending workers
        workers_response = requests.get('http://localhost:8000/workers/admin/pending', headers=headers)
        print(f'Pending Workers Status: {workers_response.status_code}')
        print(f'Pending Workers Response: {workers_response.text}')

        # Test pending reports
        reports_response = requests.get('http://localhost:8000/admin/reports/pending', headers=headers)
        print(f'Pending Reports Status: {reports_response.status_code}')
        print(f'Pending Reports Response: {reports_response.text}')

    else:
        print('Login failed')
except Exception as e:
    print(f'Error: {e}')
