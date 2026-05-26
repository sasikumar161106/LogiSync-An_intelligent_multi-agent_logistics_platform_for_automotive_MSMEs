"""
Supplier Pydantic Models
"""

from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from enum import Enum


class SupplierType(str, Enum):
    LOCAL = "local"
    DOMESTIC = "domestic"
    INTERNATIONAL = "international"


class SupplierBase(BaseModel):
    """Supplier master data."""
    name: str = Field(..., description="Company name")
    supplier_type: SupplierType = Field(..., description="local, domestic, or international")
    location: str = Field(..., description="City/region")
    contact_person: Optional[str] = None
    phone: Optional[str] = None
    email: Optional[str] = None
    lead_time_days: int = Field(..., description="Standard lead time in days")
    reliability_score: float = Field(
        default=0.8,
        ge=0.0,
        le=1.0,
        description="0.0 to 1.0 reliability rating based on historical performance"
    )
    port_of_entry: Optional[str] = Field(
        None,
        description="For international: chennai_port or ennore_port"
    )
    materials_supplied: list[str] = Field(
        default_factory=list,
        description="List of material categories this supplier provides"
    )
    payment_terms: Optional[str] = Field(None, description="e.g., Net 30, Advance")
    notes: Optional[str] = None


class SupplierCreate(SupplierBase):
    pass


class Supplier(SupplierBase):
    id: str
    is_active: bool = True
    total_orders: int = 0
    on_time_delivery_rate: float = 0.0
    created_at: datetime
    updated_at: datetime


class SupplierWithRanking(Supplier):
    """Supplier with AI-computed ranking for procurement decisions."""
    cost_score: float = 0.0
    speed_score: float = 0.0
    overall_rank: int = 0
    is_backup: bool = False
