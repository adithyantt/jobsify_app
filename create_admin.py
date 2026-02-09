import sys
import os
sys.path.append('../jobsify_backend')

from app.database import SessionLocal, engine
from app.models.user import User
import bcrypt

# Create tables if they don't exist
from app.database import Base
Base.metadata.create_all(bind=engine)

# Create admin users
admin_emails = [
    "admin@jobsify.com",
    "jobsify.admin@gmail.com",
    "superadmin@jobsify.com"
]

default_password = "admin123"
hashed_password = bcrypt.hashpw(default_password.encode(), bcrypt.gensalt()).decode()

db = SessionLocal()

for email in admin_emails:
    # Check if admin already exists
    existing_admin = db.query(User).filter(User.email == email).first()
    if not existing_admin:
        admin_name = email.split('@')[0].replace('.', ' ').title()
        new_admin = User(
            name=admin_name,
            email=email,
            password=hashed_password,
            role="admin",
            phone=None,
            verified=True,
            email_verified=True
        )
        db.add(new_admin)
        print(f"Created admin user: {email}")
    else:
        print(f"Admin user already exists: {email}")

db.commit()
db.close()

print("Admin users created successfully!")
