from fastapi import FastAPI, Request, HTTPException, status, Depends
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from pydantic import BaseModel
from typing import Optional
import httpx
import os

app = FastAPI(title="Facade Service", description="Central gateway for user-facing interactions.")

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/token")

# Dummy user store for demo
users_db = {"user": {"username": "user", "password": "pass"}}

class Token(BaseModel):
    access_token: str
    token_type: str

@app.post("/token", response_model=Token, tags=["OAuth2"])
def login(form_data: OAuth2PasswordRequestForm = Depends()):
    user = users_db.get(form_data.username)
    if not user or user["password"] != form_data.password:
        raise HTTPException(status_code=400, detail="Incorrect username or password")
    # In real app, generate JWT
    return {"access_token": "demo-token", "token_type": "bearer"}

@app.post("/introspect", tags=["OAuth2"])
def introspect(token: str):
    # Dummy introspection
    if token == "demo-token":
        return {"active": True, "username": "user"}
    return {"active": False}

@app.get("/aggregate", tags=["Aggregation"])
def aggregate(token: str = Depends(oauth2_scheme)):
    # Aggregate data from inventory, orders, reports
    inventory_url = os.environ.get("INVENTORY_URL", "http://inventory-service:8080")
    orders_url = os.environ.get("ORDERS_URL", "http://orders-service:8080")
    reports_url = os.environ.get("REPORTS_URL", "http://reports-service:8080")
    result = {}
    with httpx.Client() as client:
        try:
            result["inventory"] = client.get(f"{inventory_url}/health").json()
        except Exception:
            result["inventory"] = "unavailable"
        try:
            result["orders"] = client.get(f"{orders_url}/health").json()
        except Exception:
            result["orders"] = "unavailable"
        try:
            result["reports"] = client.get(f"{reports_url}/health").json()
        except Exception:
            result["reports"] = "unavailable"
    return result

@app.get("/health", tags=["Health"])
def health():
    return {"status": "ok"}

# Add logging, error handling, input validation, etc. as needed
