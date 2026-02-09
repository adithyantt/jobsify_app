import sys
import os
sys.path.append('../jobsify_backend')

from app.database import SessionLocal
from app.models.user import User

db = SessionLocal()

# Check if admin users exist
admin_emails = [
    "admin@jobsify.com",
    "jobsify.admin@gmail.com",
    "superadmin@jobsify.com"
]

for email in admin_emails:
    user = db.query(User).filter(User.email == email).first()
    if user:
        print(f"Admin user found: {email} - Role: {user.role} - Verified: {user.email_verified}")
    else:
        print(f"Admin user NOT found: {email}")

# List all users
print("\nAll users in database:")
users = db.query(User).all()
for user in users:
    print(f"ID: {user.id}, Email: {user.email}, Role: {user.role}, Verified: {user.email_verified}")

db.close()
