"""
Supabase Service Layer
Handles all database CRUD operations for LogiSync.
"""

from datetime import datetime, date, timedelta
from typing import Optional
from app.dependencies import get_supabase_client


class SupabaseService:
    """Central service for all Supabase database operations."""

    def __init__(self):
        self.client = get_supabase_client()

    # ── SUPPLIERS ──────────────────────────────────────────

    def get_suppliers(self, active_only: bool = True) -> list[dict]:
        query = self.client.table("suppliers").select("*")
        if active_only:
            query = query.eq("is_active", True)
        return query.order("name").execute().data

    def get_supplier(self, supplier_id: str) -> Optional[dict]:
        result = self.client.table("suppliers").select("*").eq("id", supplier_id).execute()
        return result.data[0] if result.data else None

    def create_supplier(self, data: dict) -> dict:
        return self.client.table("suppliers").insert(data).execute().data[0]

    def update_supplier(self, supplier_id: str, data: dict) -> dict:
        return self.client.table("suppliers").update(data).eq("id", supplier_id).execute().data[0]

    # ── MATERIALS ──────────────────────────────────────────

    def get_materials(self, active_only: bool = True) -> list[dict]:
        query = self.client.table("materials").select("*")
        if active_only:
            query = query.eq("is_active", True)
        return query.order("name").execute().data

    def get_material(self, material_id: str) -> Optional[dict]:
        result = self.client.table("materials").select("*").eq("id", material_id).execute()
        return result.data[0] if result.data else None

    def create_material(self, data: dict) -> dict:
        return self.client.table("materials").insert(data).execute().data[0]

    def update_material(self, material_id: str, data: dict) -> dict:
        return self.client.table("materials").update(data).eq("id", material_id).execute().data[0]

    # ── INVENTORY ──────────────────────────────────────────

    def get_inventory(self, warehouse: str = "main") -> list[dict]:
        return (
            self.client.table("inventory")
            .select("*, materials(*)")
            .eq("warehouse", warehouse)
            .execute()
            .data
        )

    def get_inventory_item(self, material_id: str, warehouse: str = "main") -> Optional[dict]:
        result = (
            self.client.table("inventory")
            .select("*, materials(*)")
            .eq("material_id", material_id)
            .eq("warehouse", warehouse)
            .execute()
        )
        return result.data[0] if result.data else None

    def update_inventory(self, inventory_id: str, data: dict) -> dict:
        data["last_updated"] = datetime.utcnow().isoformat()
        return self.client.table("inventory").update(data).eq("id", inventory_id).execute().data[0]

    def get_inventory_health(self) -> list[dict]:
        """Get all inventory items with material details for health dashboard."""
        return (
            self.client.table("inventory")
            .select("*, materials(name, part_number, category, unit_price, min_stock_level)")
            .order("stock_status", desc=True)
            .execute()
            .data
        )

    # ── CONSUMPTION LOGS ──────────────────────────────────

    def get_consumption_logs(
        self, material_id: str, days: int = 30
    ) -> list[dict]:
        since = (datetime.utcnow() - timedelta(days=days)).isoformat()
        return (
            self.client.table("consumption_logs")
            .select("*")
            .eq("material_id", material_id)
            .gte("consumed_date", since)
            .order("consumed_date", desc=True)
            .execute()
            .data
        )

    def get_avg_daily_consumption(self, material_id: str, days: int = 30) -> float:
        """Calculate average daily consumption rate for a material."""
        logs = self.get_consumption_logs(material_id, days)
        if not logs:
            return 0.0
        total = sum(float(log["quantity_consumed"]) for log in logs)
        return total / days

    def log_consumption(self, data: dict) -> dict:
        return self.client.table("consumption_logs").insert(data).execute().data[0]

    # ── SHIPMENTS ──────────────────────────────────────────

    def get_shipments(self, status: Optional[str] = None) -> list[dict]:
        query = self.client.table("shipments").select("*, suppliers(name), materials(name, part_number)")
        if status:
            query = query.eq("status", status)
        return query.order("estimated_arrival").execute().data

    def get_active_shipments(self) -> list[dict]:
        return (
            self.client.table("shipments")
            .select("*, suppliers(name), materials(name, part_number)")
            .not_.eq("status", "delivered")
            .not_.eq("status", "cancelled")
            .order("estimated_arrival")
            .execute()
            .data
        )

    def get_shipment(self, shipment_id: str) -> Optional[dict]:
        result = (
            self.client.table("shipments")
            .select("*, suppliers(name), materials(name)")
            .eq("id", shipment_id)
            .execute()
        )
        return result.data[0] if result.data else None

    def create_shipment(self, data: dict) -> dict:
        return self.client.table("shipments").insert(data).execute().data[0]

    def update_shipment(self, shipment_id: str, data: dict) -> dict:
        return self.client.table("shipments").update(data).eq("id", shipment_id).execute().data[0]

    def get_delayed_shipments(self) -> list[dict]:
        return (
            self.client.table("shipments")
            .select("*, suppliers(name), materials(name, part_number)")
            .gt("delay_hours", 0)
            .not_.eq("status", "delivered")
            .not_.eq("status", "cancelled")
            .execute()
            .data
        )

    # ── PORT STATUS ────────────────────────────────────────

    def get_port_status(self) -> list[dict]:
        return self.client.table("port_status").select("*").execute().data

    def update_port_status(self, port_name: str, data: dict) -> dict:
        data["last_checked"] = datetime.utcnow().isoformat()
        return (
            self.client.table("port_status")
            .update(data)
            .eq("port_name", port_name)
            .execute()
            .data[0]
        )

    # ── ALERTS ─────────────────────────────────────────────

    def get_alerts(self, status: Optional[str] = None, limit: int = 50) -> list[dict]:
        query = self.client.table("alerts").select("*")
        if status:
            query = query.eq("status", status)
        return query.order("created_at", desc=True).limit(limit).execute().data

    def get_pending_alerts(self) -> list[dict]:
        return self.get_alerts(status="pending")

    def get_alert(self, alert_id: str) -> Optional[dict]:
        result = self.client.table("alerts").select("*").eq("id", alert_id).execute()
        return result.data[0] if result.data else None

    def create_alert(self, data: dict) -> dict:
        result = self.client.table("alerts").insert(data).execute().data[0]
        
        # Trigger WhatsApp/SMS if critical or urgent
        severity = result.get("severity", "info")
        if severity in ("critical", "urgent"):
            try:
                from app.services.notification_svc import NotificationService
                svc = NotificationService()
                svc.send_whatsapp_alert(
                    title=result.get("title", "New Alert"),
                    description=result.get("description", ""),
                    severity=severity
                )
            except Exception as e:
                import logging
                logging.getLogger(__name__).error(f"Failed to trigger notification: {e}")
                
        return result

    def update_alert_status(
        self, alert_id: str, status: str, resolved_by: Optional[str] = None
    ) -> dict:
        update_data = {"status": status}
        if status in ("approved", "rejected", "modified"):
            update_data["resolved_at"] = datetime.utcnow().isoformat()
            if resolved_by:
                update_data["resolved_by"] = resolved_by
        return self.client.table("alerts").update(update_data).eq("id", alert_id).execute().data[0]

    # ── PURCHASE ORDERS ────────────────────────────────────

    def create_purchase_order(self, data: dict) -> dict:
        return self.client.table("purchase_orders").insert(data).execute().data[0]

    def get_purchase_orders(self, status: Optional[str] = None) -> list[dict]:
        query = self.client.table("purchase_orders").select("*, suppliers(name), materials(name)")
        if status:
            query = query.eq("status", status)
        return query.order("created_at", desc=True).execute().data

    # ── PRODUCTION SCHEDULES ───────────────────────────────

    def get_production_schedules(
        self, from_date: Optional[date] = None, to_date: Optional[date] = None
    ) -> list[dict]:
        query = self.client.table("production_schedules").select("*")
        if from_date:
            query = query.gte("planned_date", from_date.isoformat())
        if to_date:
            query = query.lte("planned_date", to_date.isoformat())
        return query.order("planned_date").execute().data

    def update_production_schedule(self, schedule_id: str, data: dict) -> dict:
        return (
            self.client.table("production_schedules")
            .update(data)
            .eq("id", schedule_id)
            .execute()
            .data[0]
        )

    # ── AGENT RUNS ─────────────────────────────────────────

    def create_agent_run(self, data: dict) -> dict:
        return self.client.table("agent_runs").insert(data).execute().data[0]

    def update_agent_run(self, run_id: str, data: dict) -> dict:
        return self.client.table("agent_runs").update(data).eq("id", run_id).execute().data[0]

    def get_agent_runs(self, limit: int = 20) -> list[dict]:
        return (
            self.client.table("agent_runs")
            .select("*")
            .order("started_at", desc=True)
            .limit(limit)
            .execute()
            .data
        )

    # ── DASHBOARD AGGREGATIONS ─────────────────────────────

    def get_dashboard_summary(self) -> dict:
        """Aggregate KPIs for the main dashboard."""
        inventory = self.get_inventory_health()
        active_shipments = self.get_active_shipments()
        pending_alerts = self.get_pending_alerts()
        suppliers = self.get_suppliers()
        agent_runs = self.get_agent_runs(limit=1)

        total_value = sum(
            float(i.get("current_stock", 0)) * float(i.get("materials", {}).get("unit_price", 0))
            for i in inventory
        )
        at_risk = sum(
            1 for i in inventory if i.get("stock_status") in ("critical", "out_of_stock")
        )
        delayed = sum(1 for s in active_shipments if float(s.get("delay_hours", 0)) > 0)
        critical_alerts = sum(
            1 for a in pending_alerts if a.get("severity") in ("critical", "urgent")
        )

        return {
            "total_inventory_value_inr": round(total_value, 2),
            "materials_at_risk": at_risk,
            "active_shipments": len(active_shipments),
            "delayed_shipments": delayed,
            "pending_alerts": len(pending_alerts),
            "critical_alerts": critical_alerts,
            "production_efficiency_pct": 87.5,  # TODO: calculate from production_schedules
            "total_suppliers": len(suppliers),
            "ai_savings_this_month_inr": 0,
            "last_agent_run": agent_runs[0]["started_at"] if agent_runs else None,
        }
