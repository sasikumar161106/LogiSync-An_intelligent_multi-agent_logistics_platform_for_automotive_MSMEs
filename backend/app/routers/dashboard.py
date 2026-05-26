"""
Dashboard API Router
Aggregated KPIs and summary data for the main dashboard.
"""

from fastapi import APIRouter
from app.services.supabase_svc import SupabaseService
from app.services.external_apis import PortStatusAdapter

router = APIRouter()


@router.get("/summary")
async def get_dashboard_summary():
    """Get aggregated KPI data for the main dashboard."""
    svc = SupabaseService()
    return svc.get_dashboard_summary()


@router.get("/inventory-health")
async def get_inventory_health():
    """Get material-wise stock levels with shortage risk indicators."""
    svc = SupabaseService()
    inventory = svc.get_inventory_health()

    health_data = []
    for item in inventory:
        mat = item.get("materials", {})
        current = float(item.get("current_stock", 0))
        min_level = float(mat.get("min_stock_level", 0))
        unit_price = float(mat.get("unit_price", 0))

        # Calculate consumption rate
        avg_consumption = svc.get_avg_daily_consumption(item.get("material_id", ""))

        days_left = None
        if avg_consumption > 0:
            days_left = round(current / avg_consumption, 1)

        health_data.append({
            "material_id": item.get("material_id"),
            "material_name": mat.get("name", "Unknown"),
            "part_number": mat.get("part_number", "N/A"),
            "category": mat.get("category", "N/A"),
            "current_stock": current,
            "min_stock_level": min_level,
            "daily_consumption_rate": round(avg_consumption, 2),
            "days_until_stockout": days_left,
            "stock_status": item.get("stock_status", "unknown"),
            "stock_value_inr": round(current * unit_price, 2),
        })

    return health_data


@router.get("/shipment-map")
async def get_shipment_map():
    """Get active shipments data for map visualization."""
    svc = SupabaseService()
    shipments = svc.get_active_shipments()

    map_items = []
    for s in shipments:
        map_items.append({
            "id": s.get("id"),
            "shipment_ref": s.get("shipment_ref"),
            "supplier_name": s.get("suppliers", {}).get("name", "Unknown"),
            "material_name": s.get("materials", {}).get("name", "Unknown"),
            "status": s.get("status"),
            "origin": s.get("origin"),
            "destination": s.get("destination", "Chennai"),
            "estimated_arrival": s.get("estimated_arrival"),
            "delay_hours": float(s.get("delay_hours", 0)),
            "current_location": s.get("current_location"),
            "port_of_entry": s.get("port_of_entry"),
        })

    return map_items


@router.get("/port-status")
async def get_port_status():
    """Get real-time status of Chennai and Ennore ports."""
    svc = SupabaseService()
    return svc.get_port_status()


@router.get("/weather")
async def get_weather():
    """Get current Chennai weather and logistics risk assessment."""
    from app.services.external_apis import WeatherAdapter
    adapter = WeatherAdapter()
    return await adapter.get_chennai_weather()
