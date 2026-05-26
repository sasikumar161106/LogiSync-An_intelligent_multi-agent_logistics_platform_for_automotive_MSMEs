"""
Alerts API Router
Core of the human-in-the-loop workflow — actionable AI alerts with approve/reject.
"""

from fastapi import APIRouter, HTTPException
from typing import Optional
from app.services.supabase_svc import SupabaseService
from app.models.alerts import AlertAction

router = APIRouter()


@router.get("/")
async def list_alerts(
    status: Optional[str] = None,
    limit: int = 50,
):
    """
    List alerts, optionally filtered by status.
    Status options: pending, approved, rejected, modified, expired, auto_resolved
    """
    svc = SupabaseService()
    return svc.get_alerts(status=status, limit=limit)


@router.get("/pending")
async def list_pending_alerts():
    """Get all pending alerts that require manager attention."""
    svc = SupabaseService()
    return svc.get_pending_alerts()


@router.get("/summary")
async def alert_summary():
    """Get alert summary statistics for the dashboard."""
    svc = SupabaseService()
    all_alerts = svc.get_alerts(limit=200)
    pending = [a for a in all_alerts if a.get("status") == "pending"]
    critical = [a for a in pending if a.get("severity") in ("critical", "urgent")]

    # Calculate today's resolved
    from datetime import datetime, date
    today = date.today().isoformat()
    resolved_today = [
        a for a in all_alerts
        if a.get("resolved_at") and a["resolved_at"].startswith(today)
    ]
    savings_today = sum(
        float(a.get("estimated_savings_inr", 0) or 0) for a in resolved_today
        if a.get("status") == "approved"
    )

    return {
        "total_pending": len(pending),
        "total_critical": len(critical),
        "total_resolved_today": len(resolved_today),
        "estimated_savings_today_inr": savings_today,
        "recent_alerts": pending[:10],
    }


@router.get("/{alert_id}")
async def get_alert(alert_id: str):
    """Get a specific alert by ID."""
    svc = SupabaseService()
    alert = svc.get_alert(alert_id)
    if not alert:
        raise HTTPException(status_code=404, detail="Alert not found")
    return alert


@router.post("/{alert_id}/approve")
async def approve_alert(alert_id: str):
    """
    Approve an AI-recommended action.
    This triggers execution of the recommended plan (e.g., creating a purchase order).
    """
    svc = SupabaseService()
    alert = svc.get_alert(alert_id)
    if not alert:
        raise HTTPException(status_code=404, detail="Alert not found")
    if alert["status"] != "pending":
        raise HTTPException(status_code=400, detail=f"Alert is already {alert['status']}")

    # Update alert status
    updated = svc.update_alert_status(alert_id, "approved", resolved_by="manager")

    # If the alert recommended a purchase order, create it
    if alert.get("alert_type") in ("shortage_predicted", "reorder_suggested"):
        _execute_procurement_action(svc, alert)

    return {"status": "approved", "alert": updated}


@router.post("/{alert_id}/reject")
async def reject_alert(alert_id: str, action: AlertAction):
    """Reject an AI recommendation with a reason."""
    svc = SupabaseService()
    alert = svc.get_alert(alert_id)
    if not alert:
        raise HTTPException(status_code=404, detail="Alert not found")
    if alert["status"] != "pending":
        raise HTTPException(status_code=400, detail=f"Alert is already {alert['status']}")

    updated = svc.update_alert_status(alert_id, "rejected", resolved_by="manager")
    return {"status": "rejected", "reason": action.reason, "alert": updated}


@router.post("/{alert_id}/modify")
async def modify_alert(alert_id: str, action: AlertAction):
    """Modify an AI recommendation before approving it."""
    svc = SupabaseService()
    alert = svc.get_alert(alert_id)
    if not alert:
        raise HTTPException(status_code=404, detail="Alert not found")
    if alert["status"] != "pending":
        raise HTTPException(status_code=400, detail=f"Alert is already {alert['status']}")

    # Update the alert with the modified action
    svc.client.table("alerts").update({
        "status": "modified",
        "recommended_action": action.modified_action or alert["recommended_action"],
        "resolved_at": __import__("datetime").datetime.utcnow().isoformat(),
        "resolved_by": "manager",
        "metadata": {
            **alert.get("metadata", {}),
            "original_recommendation": alert["recommended_action"],
            "manager_modification": action.modified_action,
            "modification_reason": action.reason,
        }
    }).eq("id", alert_id).execute()

    return {"status": "modified", "alert_id": alert_id}


def _execute_procurement_action(svc: SupabaseService, alert: dict):
    """Execute the procurement action from an approved alert."""
    try:
        metadata = alert.get("metadata", {})
        affected = alert.get("affected_materials", [])

        if affected:
            # Create a draft purchase order based on alert data
            from datetime import date, timedelta
            svc.create_purchase_order({
                "po_number": f"PO-AI-{alert['id'][:8].upper()}",
                "supplier_id": metadata.get("recommended_supplier_id", ""),
                "material_id": affected[0] if affected else "",
                "quantity": metadata.get("recommended_quantity", 0),
                "unit_price_inr": metadata.get("unit_price_inr", 0),
                "total_amount_inr": float(alert.get("estimated_cost_inr", 0)),
                "expected_delivery": (date.today() + timedelta(days=7)).isoformat(),
                "status": "submitted",
                "is_ai_generated": True,
                "alert_id": alert["id"],
                "notes": f"Auto-generated from approved alert: {alert['title']}",
            })
    except Exception as e:
        print(f"Failed to execute procurement action: {e}")
