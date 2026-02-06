# ✅ Jobsify - Quick Action Guide

## Frontend Status: ✅ FIXED

### Changes Made:
1. ✅ Fixed Worker Service base URL: `http://YOUR_IP:8000` → `http://172.22.39.105:8000`
2. ✅ Standardized API Endpoints base URL: `http://127.0.0.1:8000` → `http://172.22.39.105:8000`
3. ✅ Fixed Worker Detail Screen import error

**Result:** All frontend compilation errors resolved. No errors found.

---

## Backend Validation Required

### What to Check:

Navigate to your backend folder and verify these files exist and are correctly configured:

```powershell
cd C:\Users\Adithyan T T\jobsify_backend
```

#### 1. Check `app/main.py`
Ensure it has:
- CORS enabled for frontend IP
- All routers properly imported
- Server listens on `0.0.0.0:8000`

#### 2. Check `app/routers/auth.py`
Required endpoints:
- `POST /auth/login` - Returns: `{role, email, token}`
- `POST /auth/register` - Accepts: `{name, email, password}`
- `GET /auth/profile?email=...` - Returns: `{id, name, email, role}`

#### 3. Check `app/routers/jobs.py`
Required endpoints:
- `GET /jobs` - Returns: `[{id, title, category, location, description, phone}]`
- `POST /jobs` - Accepts: `{title, category, description, location, phone}`

#### 4. Check `app/routers/workers.py`
Required endpoints:
- `GET /workers` - Returns: `[{id, name, role, phone, experience, rating, reviews, location, is_available, is_verified}]`
- `POST /workers` - Accepts: `{name, role, phone, experience, location}`

#### 5. Check `app/models/`
Verify database models use snake_case for fields:
- `is_available` (not `isAvailable`)
- `is_verified` (not `isVerified`)

---

## How to Test Backend

### Option 1: Using Postman
1. Create a new request
2. POST to `http://172.22.39.105:8000/auth/login`
3. Headers: `Content-Type: application/json`
4. Body: 
```json
{
  "email": "test@example.com",
  "password": "password123"
}
```

### Option 2: Using cURL
```powershell
$headers = @{"Content-Type" = "application/json"}
$body = @{email = "test@example.com"; password = "password123"} | ConvertTo-Json

Invoke-WebRequest -Uri "http://172.22.39.105:8000/auth/login" `
  -Headers $headers `
  -Body $body `
  -Method POST
```

### Option 3: Run Backend Server
```powershell
# Activate venv
venv\Scripts\Activate.ps1

# Start server
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Then test from terminal:
```powershell
# Test if server is running
curl http://172.22.39.105:8000/docs
```

---

## Expected Response Formats

### Login Response
```json
{
  "role": "employer",
  "email": "user@example.com",
  "token": "jwt_token_here"
}
```

### Workers Response
```json
[
  {
    "id": 1,
    "name": "John Doe",
    "role": "Plumber",
    "phone": "9876543210",
    "experience": 5,
    "rating": 4.5,
    "reviews": 12,
    "location": "Kochi, Kerala",
    "is_available": true,
    "is_verified": true
  }
]
```

### Jobs Response
```json
[
  {
    "id": 1,
    "title": "Fix Bathroom Tap",
    "category": "Plumbing",
    "location": "Kochi",
    "description": "Need to fix a leaking tap",
    "phone": "9876543210"
  }
]
```

---

## Final Checklist

- [x] Frontend: No compilation errors
- [x] Frontend: All imports correct
- [x] Frontend: Base URLs standardized to `http://172.22.39.105:8000`
- [ ] Backend: Routes exist and respond
- [ ] Backend: CORS enabled
- [ ] Backend: Database models match Frontend expectations
- [ ] Backend: Response formats match Frontend models
- [ ] Backend: Server running on correct IP and port
- [ ] Network: Frontend can reach backend IP (172.22.39.105:8000)

---

## If You Need to Change Server IP

If your backend is on a different IP, update these files:

1. `lib/services/auth_service.dart` - Line 3
2. `lib/services/job_service.dart` - Line 6
3. `lib/services/worker_service.dart` - Line 5
4. `lib/utils/api_endpoints.dart` - Line 1

All should use the same IP format: `http://YOUR_ACTUAL_IP:8000`

---

## Next Steps

1. **Verify Backend Routes** - Open `app/routers/` and check each file
2. **Test API Endpoints** - Use Postman or cURL to test
3. **Check Response Formats** - Compare with expected formats above
4. **Enable CORS** - Update `app/main.py` if needed
5. **Run Flutter App** - Test with `flutter run`

For detailed validation report, see: `VALIDATION_REPORT.md`
