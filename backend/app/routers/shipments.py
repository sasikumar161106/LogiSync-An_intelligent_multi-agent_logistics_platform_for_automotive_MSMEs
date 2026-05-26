"""
Shipments API Router
Tracking and management of inbound shipments.
"""

from fastapi import APIRouter, HTTPException
from typing import Optional
from app.services.supabase_svc import SupabaseService
from app.models.shipments import ShipmentCreate

router = APIRouter()


@router.get("/")
async def list_shipments(status: Optional[str] = None):
    """List all shipments, optionally filtered by status."""
    svc = SupabaseService()
    return svc.get_shipments(status=status)


@router.get("/active")
async def list_active_shipments():
    """List all active (non-delivered, non-cancelled) shipments."""
    svc = SupabaseService()
    return svc.get_active_shipments()


@router.get("/delayed")
async def list_delayed_shipments():
    """List all currently delayed shipments."""
    svc = SupabaseService()
    return svc.get_delayed_shipments()


@router.get("/{shipment_id}")
async def get_shipment(shipment_id: str):
    """Get a specific shipment by ID."""
    svc = SupabaseService()
    shipment = svc.get_shipment(shipment_id)
    if not shipment:
        raise HTTPException(status_code=404, detail="Shipment not found")
    return shipment


@router.post("/")
async def create_shipment(shipment: ShipmentCreate):
    """Create a new shipment tracking record."""
    svc = SupabaseService()
    return svc.create_shipment(shipment.model_dump())


@router.put("/{shipment_id}")
async def update_shipment(shipment_id: str, data: dict):
    """Update shipment status or details."""
    svc = SupabaseService()
    return svc.update_shipment(shipment_id, data)
