"""
AI Agents API Router
Trigger, monitor, and review CrewAI agent runs.
"""

import asyncio
from fastapi import APIRouter, BackgroundTasks
from app.services.supabase_svc import SupabaseService

router = APIRouter()


@router.post("/run")
async def trigger_agent_run(background_tasks: BackgroundTasks):
    """
    Manually trigger a full monitoring cycle.
    The crew runs in the background to avoid blocking the API.
    Returns a run_id to track progress.
    """
    from app.crews.crew import run_monitoring_cycle

    # Run the crew in a background thread (CrewAI is synchronous)
    background_tasks.add_task(
        asyncio.to_thread,
        run_monitoring_cycle,
        "manual",
    )

    return {
        "status": "started",
        "message": "Agent monitoring cycle started. Check /api/agents/history for results.",
    }


@router.get("/history")
async def get_agent_history(limit: int = 20):
    """Get the history of agent runs with results."""
    svc = SupabaseService()
    return svc.get_agent_runs(limit=limit)


@router.get("/status/{run_id}")
async def get_run_status(run_id: str):
    """Check the status of a specific agent run."""
    svc = SupabaseService()
    runs = svc.get_agent_runs(limit=100)
    run = next((r for r in runs if r["id"] == run_id), None)

    if not run:
        from fastapi import HTTPException
        raise HTTPException(status_code=404, detail="Agent run not found")

    return run


@router.get("/config")
async def get_agent_config():
    """Get the current agent configuration."""
    from app.config import get_settings
    settings = get_settings()

    return {
        "run_interval_minutes": settings.agent_run_interval_minutes,
        "alert_threshold_days": settings.alert_threshold_days,
        "llm_model": "gemini-1.5-flash",
        "agents": [
            {
                "name": "LogisticsWatcher",
                "role": "Port & Logistics Monitor",
                "tools": ["check_port_status", "get_chennai_weather", "get_traffic_conditions"],
            },
            {
                "name": "InventoryAnalyst",
                "role": "Inventory Intelligence",
                "tools": ["get_inventory_levels", "get_consumption_rate", "get_critical_stock_items"],
            },
            {
                "name": "ProcurementOptimizer",
                "role": "Supplier & PO Specialist",
                "tools": ["search_suppliers", "compare_suppliers", "get_all_suppliers"],
            },
            {
                "name": "ScheduleAdjuster",
                "role": "Production Scheduler",
                "tools": ["get_inventory_levels", "get_critical_stock_items"],
            },
        ],
    }
