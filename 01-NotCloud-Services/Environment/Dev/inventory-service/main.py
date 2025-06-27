# Inventory Service - FastAPI skeleton
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import Dict

app = FastAPI(title="Inventory Service", description="Tracks SKUs, stock levels, and availability.")

class Item(BaseModel):
    sku: str
    name: str
    stock: int

inventory: Dict[str, Item] = {}

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/v1/stock", response_model=Item)
def add_item(item: Item):
    inventory[item.sku] = item
    return item

@app.get("/v1/stock")
def get_stock(sku: str):
    item = inventory.get(sku)
    if not item:
        raise HTTPException(status_code=404, detail="SKU not found")
    return item
