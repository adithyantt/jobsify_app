import requests
import json

BASE_URL = "http://localhost:8000"

def test_create_job():
    """Test job creation with all required fields including urgent and salary"""
    print("=" * 60)
    print("TEST 1: Create Job with All Fields")
    print("=" * 60)
    
    job_data = {
        "title": "Test Plumbing Job",
        "category": "Plumber",
        "description": "Need a plumber to fix kitchen sink",
        "location": "123 Main St, City",
        "phone": "9876543210",
        "latitude": "12.9716",
        "longitude": "77.5946",
        "user_email": "testuser@example.com",
        "urgent": False,
        "salary": "500 per day"
    }
    
    try:
        response = requests.post(
            f"{BASE_URL}/jobs",
            headers={"Content-Type": "application/json"},
            json=job_data,
            timeout=10
        )
        
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code in [200, 201]:
            print("✅ SUCCESS: Job created successfully!")
            return True
        else:
            print(f"❌ FAILED: Job creation failed with status {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ ERROR: {e}")
        return False

def test_create_job_without_optional_fields():
    """Test job creation without optional fields (urgent, salary)"""
    print("\n" + "=" * 60)
    print("TEST 2: Create Job Without Optional Fields")
    print("=" * 60)
    
    job_data = {
        "title": "Simple Electrician Job",
        "category": "Electrician",
        "description": "Fix electrical wiring",
        "location": "456 Park Ave",
        "phone": "9876543211",
        "user_email": "testuser2@example.com"
        # urgent and salary not provided - should use defaults
    }
    
    try:
        response = requests.post(
            f"{BASE_URL}/jobs",
            headers={"Content-Type": "application/json"},
            json=job_data,
            timeout=10
        )
        
        print(f"Status Code: {response.status_code}")
        print(f"Response: {response.text}")
        
        if response.status_code in [200, 201]:
            print("✅ SUCCESS: Job created with default values!")
            return True
        else:
            print(f"❌ FAILED: Status {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ ERROR: {e}")
        return False

def test_fetch_jobs():
    """Test fetching all verified jobs"""
    print("\n" + "=" * 60)
    print("TEST 3: Fetch All Jobs")
    print("=" * 60)
    
    try:
        response = requests.get(
            f"{BASE_URL}/jobs",
            headers={"Content-Type": "application/json"},
            timeout=10
        )
        
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 200:
            jobs = response.json()
            print(f"✅ SUCCESS: Found {len(jobs)} jobs")
            return True
        else:
            print(f"❌ FAILED: Status {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ ERROR: {e}")
        return False

def test_fetch_my_jobs():
    """Test fetching jobs by user email"""
    print("\n" + "=" * 60)
    print("TEST 4: Fetch My Jobs")
    print("=" * 60)
    
    try:
        response = requests.get(
            f"{BASE_URL}/jobs/my?email=testuser@example.com",
            headers={"Content-Type": "application/json"},
            timeout=10
        )
        
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 200:
            jobs = response.json()
            print(f"✅ SUCCESS: Found {len(jobs)} jobs for user")
            return True
        else:
            print(f"❌ FAILED: Status {response.status_code}")
            return False
            
    except Exception as e:
        print(f"❌ ERROR: {e}")
        return False

if __name__ == "__main__":
    print("Starting Job API Tests...")
    print("Make sure the backend server is running on http://localhost:8000")
    print()
    
    results = []
    results.append(test_create_job())
    results.append(test_create_job_without_optional_fields())
    results.append(test_fetch_jobs())
    results.append(test_fetch_my_jobs())
    
    print("\n" + "=" * 60)
    print("TEST SUMMARY")
    print("=" * 60)
    passed = sum(results)
    total = len(results)
    print(f"Passed: {passed}/{total}")
    
    if passed == total:
        print("All tests passed!")
    else:
        print("Some tests failed. Check the output above.")
