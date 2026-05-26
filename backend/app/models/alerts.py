"""
Alert & Decision Pydantic Models
Core of the human-in-the-loop workflow.
"""

from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from enum import Enum


class AlertSeverity(str, Enum):
    INFO = "info"
    WARNING = "warning"
    CRITICAL = "critical"
    URGENT = "urgent"


class AlertStatus(str, Enum):
    PENDING = "pending"
    APPROVED = "approved"
    REJECTED = "rejected"
    MODIFIED = "modified"
    EXPIRED = "expired"
    AUTO_RESOLVED = "auto_resolved"


class AlertType(str, Enum):
    SHORTAGE_PREDICTED = "shortage_predicted"
    SHIPMENT_DELAYED = "shipment_delayed"
    PORT_CONGESTION = "port_congestion"
    WEATHER_RISK = "weather_risk"
    PRODUCTION_IMPACT = "production_impact"
    SUPPLIER_ISSUE = "supplier_issue"
    REORDER_SUGGESTED = "reorder_suggested"
    SCHEDULE_CHANGE = "schedule_change"


class AlertBase(BaseModel):
    """AI-generated actionable alert."""
    alert_type: AlertType
    severity: AlertSeverity
    title: str = Field(..., description="Short, actionable title")
    description: str = Field(..., description="Detailed explanation from the AI agent")
    recommended_action: str = Field(
        ...,
        description="The AI's recommended resolution (e.g., 'Order 500 units from Supplier B')"
    )
    estimated_cost_inr: Optional[float] = Field(
        None, description="Estimated cost of the recommended action in INR"
    )
    estimated_savings_inr: Optional[float] = Field(
        None, description="Estimated savings vs. doing nothing"
    )
    affected_materials: list[str] = Field(default_factory=list)
    affected_shipments: list[str] = Field(default_factory=list)
    deadline: Optional[datetime] = Field(
        None, description="Decision deadline — after which the alert expires"
    )
    agent_run_id: Optional[str] = Field(None, description="ID of the agent run that created this")
    metadata: dict = Field(default_factory=dict, description="Additional context from agents")


class AlertCreate(AlertBase):
    pass


class Alert(AlertBase):
    id: str
    status: AlertStatus = AlertStatus.PENDING
    created_at: datetime
    updated_at: datetime
    resolved_at: Optional[datetime] = None
    resolved_by: Optional[str] = None


class AlertAction(BaseModel):
    """Manager's response to an alert."""
    action: AlertStatus = Field(..., description="approve, reject, or modified")
    modified_action: Optional[str] = Field(
        None, description="If modified, the manager's revised plan"
    )
    reason: Optional[str] = Field(None, description="Reason for rejection or modification")


class AlertSummary(BaseModel):
    """Dashboard summary of alerts."""
    total_pending: int = 0
    total_critical: int = 0
    total_resolved_today: int = 0
    estimated_savings_today_inr: float = 0
    recent_alerts: list[Alert] = []
