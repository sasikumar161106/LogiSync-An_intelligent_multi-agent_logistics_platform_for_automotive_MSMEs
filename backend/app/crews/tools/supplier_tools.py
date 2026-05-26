"""
Supplier Tools for CrewAI Agents
Helps agents find and compare backup suppliers.
"""

from crewai.tools import tool
from app.services.supabase_svc import SupabaseService


@tool("Search Suppliers by Material Category")
def search_suppliers_by_category(category: str) -> str:
    """
    Searches for active suppliers that provide materials in a given category.
    Categories: raw_material, component, consumable, packaging.
    Returns supplier details sorted by reliability score.
    """
    svc = SupabaseService()
    all_suppliers = svc.get_suppliers(active_only=True)

    # Filter suppliers whose materials_supplied includes the category
    matching = [
        s for s in all_suppliers
        if category.lower() in [c.lower() for c in s.get("materials_supplied", [])]
    ]

    if not matching:
        # Fallback: return all suppliers if no category match
        matching = all_suppliers

    # Sort by reliability score descending
    matching.sort(key=lambda s: float(s.get("reliability_score", 0)), reverse=True)

    lines = [f"=== SUPPLIERS FOR '{category.upper()}' ===\n"]
    for s in matching:
        lines.append(
            f"• {s.get('name', 'Unknown')} ({s.get('supplier_type', 'N/A')})\n"
            f"  Location: {s.get('location', 'N/A')}\n"
            f"  Lead Time: {s.get('lead_time_days', 'N/A')} days\n"
            f"  Reliability: {float(s.get('reliability_score', 0)) * 100:.0f}%\n"
            f"  On-Time Rate: {float(s.get('on_time_delivery_rate', 0)):.0f}%\n"
            f"  Port: {s.get('port_of_entry', 'Local delivery')}\n"
            f"  Payment: {s.get('payment_terms', 'N/A')}\n"
            f"  Contact: {s.get('contact_person', 'N/A')} | {s.get('phone', 'N/A')}\n"
            f"  ID: {s.get('id', 'N/A')}\n"
        )

    return "\n".join(lines)


@tool("Compare Two Suppliers")
def compare_suppliers(supplier_id_1: str, supplier_id_2: str) -> str:
    """
    Compares two suppliers side-by-side on key metrics:
    lead time, reliability, cost effectiveness, and delivery history.
    Provide two supplier UUIDs.
    """
    svc = SupabaseService()
    s1 = svc.get_supplier(supplier_id_1)
    s2 = svc.get_supplier(supplier_id_2)

    if not s1 or not s2:
        return "Error: One or both supplier IDs not found."

    def score(s):
        reliability = float(s.get("reliability_score", 0))
        speed = max(0, 1 - (int(s.get("lead_time_days", 30)) / 30))
        return round((reliability * 0.6 + speed * 0.4) * 100, 1)

    return (
        f"=== SUPPLIER COMPARISON ===\n\n"
        f"{'Metric':<25} {'Supplier A':<25} {'Supplier B':<25}\n"
        f"{'-'*75}\n"
        f"{'Name':<25} {s1.get('name', ''):<25} {s2.get('name', ''):<25}\n"
        f"{'Type':<25} {s1.get('supplier_type', ''):<25} {s2.get('supplier_type', ''):<25}\n"
        f"{'Location':<25} {s1.get('location', ''):<25} {s2.get('location', ''):<25}\n"
        f"{'Lead Time':<25} {s1.get('lead_time_days', 'N/A')} days{'':<18} "
        f"{s2.get('lead_time_days', 'N/A')} days\n"
        f"{'Reliability':<25} {float(s1.get('reliability_score', 0))*100:.0f}%{'':<22} "
        f"{float(s2.get('reliability_score', 0))*100:.0f}%\n"
        f"{'On-Time Rate':<25} {float(s1.get('on_time_delivery_rate', 0)):.0f}%{'':<22} "
        f"{float(s2.get('on_time_delivery_rate', 0)):.0f}%\n"
        f"{'Total Orders':<25} {s1.get('total_orders', 0):<25} {s2.get('total_orders', 0):<25}\n"
        f"{'Port':<25} {s1.get('port_of_entry', 'Local'):<25} {s2.get('port_of_entry', 'Local'):<25}\n"
        f"{'Payment':<25} {s1.get('payment_terms', 'N/A'):<25} {s2.get('payment_terms', 'N/A'):<25}\n"
        f"\n{'Overall Score':<25} {score(s1)}/100{'':<20} {score(s2)}/100\n"
        f"\n✅ RECOMMENDATION: {'Supplier A (' + s1.get('name', '') + ')' if score(s1) >= score(s2) else 'Supplier B (' + s2.get('name', '') + ')'}\n"
    )


@tool("Get All Suppliers")
def get_all_suppliers() -> str:
    """
    Retrieves a complete list of all active suppliers with their details.
    Useful for getting an overview of the supplier network.
    """
    svc = SupabaseService()
    suppliers = svc.get_suppliers(active_only=True)

    if not suppliers:
        return "No active suppliers found in the database."

    lines = [f"=== ALL ACTIVE SUPPLIERS ({len(suppliers)}) ===\n"]
    for s in suppliers:
        lines.append(
            f"• {s.get('name', 'Unknown')} [{s.get('supplier_type', 'N/A')}]\n"
            f"  Location: {s.get('location', 'N/A')} | Lead: {s.get('lead_time_days', 'N/A')}d | "
            f"Reliability: {float(s.get('reliability_score', 0))*100:.0f}%\n"
            f"  Supplies: {', '.join(s.get('materials_supplied', []))}\n"
            f"  ID: {s.get('id', 'N/A')}\n"
        )

    return "\n".join(lines)
