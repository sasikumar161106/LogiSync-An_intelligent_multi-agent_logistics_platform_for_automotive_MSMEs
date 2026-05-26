"""
Inventory API Router
CRUD operations for materials and inventory management.
"""

from fastapi import APIRouter, HTTPException
from typing import Optional
from app.services.supabase_svc import SupabaseService
from app.models.inventory import MaterialCreate, InventoryCreate

router = APIRouter()


# ── MATERIALS ──────────────────────────────────────────

@router.get("/materials")
async def list_materials(active_only: bool = True):
    """List all materials in the catalog."""
    svc = SupabaseService()
    return svc.get_materials(active_only=active_only)


@router.get("/materials/{material_id}")
async def get_material(material_id: str):
    """Get a specific material by ID."""
    svc = SupabaseService()
    material = svc.get_material(material_id)
    if not material:
        raise HTTPException(status_code=404, detail="Material not found")
    return material


@router.post("/materials")
async def create_material(material: MaterialCreate):
    """Add a new material to the catalog."""
    svc = SupabaseService()
    return svc.create_material(material.model_dump())


@router.put("/materials/{material_id}")
async def update_material(material_id: str, material: MaterialCreate):
    """Update an existing material."""
    svc = SupabaseService()
    return svc.update_material(material_id, material.model_dump())


# ── STOCK LEVELS ───────────────────────────────────────

@router.get("/stock")
async def list_stock(warehouse: str = "main"):
    """List current stock levels for all materials in a warehouse."""
    svc = SupabaseService()
    return svc.get_inventory(warehouse=warehouse)


@router.get("/stock/{material_id}")
async def get_stock(material_id: str, warehouse: str = "main"):
    """Get stock level for a specific material."""
    svc = SupabaseService()
    item = svc.get_inventory_item(material_id, warehouse)
    if not item:
        raise HTTPException(status_code=404, detail="Inventory record not found")
    return item


@router.put("/stock/{inventory_id}")
async def update_stock(inventory_id: str, data: InventoryCreate):
    """Update stock level for a material."""
    svc = SupabaseService()
    return svc.update_inventory(inventory_id, data.model_dump())


# ── CONSUMPTION ────────────────────────────────────────

@router.get("/consumption/{material_id}")
async def get_consumption(material_id: str, days: int = 30):
    """Get consumption history for a material."""
    svc = SupabaseService()
    logs = svc.get_consumption_logs(material_id, days)
    avg_rate = svc.get_avg_daily_consumption(material_id, days)

    return {
        "material_id": material_id,
        "period_days": days,
        "total_consumed": sum(float(l["quantity_consumed"]) for l in logs),
        "avg_daily_rate": round(avg_rate, 2),
        "data_points": len(logs),
        "logs": logs,
    }


@router.post("/consumption")
async def log_consumption(data: dict):
    """Log a new consumption entry."""
    svc = SupabaseService()
    return svc.log_consumption(data)
