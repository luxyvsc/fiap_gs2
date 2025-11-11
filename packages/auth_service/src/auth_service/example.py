"""
Example FastAPI application demonstrating Firebase Authentication.

This is an example microservice showing how to use the auth_service package.
"""

from fastapi import Depends, FastAPI
from fastapi.middleware.cors import CORSMiddleware

from auth_service import (
    AuthUser,
    init_firebase_admin,
    require_any_role,
    require_role,
    verify_firebase_token,
)

# Initialize FastAPI app
app = FastAPI(
    title="Example Auth Microservice",
    description="Example microservice using Firebase Authentication",
    version="1.0.0",
)

# Enable CORS for frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
async def startup():
    """Initialize Firebase Admin on startup."""
    try:
        init_firebase_admin()
        print("✅ Firebase Admin initialized successfully")
    except Exception as e:
        print(f"❌ Failed to initialize Firebase Admin: {e}")
        # In production, you might want to fail startup if Firebase can't initialize


@app.get("/")
async def root():
    """Public endpoint - no authentication required."""
    return {
        "message": "Example Firebase Auth Microservice",
        "status": "running",
        "auth": "Firebase Authentication",
    }


@app.get("/health")
async def health_check():
    """Health check endpoint - no authentication required."""
    return {"status": "healthy"}


@app.get("/api/v1/protected")
async def protected_route(user: AuthUser = Depends(verify_firebase_token)):
    """
    Protected endpoint - requires valid Firebase ID token.

    Send request with Authorization header:
    Authorization: Bearer <firebase_id_token>
    """
    return {
        "message": f"Hello, {user.name or user.email}!",
        "user": {
            "uid": user.uid,
            "email": user.email,
            "email_verified": user.email_verified,
            "role": user.role,
            "tenant_id": user.tenant_id,
        },
    }


@app.get("/api/v1/user/profile")
async def get_profile(user: AuthUser = Depends(verify_firebase_token)):
    """Get current user profile."""
    return {
        "uid": user.uid,
        "email": user.email,
        "name": user.name,
        "picture": user.picture,
        "email_verified": user.email_verified,
        "role": user.role,
        "tenant_id": user.tenant_id,
        "custom_claims": user.custom_claims,
    }


@app.get("/api/v1/admin/users")
async def list_users(user: AuthUser = Depends(require_role("admin"))):
    """
    Admin-only endpoint.
    Only users with role="admin" can access.
    """
    return {
        "message": "Admin access granted",
        "admin_uid": user.uid,
        "users": [
            # In real application, fetch from database
            {"uid": "user1", "email": "user1@example.com", "role": "user"},
            {"uid": "user2", "email": "user2@example.com", "role": "recruiter"},
        ],
    }


@app.post("/api/v1/recruiter/post-job")
async def post_job(
    job_title: str,
    user: AuthUser = Depends(require_any_role("admin", "recruiter")),
):
    """
    Endpoint accessible by admins and recruiters.
    """
    return {
        "message": f"Job posted by {user.email}",
        "job_title": job_title,
        "posted_by": user.uid,
        "role": user.role,
    }


@app.get("/api/v1/tenant/{tenant_id}/data")
async def get_tenant_data(
    tenant_id: str,
    user: AuthUser = Depends(verify_firebase_token),
):
    """
    Tenant-specific data endpoint.
    Users can only access data from their own tenant (unless admin).
    """
    # Check tenant access
    if user.tenant_id != tenant_id and user.role != "admin":
        from fastapi import HTTPException

        raise HTTPException(
            status_code=403,
            detail=f"Access denied. User belongs to tenant {user.tenant_id}",
        )

    return {
        "tenant_id": tenant_id,
        "data": f"Data for tenant {tenant_id}",
        "accessed_by": user.uid,
    }


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
