from fastapi import FastAPI, Request, Header, HTTPException, status, Body
from typing import Optional, List

app = FastAPI(
    title="CloudBot DevOps API Playground",
    description="An upgraded FastAPI backend simulating an internal developer platform with mock GCP resource management. Still includes Apigee demo endpoints.",
    openapi_tags=[
        {"name": "Hello", "description": "Simple hello endpoint"},
        {"name": "Security", "description": "OAuth2/JWT protected endpoints for authentication demo"},
        {"name": "Rate Limiting", "description": "Endpoints to demonstrate Apigee/Gateway rate limiting"},
        {"name": "Echo", "description": "Endpoints that echo request headers or body for pre/postflow demo"},
        {"name": "Headers/Env", "description": "Endpoints to inspect request headers and environment variables"},
        {"name": "CloudOps", "description": "Simulated GCP resource management (mock buckets, jobs, etc.)"},
        {"name": "Info", "description": "API metadata and status endpoints"}
    ]
)

# In-memory fake storage for mock resources
fake_buckets = []
fake_jobs = {}

@app.get(
    "/hello",
    tags=["Hello"],
    description="Returns a simple hello message to verify API connectivity."
)
def hello():
    return {"message": "Hello from CloudBot DevOps API Playground!"}

@app.get(
    "/secure",
    tags=["Security"],
    description="OAuth2/JWT protected endpoint. Requires a valid Bearer token in the Authorization header."
)
def secure(authorization: Optional[str] = Header(None)):
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Missing or invalid token")
    token = authorization.split(" ", 1)[1]
    if token != "test-token":
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
    return {"message": "Secure data", "token": token}

@app.get(
    "/ratelimit",
    tags=["Rate Limiting"],
    description="Endpoint for demonstrating Apigee or API Gateway rate limiting/quota policies."
)
def ratelimit():
    return {"message": "This endpoint is rate-limited by Apigee proxy policies."}

@app.get(
    "/prepost",
    tags=["Echo"],
    description="Echoes request headers for preflow/postflow demonstration."
)
def prepost(request: Request):
    headers = dict(request.headers)
    return {"message": "Preflow/Postflow demo", "headers": headers}

@app.post(
    "/echo",
    tags=["Echo"],
    description="Echoes the request body and headers for testing API proxy transformations."
)
async def echo(request: Request):
    try:
        body = await request.json()
    except Exception:
        body = await request.body()
    headers = dict(request.headers)
    return {"echo": body, "headers": headers}

@app.get(
    "/status",
    tags=["Info"],
    description="Returns API status for health checks and monitoring."
)
def status_check():
    return {"status": "ok"}

@app.get(
    "/headers",
    tags=["Headers/Env"],
    description="Returns all request headers for debugging and inspection."
)
def headers(request: Request):
    return {"headers": dict(request.headers)}

@app.get(
    "/env",
    tags=["Headers/Env"],
    description="Returns environment variables for debugging (do not expose in production)."
)
def env():
    import os
    return {"env": dict(os.environ)}

@app.get(
    "/buckets",
    tags=["CloudOps"],
    description="Lists all mock GCP buckets in the in-memory store."
)
def list_buckets():
    return {"buckets": fake_buckets}

@app.post(
    "/buckets",
    tags=["CloudOps"],
    description="Creates a new mock GCP bucket and adds it to the in-memory store."
)
def create_bucket(name: str = Body(..., embed=True)):
    fake_buckets.append(name)
    return {"message": f"Bucket '{name}' created.", "buckets": fake_buckets}

@app.get(
    "/jobs",
    tags=["CloudOps"],
    description="Lists all mock GCP jobs in the in-memory store."
)
def list_jobs():
    return {"jobs": fake_jobs}

@app.post(
    "/jobs",
    tags=["CloudOps"],
    description="Creates a new mock GCP job and adds it to the in-memory store."
)
def create_job(job_id: str = Body(..., embed=True), job_data: dict = Body(...)):
    fake_jobs[job_id] = job_data
    return {"message": f"Job '{job_id}' created.", "jobs": fake_jobs}
