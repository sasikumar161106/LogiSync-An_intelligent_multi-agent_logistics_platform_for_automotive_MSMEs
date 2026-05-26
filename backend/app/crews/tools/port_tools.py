"""
Port Status Tools for CrewAI Agents
Gives agents the ability to check port conditions.
"""

from crewai.tools import tool
from app.services.external_apis import PortStatusAdapter
from app.services.supabase_svc import SupabaseService


@tool("Check Port Status")
def check_port_status(port_name: str) -> str:
    """
    Checks the current operational status of a port.
    Valid port names: 'chennai_port' or 'ennore_port'.
    Returns congestion level, average delays, vessels waiting, and weather impact.
    """
    adapter = PortStatusAdapter()
    status = adapter.get_port_status(port_name)

    # Also update the database with latest status
    try:
        svc = SupabaseService()
        svc.update_port_status(port_name, status)
    except Exception:
        pass  # Don't fail the tool if DB update fails

    port_display = "Chennai Port" if port_name == "chennai_port" else "Ennore (Kamarajar) Port"

    return (
        f"=== {port_display} STATUS ===\n"
        f"Congestion Level: {status['congestion_level'].upper()}\n"
        f"Average Delay: {status['avg_delay_hours']} hours\n"
        f"Vessels Waiting: {status['vessels_waiting']}\n"
        f"Weather Impact: {status.get('weather_impact', 'None')}\n"
        f"Last Checked: {status['last_checked']}\n"
    )


@tool("Get All Delayed Shipments")
def get_delayed_shipments() -> str:
    """
    Retrieves all currently delayed shipments across both ports.
    Shows shipment details, supplier info, delay duration, and reason.
    """
    svc = SupabaseService()
    delayed = svc.get_delayed_shipments()

    if not delayed:
        return "✅ No delayed shipments found. All shipments are on schedule."

    lines = [f"🚨 === {len(delayed)} DELAYED SHIPMENTS ===\n"]
    for s in delayed:
        lines.append(
            f"• {s.get('shipment_ref', 'N/A')}\n"
            f"  Supplier: {s.get('suppliers', {}).get('name', 'Unknown')}\n"
            f"  Material: {s.get('materials', {}).get('name', 'Unknown')} "
            f"({s.get('materials', {}).get('part_number', 'N/A')})\n"
            f"  Quantity: {s.get('quantity', 0)}\n"
            f"  Status: {s.get('status', 'unknown')}\n"
            f"  Port: {s.get('port_of_entry', 'N/A')}\n"
            f"  Original ETA: {s.get('estimated_arrival', 'N/A')}\n"
            f"  Delay: {s.get('delay_hours', 0)} hours\n"
            f"  Reason: {s.get('delay_reason', 'Not specified')}\n"
        )

    return "\n".join(lines)


@tool("Get Both Ports Summary")
def get_both_ports_summary() -> str:
    """
    Gets a quick summary of both Chennai Port and Ennore Port status
    in a single call. Useful for the initial monitoring scan.
    """
    adapter = PortStatusAdapter()

    chennai = adapter.get_port_status("chennai_port")
    ennore = adapter.get_port_status("ennore_port")

    return (
        "=== PORT STATUS SUMMARY ===\n\n"
        f"CHENNAI PORT:\n"
        f"  Congestion: {chennai['congestion_level'].upper()}\n"
        f"  Avg Delay: {chennai['avg_delay_hours']}h\n"
        f"  Vessels Waiting: {chennai['vessels_waiting']}\n"
        f"  Weather: {chennai.get('weather_impact', 'Clear')}\n\n"
        f"ENNORE (KAMARAJAR) PORT:\n"
        f"  Congestion: {ennore['congestion_level'].upper()}\n"
        f"  Avg Delay: {ennore['avg_delay_hours']}h\n"
        f"  Vessels Waiting: {ennore['vessels_waiting']}\n"
        f"  Weather: {ennore.get('weather_impact', 'Clear')}\n"
    )
