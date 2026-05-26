"""
Production Schedule Pydantic Models
"""

from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime, date
from enum import Enum


class ScheduleStatus(str, Enum):
    PLANNED = "planned"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    DELAYED = "delayed"
    ON_HOLD = "on_hold"
    CANCELLED = "cancelled"


class ProductionScheduleBase(BaseModel):
    """Daily/weekly production plan."""
    schedule_ref: str = Field(..., description="Schedule reference ID")
    product_name: str = Field(..., description="End product being manufactured")
    planned_date: date
    planned_quantity: int
    priority: int = Field(default=3, ge=1, le=5, description="1=highest, 5=lowest")
    material_requirements: list[dict] = Field(
        default_factory=list,
        description="List of {material_id, quantity_needed}"
    )
    notes: Optional[str] = None


class ProductionScheduleCreate(ProductionScheduleBase):
    pass


class ProductionSchedule(ProductionScheduleBase):
    id: str
    status: ScheduleStatus = ScheduleStatus.PLANNED
    actual_quantity: int = 0
    completion_percentage: float = 0.0
    created_at: datetime
    updated_at: datetime


class PurchaseOrderBase(BaseModel):
    """Purchase order (manual or AI-drafted)."""
    po_number: str = Field(..., description="Purchase order number")
    supplier_id: str
    material_id: str
    quantity: float
    unit_price_inr: float
    total_amount_inr: float
    expected_delivery: date
    is_ai_generated: bool = Field(default=False, description="Whether this PO was drafted by AI")
    alert_id: Optional[str] = Field(None, description="Linked alert if AI-generated")
    notes: Optional[str] = None


class PurchaseOrderCreate(PurchaseOrderBase):
    pass


class PurchaseOrder(PurchaseOrderBase):
    id: str
    status: str = "draft"  # draft, submitted, confirmed, received, cancelled
    created_at: datetime
    updated_at: datetime


class AgentRun(BaseModel):
    """Audit log of a CrewAI execution."""
    id: str
    trigger: str = Field(..., description="scheduled, manual, or event")
    status: str = Field(default="running", description="running, completed, failed")
    started_at: datetime
    completed_at: Optional[datetime] = None
    duration_seconds: Optional[float] = None
    agents_involved: list[str] = Field(default_factory=list)
    tasks_completed: int = 0
    alerts_generated: int = 0
    summary: Optional[str] = None
    error_message: Optional[str] = None


class DashboardSummary(BaseModel):
    """Aggregated KPIs for the main dashboard."""
    total_inventory_value_inr: float = 0
    materials_at_risk: int = 0
    active_shipments: int = 0
    delayed_shipments: int = 0
    pending_alerts: int = 0
    critical_alerts: int = 0
    production_efficiency_pct: float = 0.0
    total_suppliers: int = 0
    ai_savings_this_month_inr: float = 0
    last_agent_run: Optional[datetime] = None
