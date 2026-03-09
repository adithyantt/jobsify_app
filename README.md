# Jobsify 🚀

A full-stack mobile application for connecting employers with skilled workers. Built with Flutter for the frontend and FastAPI for the backend.

![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?style=flat&logo=flutter)
![FastAPI](https://img.shields.io/badge/FastAPI-0.104+-009688?style=flat&logo=fastapi)
![License](https://img.shields.io/badge/License-MIT-green)

## 📱 Overview

Jobsify is a job marketplace platform that enables:
- **Employers** to post jobs and find skilled workers nearby
- **Workers** to create profiles showcasing their skills and availability  
- **Admins** to manage users, content moderation through reports system

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Frontend                              │
│                     (Flutter App)                            │
│                                                              │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌───────────────┐  │
│  │ Auth     │ │ Jobs     │ │ Workers  │ │ Admin Panel    │  │
│  └──────────┘ └──────────┘ └──────────┘ └───────────────┘  │
└─────────────────────────────────────────────────────────────┘
                           ↕ REST API (HTTP)
                         Port: 8000 
                         IP: http://172.22.39.105/
└─────────────────────────────────────────────────────────────┐
│                        Backend                               │
│                    (FastAPI Server)                          │
|      /auth ──► JWT Authentication                           |
|      /jobs ──► Job CRUD Operations                          |
|      /workers ► Worker Management                           |
|      /reviews ► Rating & Reviews                            |
|      /admin ──► Admin Dashboard                             |
└─────────────────────────────────────────────────────────────┘    
```

## ✨ Features

### User Features 🔑
- 📝 User Registration & Login with OTP Verification  
- 🔍 Find Jobs by category and location  
- 👷 Find Workers by skill type  
- ⭐ Rate and Review Workers  
- 💾 Save Favorite Jobs  

### Employer Features 💼 
- 📋 Post New Job Listings  
- ✅ Manage Posted Jobs  
- 👥 Contact Available Workers  

### Worker Features 👷‍♂️ 
| Feature | Description |
|---------|-------------|
| Profile Creation | Create detailed worker profile |
| Availability Toggle | Show/hide availability status |
| Skill Showcase | Display experience & expertise |

### Admin Features ⚙️ 
| Feature | Description |
|---------|-------------|
| Dashboard Stats | View platform statistics |
| User Management | View all registered users |
| Job Verification | Approve/reject job postings |
| Worker Verification | Approve/reject worker profiles |
| Reports | Handle user reports |

## 🛠️ Tech Stack 

### Frontend Technologies 🌐 

|Package|Purpose|
|-------|-------|
|`http`|REST API communication|
|`geolocator`|GPS location services|
|`shared_preferences`|Local key-value storage|

---

### Backend Technologies ⚙️ 

```python
# Core Framework
fastapi              # Modern web framework               
# Database           
sqlalchemy           # ORM                                
# Authentication     
python-jose          # JWT token generation               
passlib              # Password hashing                   
# Utilities          
pydantic             # Data validation                    
```

---

## 📂 Project Structure 

```
jobsify/
├── lib/                          ← Flutter Source Code   
├── ├── main.dart                 ← App Entry Point       
├── ├── models/                   ← Data Models           
├── ├── screens/                  ← UI Screens            
│   ├── auth/                     ← Auth Screens         
│   ├── jobs/                     ← Job Related Screens  
│   ├── workers/                  ← Worker Screens       
│   ├── admin/                    ← Admin Panel          
│   ├── home/                     ← Home Screen          
│   ├── profile/                  ← Profile Screen       
│   ├── settings/                 ← Settings Screen      
│   └── splash/                   ← Splash Screen        
├── services/                     ← Business Logic       
├── utils/                        ← Utilities            
└── widgets/                      ← Reusable Widgets     
    
jobsify_backend/
├── app/
│   ├── main.py                   ← FastAPI Entry Point  
│   ├── database.py               ← Database Config      
│   ├── models/                   ← SQLAlchemy Models    
│   │   ├── user.py               
│   │   ├── job.py                
│   │   ├── workers.py            
│   │   ├── review.py             
│   │   ├── notification.py       
│   │   └── report.py             
│   ├── routers/                  ← API Endpoints        
│   │   ├── auth.py               
│   │   ├── jobs.py               
│   │   ├── workers.py            
│   │   ├── reviews.py            
│   │   ├── notifications.py      
│   │   └── admin.py              
│   └── schemas/                  ← Pydantic Schemas     
├── requirements.txt              ← Python Dependencies   
└── venv/                         ← Virtual Environment   
```

---

## 🚀 Getting Started 

### Prerequisites 

Before you begin ensure you have installed:

✅ [Python](https://www.python.org/downloads) version >=3.x  

✅ [Flutter SDK](https://docs.flutter.dev/get-started/install)

✅ Android Studio or VS Code configured properly 

---

### Frontend Setup

#### Step 1: Install Dependencies

```powershell
flutter pub get
```

#### Step 2: Run the Application

```powershell
flutter run
```

Or for release build:

```powershell
flutter run --release
```

**Note:** Ensure your device/emulator can connect to `http://172.22.39.105:8000`. If not, update the IP address in these files:
- `lib/utils/api_endpoints.dart`
- `lib/services/auth_service.dart`
- `lib/services/job_service.dart`
- `lib/services/worker_service.dart`

---

### Backend Setup

#### Step 1: Navigate to Backend Folder

```powershell
cd jobsify_backend
```

#### Step 2: Create Virtual Environment

```powershell
python -m venv venv
```

#### Step 3: Activate Virtual Environment

**Windows:**
```powershell
venv\Scripts\Activate.ps1
```

**Linux/Mac:**
```bash
source venv/bin/activate
```

#### Step 4: Install Dependencies

```powershell
pip install -r requirements.txt
```

#### Step 5: Run the Server

```powershell
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

The server will start at `http://localhost:8000`

#### Step 6: Access API Documentation

Visit `http://localhost:8000/docs` for interactive API documentation (Swagger UI)

---

## 🔐 Admin Credentials

For testing purposes, admin access is available with these predefined emails:

- `admin@jobsify.com`
- `jobsify.admin@gmail.com`
- `superadmin@jobsify.com`

Register with any of these emails to get admin privileges.

---

## 📡 API Endpoints

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/register` | Register new user |
| POST | `/auth/login` | Login user |
| POST | `/auth/verify-otp` | Verify email OTP |
| GET | `/auth/me` | Get current user |

### Jobs
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/jobs` | Get all verified jobs |
| GET | `/jobs/{id}` | Get job by ID |
| POST | `/jobs` | Create new job |
| GET | `/jobs/my?email=x` | Get user's jobs |
| GET | `/jobs/saved?email=x` | Get saved jobs |
| PUT | `/jobs/admin/approve/{id}` | Approve job (admin) |
| PUT | `/jobs/admin/reject/{id}` | Reject job (admin) |

### Workers
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/workers` | Get all verified workers |
| GET | `/workers/{id}` | Get worker by ID |
| POST | `/workers` | Create worker profile |
| GET | `/workers/my?email=x` | Get user's workers |
| GET | `/workers/admin/pending` | Get pending workers (admin) |
| PUT | `/workers/admin/approve/{id}` | Approve worker (admin) |
| PUT | `/workers/admin/reject/{id}` | Reject worker (admin) |

### Admin
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/admin/stats` | Get platform statistics |
| GET | `/admin/users` | Get all users |
| PUT | `/admin/users/block` | Block user |

### Reviews
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/reviews/worker/{id}` | Get worker reviews |
| POST | `/reviews` | Create review |

### Notifications
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/notifications?user_email=x` | Get user notifications |

---

## 🧪 Testing

### Run Backend Tests

```powershell
cd jobsify_backend
python test_backend.py
```

### Test API Endpoints

Using curl:

```powershell
# Test root endpoint
curl http://localhost:8000/

# Test login
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com", "password": "password123"}'
```

---

## 📱 Mobile App Screens

### User Screens
- **Splash Screen** - App loading with logo
- **Login Screen** - Email/password authentication
- **Register Screen** - New user registration
- **OTP Verification** - Email verification
- **Home Screen** - Main dashboard with job/worker tabs
- **Find Jobs** - Browse and search jobs
- **Find Workers** - Browse and search workers
- **Job Detail** - View job details
- **Worker Detail** - View worker profile
- **Profile** - User profile management
- **Settings** - App settings

### Admin Screens
- **Admin Dashboard** - Platform statistics
- **User Management** - View and block users
- **Job Verification** - Approve/reject jobs
- **Worker Verification** - Approve/reject workers

---

## 🔧 Configuration

### Backend IP Configuration

If running on a different IP, update the base URL in:

1. `lib/utils/api_endpoints.dart`
2. `lib/services/auth_service.dart`
3. `lib/services/job_service.dart`
4. `lib/services/worker_service.dart`

Change from:
```dart
static const String baseUrl = "http://172.22.39.105:8000";
```

To your actual server IP.

---

## 📄 License

This project is licensed under the MIT License.

---

## 👤 Author

Built with ❤️ by Jobsify Team

For issues and feature requests, please open an issue on GitHub.
