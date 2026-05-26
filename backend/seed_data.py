"""
LogiSync Seed Data
Populates the Supabase database with realistic demo data for an automotive MSME.
Run: python seed_data.py
"""

import os
import sys
from datetime import datetime, timedelta, date
from dotenv import load_dotenv
from supabase import create_client

load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_SERVICE_KEY", os.getenv("SUPABASE_KEY"))

if not SUPABASE_URL or not SUPABASE_KEY:
    print("❌ Set SUPABASE_URL and SUPABASE_KEY in .env")
    sys.exit(1)

client = create_client(SUPABASE_URL, SUPABASE_KEY)

# ============================================================
# SUPPLIERS
# ============================================================
SUPPLIERS = [
    {
        "name": "Tata Steel India",
        "supplier_type": "domestic",
        "location": "Jamshedpur, Jharkhand",
        "contact_person": "Rajesh Menon",
        "phone": "+91 98765 43210",
        "email": "rajesh.menon@tatasteel.com",
        "lead_time_days": 12,
        "reliability_score": 0.92,
        "port_of_entry": "chennai_port",
        "materials_supplied": ["raw_material", "component"],
        "payment_terms": "Net 30",
        "total_orders": 145,
        "on_time_delivery_rate": 91.0,
    },
    {
        "name": "Nippon Steel Japan",
        "supplier_type": "international",
        "location": "Tokyo, Japan",
        "contact_person": "Takeshi Yamamoto",
        "phone": "+81 3 6867 4111",
        "email": "t.yamamoto@nippon.co.jp",
        "lead_time_days": 25,
        "reliability_score": 0.95,
        "port_of_entry": "ennore_port",
        "materials_supplied": ["raw_material"],
        "payment_terms": "LC 60 days",
        "total_orders": 38,
        "on_time_delivery_rate": 94.0,
    },
    {
        "name": "Chennai Auto Parts",
        "supplier_type": "local",
        "location": "Ambattur, Chennai",
        "contact_person": "Suresh Kumar",
        "phone": "+91 94433 21098",
        "email": "suresh@chennaiap.in",
        "lead_time_days": 2,
        "reliability_score": 0.78,
        "materials_supplied": ["component", "consumable"],
        "payment_terms": "Net 15",
        "total_orders": 312,
        "on_time_delivery_rate": 76.0,
    },
    {
        "name": "Sundaram Fasteners",
        "supplier_type": "local",
        "location": "Padi, Chennai",
        "contact_person": "Lakshmi Narayanan",
        "phone": "+91 98411 55678",
        "email": "lakshmi@sundaram.co.in",
        "lead_time_days": 3,
        "reliability_score": 0.88,
        "materials_supplied": ["component"],
        "payment_terms": "Net 15",
        "total_orders": 198,
        "on_time_delivery_rate": 87.0,
    },
    {
        "name": "Bosch Rexroth Germany",
        "supplier_type": "international",
        "location": "Stuttgart, Germany",
        "contact_person": "Hans Mueller",
        "phone": "+49 711 811 0",
        "email": "h.mueller@boschrexroth.de",
        "lead_time_days": 30,
        "reliability_score": 0.97,
        "port_of_entry": "chennai_port",
        "materials_supplied": ["component"],
        "payment_terms": "LC 90 days",
        "total_orders": 22,
        "on_time_delivery_rate": 96.0,
    },
]

# ============================================================
# MATERIALS (Automotive parts)
# ============================================================
MATERIALS = [
    {"part_number": "BRK-PAD-001", "name": "Brake Pad Set (Front)", "category": "component", "unit": "set", "min_stock_level": 200, "reorder_quantity": 500, "unit_price": 850},
    {"part_number": "BRK-PAD-002", "name": "Brake Pad Set (Rear)", "category": "component", "unit": "set", "min_stock_level": 150, "reorder_quantity": 400, "unit_price": 720},
    {"part_number": "BRG-6205", "name": "Ball Bearing 6205-2RS", "category": "component", "unit": "pcs", "min_stock_level": 500, "reorder_quantity": 1000, "unit_price": 185},
    {"part_number": "BRG-6308", "name": "Ball Bearing 6308-ZZ", "category": "component", "unit": "pcs", "min_stock_level": 300, "reorder_quantity": 600, "unit_price": 340},
    {"part_number": "GSK-CYL-001", "name": "Cylinder Head Gasket", "category": "component", "unit": "pcs", "min_stock_level": 100, "reorder_quantity": 250, "unit_price": 1250},
    {"part_number": "GSK-OIL-001", "name": "Oil Pan Gasket", "category": "component", "unit": "pcs", "min_stock_level": 100, "reorder_quantity": 250, "unit_price": 380},
    {"part_number": "STL-MS-3MM", "name": "Mild Steel Sheet 3mm", "category": "raw_material", "unit": "kg", "min_stock_level": 2000, "reorder_quantity": 5000, "unit_price": 72},
    {"part_number": "STL-SS-304", "name": "SS 304 Round Bar", "category": "raw_material", "unit": "kg", "min_stock_level": 500, "reorder_quantity": 1500, "unit_price": 245},
    {"part_number": "RBR-SEAL-01", "name": "Rubber Oil Seal (40mm)", "category": "component", "unit": "pcs", "min_stock_level": 400, "reorder_quantity": 800, "unit_price": 65},
    {"part_number": "RBR-SEAL-02", "name": "Rubber Oil Seal (55mm)", "category": "component", "unit": "pcs", "min_stock_level": 300, "reorder_quantity": 600, "unit_price": 85},
    {"part_number": "FLT-OIL-001", "name": "Engine Oil Filter", "category": "consumable", "unit": "pcs", "min_stock_level": 200, "reorder_quantity": 500, "unit_price": 145},
    {"part_number": "FLT-AIR-001", "name": "Air Filter Element", "category": "consumable", "unit": "pcs", "min_stock_level": 150, "reorder_quantity": 400, "unit_price": 210},
    {"part_number": "SPK-PLG-001", "name": "Spark Plug (Iridium)", "category": "component", "unit": "pcs", "min_stock_level": 300, "reorder_quantity": 600, "unit_price": 420},
    {"part_number": "CLT-PLT-001", "name": "Clutch Plate Assembly", "category": "component", "unit": "set", "min_stock_level": 50, "reorder_quantity": 100, "unit_price": 3200},
    {"part_number": "SHK-ABS-001", "name": "Shock Absorber (Front)", "category": "component", "unit": "pcs", "min_stock_level": 80, "reorder_quantity": 150, "unit_price": 1850},
    {"part_number": "SHK-ABS-002", "name": "Shock Absorber (Rear)", "category": "component", "unit": "pcs", "min_stock_level": 80, "reorder_quantity": 150, "unit_price": 1650},
    {"part_number": "WHL-NUT-M12", "name": "Wheel Nut M12 (Chrome)", "category": "component", "unit": "pcs", "min_stock_level": 1000, "reorder_quantity": 2000, "unit_price": 28},
    {"part_number": "LUB-ENG-5W30", "name": "Engine Oil 5W-30 (Litre)", "category": "consumable", "unit": "litre", "min_stock_level": 500, "reorder_quantity": 1000, "unit_price": 480},
    {"part_number": "PKG-BOX-L", "name": "Packaging Box (Large)", "category": "packaging", "unit": "pcs", "min_stock_level": 200, "reorder_quantity": 500, "unit_price": 45},
    {"part_number": "PKG-BOX-M", "name": "Packaging Box (Medium)", "category": "packaging", "unit": "pcs", "min_stock_level": 300, "reorder_quantity": 700, "unit_price": 28},
]

# ============================================================
# PRODUCTION SCHEDULES
# ============================================================
SCHEDULES = [
    {"schedule_ref": "PS-2026-W22-001", "product_name": "Brake Assembly Kit (Sedan)", "planned_date": date.today().isoformat(), "planned_quantity": 200, "priority": 1, "status": "in_progress", "actual_quantity": 85, "completion_percentage": 42.5,
     "material_requirements": [{"part_number": "BRK-PAD-001", "qty": 200}, {"part_number": "BRG-6205", "qty": 400}]},
    {"schedule_ref": "PS-2026-W22-002", "product_name": "Engine Gasket Set", "planned_date": (date.today() + timedelta(days=1)).isoformat(), "planned_quantity": 150, "priority": 2, "status": "planned",
     "material_requirements": [{"part_number": "GSK-CYL-001", "qty": 150}, {"part_number": "GSK-OIL-001", "qty": 150}, {"part_number": "RBR-SEAL-01", "qty": 300}]},
    {"schedule_ref": "PS-2026-W22-003", "product_name": "Clutch Kit Assembly", "planned_date": (date.today() + timedelta(days=2)).isoformat(), "planned_quantity": 80, "priority": 2, "status": "planned",
     "material_requirements": [{"part_number": "CLT-PLT-001", "qty": 80}, {"part_number": "BRG-6308", "qty": 160}]},
    {"schedule_ref": "PS-2026-W22-004", "product_name": "Suspension Service Kit", "planned_date": (date.today() + timedelta(days=3)).isoformat(), "planned_quantity": 100, "priority": 3, "status": "planned",
     "material_requirements": [{"part_number": "SHK-ABS-001", "qty": 100}, {"part_number": "SHK-ABS-002", "qty": 100}]},
]


def seed():
    print("🌱 Seeding LogiSync database...")

    # 1. Suppliers
    print("  📦 Creating suppliers...")
    supplier_ids = {}
    for s in SUPPLIERS:
        result = client.table("suppliers").upsert(s, on_conflict="name").execute()
        if result.data:
            supplier_ids[s["name"]] = result.data[0]["id"]
            print(f"    ✅ {s['name']}")

    # 2. Materials
    print("  🔩 Creating materials...")
    material_ids = {}
    for m in MATERIALS:
        result = client.table("materials").upsert(m, on_conflict="part_number").execute()
        if result.data:
            material_ids[m["part_number"]] = result.data[0]["id"]
            print(f"    ✅ {m['part_number']} — {m['name']}")

    # 3. Inventory (varying health levels)
    print("  📊 Setting inventory levels...")
    import random
    inventory_configs = [
        # (part_number, stock_multiplier, status)
        ("BRK-PAD-001", 0.3, "critical"),     # Critically low!
        ("BRK-PAD-002", 1.5, "healthy"),
        ("BRG-6205", 0.5, "low"),             # Low
        ("BRG-6308", 2.0, "healthy"),
        ("GSK-CYL-001", 0.15, "critical"),    # Almost out!
        ("GSK-OIL-001", 1.2, "healthy"),
        ("STL-MS-3MM", 0.8, "low"),
        ("STL-SS-304", 1.5, "healthy"),
        ("RBR-SEAL-01", 1.8, "healthy"),
        ("RBR-SEAL-02", 0.0, "out_of_stock"), # Completely out!
        ("FLT-OIL-001", 1.0, "healthy"),
        ("FLT-AIR-001", 0.6, "low"),
        ("SPK-PLG-001", 1.3, "healthy"),
        ("CLT-PLT-001", 0.4, "low"),
        ("SHK-ABS-001", 1.1, "healthy"),
        ("SHK-ABS-002", 0.2, "critical"),     # Critical!
        ("WHL-NUT-M12", 2.5, "healthy"),
        ("LUB-ENG-5W30", 0.7, "low"),
        ("PKG-BOX-L", 1.5, "healthy"),
        ("PKG-BOX-M", 1.8, "healthy"),
    ]

    for pn, multiplier, status in inventory_configs:
        mat = next((m for m in MATERIALS if m["part_number"] == pn), None)
        if mat and pn in material_ids:
            stock = round(mat["min_stock_level"] * multiplier, 0)
            reserved = round(stock * random.uniform(0.05, 0.2), 0) if stock > 0 else 0

            # Calculate days until stockout (simulated consumption)
            daily_rate = random.uniform(5, 50)
            days_left = round(stock / daily_rate, 1) if daily_rate > 0 and stock > 0 else 0

            client.table("inventory").upsert({
                "material_id": material_ids[pn],
                "warehouse": "main",
                "current_stock": stock,
                "reserved_stock": reserved,
                "stock_status": status,
                "days_until_stockout": days_left if stock > 0 else 0,
            }, on_conflict="material_id,warehouse").execute()
            print(f"    {'🔴' if status in ('critical','out_of_stock') else '🟡' if status == 'low' else '🟢'} {pn}: {stock} units ({status})")

    # 4. Shipments
    print("  🚢 Creating shipments...")
    shipments = [
        {
            "shipment_ref": "SHP-2026-0451",
            "supplier_id": supplier_ids.get("Nippon Steel Japan", ""),
            "material_id": material_ids.get("STL-MS-3MM", ""),
            "quantity": 5000,
            "status": "delayed",
            "port_of_entry": "ennore_port",
            "vessel_name": "MV Sakura Maru",
            "container_id": "TCLU7891234",
            "origin": "Tokyo, Japan",
            "destination": "Chennai",
            "estimated_departure": (datetime.utcnow() - timedelta(days=18)).isoformat(),
            "estimated_arrival": (datetime.utcnow() - timedelta(days=1)).isoformat(),
            "delay_hours": 48,
            "delay_reason": "Port congestion at Ennore — vessel waiting at outer anchorage",
            "current_location": "Ennore Port Anchorage",
        },
        {
            "shipment_ref": "SHP-2026-0452",
            "supplier_id": supplier_ids.get("Bosch Rexroth Germany", ""),
            "material_id": material_ids.get("BRG-6205", ""),
            "quantity": 1000,
            "status": "in_transit",
            "port_of_entry": "chennai_port",
            "vessel_name": "MSC Lorena",
            "container_id": "MSCU5567890",
            "origin": "Stuttgart, Germany",
            "destination": "Chennai",
            "estimated_departure": (datetime.utcnow() - timedelta(days=20)).isoformat(),
            "estimated_arrival": (datetime.utcnow() + timedelta(days=5)).isoformat(),
            "delay_hours": 0,
            "current_location": "Arabian Sea — 800km from Chennai",
        },
        {
            "shipment_ref": "SHP-2026-0453",
            "supplier_id": supplier_ids.get("Chennai Auto Parts", ""),
            "material_id": material_ids.get("RBR-SEAL-02", ""),
            "quantity": 600,
            "status": "in_delivery",
            "port_of_entry": "none",
            "origin": "Ambattur, Chennai",
            "destination": "Main Warehouse, Chennai",
            "estimated_arrival": (datetime.utcnow() + timedelta(hours=3)).isoformat(),
            "delay_hours": 0,
            "current_location": "Ambattur Industrial Estate — in transit",
        },
    ]

    for s in shipments:
        if s["supplier_id"] and s["material_id"]:
            client.table("shipments").upsert(s, on_conflict="shipment_ref").execute()
            status_icon = "🔴" if s["status"] == "delayed" else "🟡" if s["status"] == "in_transit" else "🟢"
            print(f"    {status_icon} {s['shipment_ref']} — {s['status']}")

    # 5. Consumption Logs (30 days of history)
    print("  📉 Generating consumption history (30 days)...")
    for pn in ["BRK-PAD-001", "BRG-6205", "GSK-CYL-001", "STL-MS-3MM", "RBR-SEAL-02"]:
        if pn not in material_ids:
            continue
        for day_offset in range(30):
            consumed_date = (datetime.utcnow() - timedelta(days=day_offset)).isoformat()
            qty = round(random.uniform(5, 45), 1)
            if pn == "BRK-PAD-001":
                qty = round(random.uniform(15, 35), 1)  # Higher consumption
            elif pn == "GSK-CYL-001":
                qty = round(random.uniform(8, 20), 1)

            client.table("consumption_logs").insert({
                "material_id": material_ids[pn],
                "quantity_consumed": qty,
                "consumed_date": consumed_date,
                "production_order_ref": f"PO-W{22 - day_offset // 7}",
            }).execute()
    print("    ✅ 150 consumption log entries created")

    # 6. Alerts (pre-generated for demo)
    print("  🚨 Creating demo alerts...")
    alerts = [
        {
            "alert_type": "shipment_delayed",
            "severity": "critical",
            "title": "Ennore Port delayed by 48 hours — Steel shipment stuck",
            "description": (
                "Shipment SHP-2026-0451 from Nippon Steel Japan carrying 5,000 kg of "
                "Mild Steel Sheet 3mm is delayed by 48 hours at Ennore Port outer anchorage. "
                "Port congestion level is HIGH with 12 vessels waiting. This steel is needed "
                "for next week's production schedule PS-2026-W23. Current stock of STL-MS-3MM "
                "is at 1,600 kg (below minimum of 2,000 kg) with approximately 4.2 days of "
                "stock remaining at current consumption rate."
            ),
            "recommended_action": (
                "Approve emergency order of 2,000 kg Mild Steel Sheet 3mm from Tata Steel India "
                "(lead time: 12 days, ₹72/kg). Total cost: ₹1,44,000. This provides buffer stock "
                "while the Ennore shipment clears. Alternatively, contact Sundaram Fasteners for "
                "partial quantity (500 kg) with 3-day delivery at ₹78/kg."
            ),
            "estimated_cost_inr": 144000,
            "estimated_savings_inr": 380000,
            "affected_materials": ["STL-MS-3MM"],
            "affected_shipments": ["SHP-2026-0451"],
            "deadline": (datetime.utcnow() + timedelta(hours=24)).isoformat(),
            "metadata": {"confidence": "high", "port": "ennore_port"},
        },
        {
            "alert_type": "shortage_predicted",
            "severity": "urgent",
            "title": "Cylinder Head Gaskets will run out in 2.1 days",
            "description": (
                "Critical shortage predicted for GSK-CYL-001 (Cylinder Head Gasket). "
                "Current stock: 15 units. Minimum level: 100 units. Average daily consumption: "
                "14.2 units/day. At current rate, stockout in approximately 1.1 days. "
                "Production schedule PS-2026-W22-002 (Engine Gasket Set) requires 150 units "
                "planned for tomorrow. No incoming shipments found for this material."
            ),
            "recommended_action": (
                "Approve ₹50,000 emergency order from Chennai Auto Parts (Ambattur). "
                "Order 250 units of Cylinder Head Gasket at ₹1,250/unit. "
                "Lead time: 2 days. This is the fastest option to prevent production halt. "
                "Approve immediately to maintain Engine Gasket Set production schedule."
            ),
            "estimated_cost_inr": 50000,
            "estimated_savings_inr": 215000,
            "affected_materials": ["GSK-CYL-001"],
            "deadline": (datetime.utcnow() + timedelta(hours=4)).isoformat(),
            "metadata": {"confidence": "high", "days_until_stockout": 1.1},
        },
    ]

    for a in alerts:
        client.table("alerts").insert(a).execute()
        severity_icon = "🔴" if a["severity"] in ("critical", "urgent") else "🟡"
        print(f"    {severity_icon} {a['title'][:60]}...")

    # 7. Production Schedules
    print("  🏭 Creating production schedules...")
    for ps in SCHEDULES:
        client.table("production_schedules").upsert(ps, on_conflict="schedule_ref").execute()
        print(f"    ✅ {ps['schedule_ref']} — {ps['product_name']}")

    print("\n✅ Seed data complete! LogiSync is ready for demo.")
    print(f"   Suppliers: {len(SUPPLIERS)}")
    print(f"   Materials: {len(MATERIALS)}")
    print(f"   Inventory: {len(inventory_configs)}")
    print(f"   Shipments: {len(shipments)}")
    print(f"   Alerts: {len(alerts)}")
    print(f"   Schedules: {len(SCHEDULES)}")


if __name__ == "__main__":
    seed()
