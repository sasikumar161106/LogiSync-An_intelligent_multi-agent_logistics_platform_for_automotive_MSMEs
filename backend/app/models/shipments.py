"""
Shipment Tracking Pydantic Models
"""

from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from enum import Enum


class ShipmentStatus(str, Enum):
    ORDERED = "ordered"
    IN_TRANSIT = "in_transit"
    AT_PORT = "at_port"
    CUSTOMS_CLEARANCE = "customs_clearance"
    IN_DELIVERY = "in_delivery"
    DELIVERED = "delivered"
    DELAYED = "delayed"
    CANCELLED = "cancelled"


class PortName(str, Enum):
    CHENNAI = "chennai_port"
    ENNORE = "ennore_port"
    NONE = "none"  # For local suppliers


class ShipmentBase(BaseModel):
    """Inbound shipment tracking."""
    shipment_ref: str = Field(..., description="Unique shipment reference number")
    supplier_id: str
    purchase_order_id: Optional[str] = None
    material_id: str
    quantity: float
    port_of_entry: PortName = PortName.NONE
    vessel_name: Optional[str] = None
    container_id: Optional[str] = None
    origin: str = Field(..., description="Origin city/country")
    destination: str = Field(default="Chennai", description="Destination")
    estimated_departure: Optional[datetime] = None
    estimated_arrival: datetime
    actual_arrival: Optional[datetime] = None
    delay_hours: float = Field(default=0, description="Delay in hours (0 = on time)")
    delay_reason: Optional[str] = None
    current_location: Optional[str] = None
    notes: Optional[str] = None


class ShipmentCreate(ShipmentBase):
    pass


class Shipment(ShipmentBase):
    id: str
    status: ShipmentStatus = ShipmentStatus.ORDERED
    created_at: datetime
    updated_at: datetime


class PortStatus(BaseModel):
    """Real-time port congestion and delay data."""
    id: str
    port_name: PortName
    congestion_level: str = Field(..., description="low, moderate, high, severe")
    avg_delay_hours: float = 0
    vessels_waiting: int = 0
    weather_impact: Optional[str] = None
    last_checked: datetime
    notes: Optional[str] = None


class ShipmentMapItem(BaseModel):
    """Simplified shipment data for map visualization."""
    id: str
    shipment_ref: str
    supplier_name: str
    material_name: str
    status: ShipmentStatus
    origin: str
    destination: str
    estimated_arrival: datetime
    delay_hours: float
    current_location: Optional[str]
    port_of_entry: PortName
