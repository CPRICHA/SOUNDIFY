from pydantic import BaseModel, EmailStr
from typing import List, Optional
from datetime import datetime

class UserSignUp(BaseModel):
    name: str
    age: int
    phone: Optional[str] = None
    email: EmailStr
    password: str
    micAccess: bool = False
    termsAccepted: bool = False
    privacyPolicyAccepted: bool = False

class UserSignIn(BaseModel):
    email: EmailStr
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str
    user_id: str

class UserProfileResponse(BaseModel):
    id: str
    name: str
    age: int
    phone: Optional[str] = None
    email: EmailStr
    micAccess: bool
    termsAccepted: bool
    privacyPolicyAccepted: bool
    outputPreferences: List[str]

class UserProfileUpdate(BaseModel):
    name: Optional[str] = None
    age: Optional[int] = None
    phone: Optional[str] = None
    outputPreferences: Optional[List[str]] = None

class SoundLabelSchema(BaseModel):
    id: str
    name: str
    environment: str
    category: str
    severity: str
    iconName: str

class SoundEventCreate(BaseModel):
    user_id: str
    label: str
    severity: str
    mode: str
    timestamp: datetime

class SoundEventResponse(BaseModel):
    id: str
    user_id: str
    label: str
    severity: str
    mode: str
    timestamp: datetime

class EmergencyContactTrigger(BaseModel):
    user_id: str
    message: str
    action_type: str # e.g. 'CALL_EMERGENCY' or 'REACHED_SAFE_SPOT'
