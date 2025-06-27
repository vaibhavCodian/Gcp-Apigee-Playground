# Reports Service - FastAPI skeleton
from fastapi import FastAPI
from pydantic import BaseModel
from typing import List

app = FastAPI(title="Reports Service", description="Generates analytics and reporting data.")

class Report(BaseModel):
    report_id: str
    summary: str

reports: List[Report] = []

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/v1/generate", response_model=List[Report])
def generate_reports():
    # Dummy data for demo
    return [Report(report_id="r1", summary="Inventory low on SKU123"), Report(report_id="r2", summary="10 orders pending")]
