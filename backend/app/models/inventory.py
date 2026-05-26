"""
Inventory Pydantic Models
"""

from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from enum import Enum


class StockStatus(str, Enum):
    HEALTHY = "healthy"
    LOW = "low"
    CRITICAL = "critical"
    OUT_OF_STOCK = "out_of_stock"


class MaterialBase(BaseModel):
    """Base material/part definition."""
    part_number: str = Field(..., description="Unique part identifier (e.g., BRK-PAD-001)")
    name: str = Field(..., description="Human-readable material name")
    description: Optional[str] = None
    category: str = Field(..., description="Category: raw_material, component, consumable")
    unit: str = Field(default="pcs", description="Unit of measure: pcs, kg, litre, metre")
    min_stock_level: float = Field(default=0, description="Minimum stock before reorder alert")
    reorder_quantity: float = Field(default=0, description="Standard reorder quantity")
    unit_price: float = Field(default=0, description="Price per unit in INR")


class MaterialCreate(MaterialBase):
    pass


class Material(MaterialBase):
    id: str
    is_active: bool = True
    created_at: datetime
    updated_at: datetime


class InventoryBase(BaseModel):
    """Current stock level for a material at a specific warehouse."""
    material_id: str
    warehouse: str = Field(default="main", description="Warehouse identifier")
    current_stock: float = Field(..., description="Current quantity in stock")
    reserved_stock: float = Field(default=0, description="Quantity reserved for production")


class InventoryCreate(InventoryBase):
    pass


class Inventory(InventoryBase):
    id: str
    available_stock: float = Field(default=0, description="current_stock - reserved_stock")
    stock_status: StockStatus = StockStatus.HEALTHY
    last_updated: datetime
    days_until_stockout: Optional[float] = None


class InventoryHealth(BaseModel):
    """Aggregated inventory health for dashboard."""
    material_id: str
    material_name: str
    part_number: str
    category: str
    current_stock: float
    min_stock_level: float
    daily_consumption_rate: float
    days_until_stockout: Optional[float]
    stock_status: StockStatus
    stock_value_inr: float


class ConsumptionLog(BaseModel):
    """Historical material consumption record."""
    id: str
    material_id: str
    quantity_consumed: float
    consumed_date: datetime
    production_order_ref: Optional[str] = None
    notes: Optional[str] = None
