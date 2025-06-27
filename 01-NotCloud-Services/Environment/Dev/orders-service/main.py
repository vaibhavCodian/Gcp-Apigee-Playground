# Orders Service - FastAPI skeleton
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Dict

app = FastAPI(title="Orders Service", description="Handles order creation, validation, and status tracking.")

class Order(BaseModel):
    order_id: str
    sku: str
    quantity: int
    status: str = "created"

orders: Dict[str, Order] = {}

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/v1/orders", response_model=Order)
def create_order(order: Order):
    if order.order_id in orders:
        raise HTTPException(status_code=400, detail="Order already exists")
    orders[order.order_id] = order
    return order

@app.get("/v1/orders/{order_id}")
def get_order(order_id: str):
    order = orders.get(order_id)
    if not order:
        raise HTTPException(status_code=404, detail="Order not found")
    return order
