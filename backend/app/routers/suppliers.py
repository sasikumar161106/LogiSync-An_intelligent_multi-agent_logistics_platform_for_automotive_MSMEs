"""
Suppliers API Router
CRUD operations for supplier management.
"""

from fastapi import APIRouter, HTTPException
from app.services.supabase_svc import SupabaseService
from app.models.suppliers import SupplierCreate

router = APIRouter()


@router.get("/")
async def list_suppliers(active_only: bool = True):
    """List all suppliers."""
    svc = SupabaseService()
    return svc.get_suppliers(active_only=active_only)


@router.get("/{supplier_id}")
async def get_supplier(supplier_id: str):
    """Get a specific supplier by ID."""
    svc = SupabaseService()
    supplier = svc.get_supplier(supplier_id)
    if not supplier:
        raise HTTPException(status_code=404, detail="Supplier not found")
    return supplier


@router.post("/")
async def create_supplier(supplier: SupplierCreate):
    """Add a new supplier."""
    svc = SupabaseService()
    return svc.create_supplier(supplier.model_dump())


@router.put("/{supplier_id}")
async def update_supplier(supplier_id: str, supplier: SupplierCreate):
    """Update an existing supplier."""
    svc = SupabaseService()
    return svc.update_supplier(supplier_id, supplier.model_dump())
