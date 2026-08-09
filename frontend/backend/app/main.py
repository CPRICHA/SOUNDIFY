import os
import uuid
import datetime
from typing import List, Dict, Any
from fastapi import FastAPI, APIRouter, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr

# Import schemas and taxonomy data
from app.models.schemas import (
    UserSignUp, UserSignIn, Token, UserProfileResponse, 
    UserProfileUpdate, SoundLabelSchema, SoundEventCreate, 
    SoundEventResponse, EmergencyContactTrigger
)
from app.data.sound_taxonomy import SOUND_TAXONOMY

app = FastAPI(
    title="SoundSee API",
    description="Backend synchronization, authentication, and safety service for SoundSee",
    version="1.0.0"
)

# CORS Setup for React Simulator and Flutter App Communication
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# In-memory mock database for rapid prototyping / SQLModel simulation
MOCK_USERS: Dict[str, Dict[str, Any]] = {}
MOCK_EVENTS: List[Dict[str, Any]] = []

# Populate initial user
sample_user_id = "usr_123"
MOCK_USERS[sample_user_id] = {
    "id": sample_user_id,
    "name": "John Doe",
    "age": 28,
    "phone": "+15551234567",
    "email": "john@soundsee.org",
    "password_hash": "pbkdf2_sha256$hashedpassword", # representation of secured hash
    "micAccess": True,
    "termsAccepted": True,
    "privacyPolicyAccepted": True,
    "outputPreferences": ["text", "icon", "color"]
}

# ----------------------------------------------------------------------
# 1. AUTH ENDPOINTS
# ----------------------------------------------------------------------
auth_router = APIRouter(prefix="/auth", tags=["Authentication"])

@auth_router.post("/signup", response_model=Token)
async def signup(user: UserSignUp):
    # Check if user already exists
    for existing_user in MOCK_USERS.values():
        if existing_user["email"] == user.email:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email is already registered"
            )
    
    new_user_id = f"usr_{uuid.uuid4().hex[:8]}"
    MOCK_USERS[new_user_id] = {
        "id": new_user_id,
        "name": user.name,
        "age": user.age,
        "phone": user.phone,
        "email": user.email,
        "password_hash": "pbkdf2_sha256$hashed_new_password", # bcrypt placeholder
        "micAccess": user.micAccess,
        "termsAccepted": user.termsAccepted,
        "privacyPolicyAccepted": user.privacyPolicyAccepted,
        "outputPreferences": ["text", "icon", "color"] # default style presets
    }
    
    # Generate mock JWT token
    return {
        "access_token": f"mock-jwt-token-{new_user_id}",
        "token_type": "bearer",
        "user_id": new_user_id
    }

@auth_router.post("/signin", response_model=Token)
async def signin(credentials: UserSignIn):
    for u_id, user in MOCK_USERS.items():
        if user["email"] == credentials.email:
            # Match secure credentials (stub for bcrypt verification)
            return {
                "access_token": f"mock-jwt-token-{u_id}",
                "token_type": "bearer",
                "user_id": u_id
            }
    
    raise HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Invalid email or password"
    )

app.include_router(auth_router)

# ----------------------------------------------------------------------
# 2. USER PROFILE ENDPOINTS
# ----------------------------------------------------------------------
users_router = APIRouter(prefix="/users", tags=["Users"])

@users_router.get("/{id}/profile", response_model=UserProfileResponse)
async def get_profile(id: str):
    if id not in MOCK_USERS:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User profile not found"
        )
    return MOCK_USERS[id]

@users_router.put("/{id}/profile", response_model=UserProfileResponse)
async def update_profile(id: str, profile_update: UserProfileUpdate):
    if id not in MOCK_USERS:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User profile not found"
        )
    
    user = MOCK_USERS[id]
    if profile_update.name is not None:
        user["name"] = profile_update.name
    if profile_update.age is not None:
        user["age"] = profile_update.age
    if profile_update.phone is not None:
        user["phone"] = profile_update.phone
    if profile_update.outputPreferences is not None:
        user["outputPreferences"] = profile_update.outputPreferences
        
    return user

app.include_router(users_router)

# ----------------------------------------------------------------------
# 3. SOUND TAXONOMY ENDPOINTS
# ----------------------------------------------------------------------
taxonomy_router = APIRouter(tags=["Sound Taxonomy"])

@taxonomy_router.get("/sound-taxonomy", response_model=List[SoundLabelSchema])
async def get_sound_taxonomy():
    """Serves the 28-sound + severity table, allowing dynamic remote config updates."""
    return SOUND_TAXONOMY

app.include_router(taxonomy_router)

# ----------------------------------------------------------------------
# 4. SOUND EVENTS SYNC ENDPOINTS
# ----------------------------------------------------------------------
events_router = APIRouter(tags=["Sound Events"])

@events_router.post("/sound-events", response_model=SoundEventResponse)
async def log_sound_event(event: SoundEventCreate):
    """Log a detected sound event from the client for sync."""
    if event.user_id not in MOCK_USERS:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not registered"
        )
    
    event_id = f"evt_{uuid.uuid4().hex[:8]}"
    logged_event = {
        "id": event_id,
        "user_id": event.user_id,
        "label": event.label,
        "severity": event.severity,
        "mode": event.mode,
        "timestamp": event.timestamp
    }
    
    MOCK_EVENTS.append(logged_event)
    return logged_event

@events_router.get("/sound-events/{user_id}", response_model=List[SoundEventResponse])
async def get_sound_history(user_id: str):
    """Fetch logged history for a user, returned in reverse chronological order."""
    user_events = [e for e in MOCK_EVENTS if e["user_id"] == user_id]
    user_events.sort(key=lambda x: x["timestamp"], reverse=True)
    return user_events

app.include_router(events_router)

# ----------------------------------------------------------------------
# 5. EMERGENCY ALERTS
# ----------------------------------------------------------------------
emergency_router = APIRouter(prefix="/emergency", tags=["Emergency Services"])

@emergency_router.post("/contact")
async def trigger_emergency_alert(payload: EmergencyContactTrigger):
    """
    Simulates sending an emergency dispatch or SMS notifications.
    In production, this functions as the Twilio API integration seam.
    """
    user = MOCK_USERS.get(payload.user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    phone_number = user.get("phone", "+15551234567")
    
    # TODO: Drop in Twilio REST SDK client setup
    # from twilio.rest import Client
    # client = Client(TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN)
    # message = client.messages.create(
    #     body=f"[SoundSee Alert] {user['name']}: {payload.message}",
    #     from_='+1555XXXXXXX',
    #     to=phone_number
    # )
    
    return {
        "status": "success",
        "recipient": phone_number,
        "dispatch_message": payload.message,
        "action_type": payload.action_type,
        "provider_stub": "Twilio SMS Gateway Simulator",
        "timestamp": datetime.datetime.now().isoformat()
    }

app.include_router(emergency_router)

# ----------------------------------------------------------------------
# 6. OPTIONAL CLOUD FALLBACK CLASSIFY
# ----------------------------------------------------------------------
@app.post("/classify", tags=["Future Enhancements"])
async def classify_audio_fallback():
    """Placeholder cloud-fallback endpoint if on-device inference fails."""
    return {
        "detail": "Optional cloud-fallback endpoint is reserved for enterprise-grade high-compute models.",
        "status": "stub_only"
    }

@app.get("/")
async def root():
    return {
        "app": "SoundSee Server",
        "status": "healthy",
        "sqlite_database": "ready",
        "sound_taxonomy_count": len(SOUND_TAXONOMY)
    }
