"""
Inventory Tools for CrewAI Agents
Gives agents the ability to query inventory data from Supabase.
"""

from crewai.tools import tool
from app.services.supabase_svc import SupabaseService


@tool("Get All Inventory Levels")
def get_inventory_levels() -> str:
    """
    Retrieves current inventory levels for all materials in the main warehouse.
    Returns material name, part number, current stock, min stock level, and stock status.
    """
    svc = SupabaseService()
    inventory = svc.get_inventory_health()

    if not inventory:
        return "No inventory data found. The warehouse may be empty or not configured."

    lines = ["=== CURRENT INVENTORY LEVELS ===\n"]
    for item in inventory:
        mat = item.get("materials", {})
        lines.append(
            f"• {mat.get('name', 'Unknown')} ({mat.get('part_number', 'N/A')})\n"
            f"  Category: {mat.get('category', 'N/A')}\n"
            f"  Current Stock: {item.get('current_stock', 0)} | "
            f"Min Level: {mat.get('min_stock_level', 0)}\n"
            f"  Status: {item.get('stock_status', 'unknown').upper()}\n"
            f"  Days Until Stockout: {item.get('days_until_stockout', 'N/A')}\n"
        )

    return "\n".join(lines)


@tool("Get Material Consumption Rate")
def get_consumption_rate(material_id: str) -> str:
    """
    Calculates the average daily consumption rate for a specific material
    over the last 30 days. Provide the material UUID.
    """
    svc = SupabaseService()
    avg = svc.get_avg_daily_consumption(material_id, days=30)
    logs = svc.get_consumption_logs(material_id, days=30)
    material = svc.get_material(material_id)

    name = material.get("name", "Unknown") if material else "Unknown"

    return (
        f"=== CONSUMPTION ANALYSIS: {name} ===\n"
        f"Average Daily Consumption: {avg:.2f} units/day\n"
        f"Data Points (last 30 days): {len(logs)} entries\n"
        f"Total Consumed (30 days): {sum(float(l['quantity_consumed']) for l in logs):.2f} units"
    )


@tool("Get Critical Stock Items")
def get_critical_stock_items() -> str:
    """
    Returns all materials that are in 'critical' or 'out_of_stock' status.
    These are the items that need immediate attention.
    """
    svc = SupabaseService()
    inventory = svc.get_inventory_health()

    critical = [
        i for i in inventory
        if i.get("stock_status") in ("critical", "out_of_stock", "low")
    ]

    if not critical:
        return "✅ All inventory levels are healthy. No critical items found."

    lines = ["🚨 === CRITICAL & LOW STOCK ITEMS ===\n"]
    for item in critical:
        mat = item.get("materials", {})
        lines.append(
            f"⚠️ {mat.get('name', 'Unknown')} ({mat.get('part_number', 'N/A')})\n"
            f"   Status: {item.get('stock_status', 'unknown').upper()}\n"
            f"   Current Stock: {item.get('current_stock', 0)}\n"
            f"   Min Required: {mat.get('min_stock_level', 0)}\n"
            f"   Days Until Stockout: {item.get('days_until_stockout', 'N/A')}\n"
            f"   Unit Price: ₹{mat.get('unit_price', 0)}\n"
        )

    return "\n".join(lines)


@tool("Check Incoming Shipments for Material")
def check_incoming_shipments(material_id: str) -> str:
    """
    Checks if there are any active (non-delivered) shipments for a specific material.
    Helps determine if a shortage will self-resolve with incoming stock.
    """
    svc = SupabaseService()
    all_shipments = svc.get_active_shipments()

    material_shipments = [
        s for s in all_shipments if s.get("material_id") == material_id
    ]

    if not material_shipments:
        return f"No incoming shipments found for material {material_id}."

    lines = [f"=== INCOMING SHIPMENTS FOR MATERIAL ===\n"]
    for s in material_shipments:
        lines.append(
            f"• Shipment {s.get('shipment_ref', 'N/A')}\n"
            f"  Supplier: {s.get('suppliers', {}).get('name', 'Unknown')}\n"
            f"  Quantity: {s.get('quantity', 0)}\n"
            f"  Status: {s.get('status', 'unknown')}\n"
            f"  ETA: {s.get('estimated_arrival', 'N/A')}\n"
            f"  Delay: {s.get('delay_hours', 0)} hours\n"
            f"  Port: {s.get('port_of_entry', 'N/A')}\n"
        )

    return "\n".join(lines)
