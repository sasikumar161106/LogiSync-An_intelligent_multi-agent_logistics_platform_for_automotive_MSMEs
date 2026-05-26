"""
LogiSync Crew Orchestration
The main CrewAI crew that chains all 4 agents and 6 tasks together.
"""

import json
import os
from datetime import datetime, timedelta
from pathlib import Path

from crewai import Agent, Crew, Process, Task
from crewai.project import CrewBase, agent, crew, task

from app.crews.tools.inventory_tools import (
    get_inventory_levels,
    get_consumption_rate,
    get_critical_stock_items,
    check_incoming_shipments,
)
from app.crews.tools.port_tools import (
    check_port_status,
    get_delayed_shipments,
    get_both_ports_summary,
)
from app.crews.tools.weather_tools import (
    get_chennai_weather,
    get_traffic_conditions,
)
from app.crews.tools.supplier_tools import (
    search_suppliers_by_category,
    compare_suppliers,
    get_all_suppliers,
)
from app.crews.callbacks import AlertCallback


@CrewBase
class LogiSyncCrew:
    """
    The core multi-agent crew for supply chain monitoring and optimization.
    
    Agents:
        1. LogisticsWatcher — monitors ports, weather, traffic
        2. InventoryAnalyst — analyzes stock levels and consumption
        3. ProcurementOptimizer — finds alternative suppliers, drafts POs
        4. ScheduleAdjuster — recalculates production schedules
    
    Process: Sequential (Monitor → Analyze → Identify → Resolve → Adjust → Alert)
    """

    agents_config = str(Path(__file__).parent / "config" / "agents.yaml")
    tasks_config = str(Path(__file__).parent / "config" / "tasks.yaml")

    # ── AGENTS ─────────────────────────────────────────────

    @agent
    def logistics_watcher(self) -> Agent:
        return Agent(
            config=self.agents_config["logistics_watcher"],
            tools=[check_port_status, get_both_ports_summary, get_delayed_shipments,
                   get_chennai_weather, get_traffic_conditions],
            llm="gemini/gemini-1.5-flash",
        )

    @agent
    def inventory_analyst(self) -> Agent:
        return Agent(
            config=self.agents_config["inventory_analyst"],
            tools=[get_inventory_levels, get_consumption_rate,
                   get_critical_stock_items, check_incoming_shipments],
            llm="gemini/gemini-1.5-flash",
        )

    @agent
    def procurement_optimizer(self) -> Agent:
        return Agent(
            config=self.agents_config["procurement_optimizer"],
            tools=[search_suppliers_by_category, compare_suppliers,
                   get_all_suppliers, get_critical_stock_items],
            llm="gemini/gemini-1.5-flash",
        )

    @agent
    def schedule_adjuster(self) -> Agent:
        return Agent(
            config=self.agents_config["schedule_adjuster"],
            tools=[get_inventory_levels, get_critical_stock_items],
            llm="gemini/gemini-1.5-flash",
        )

    # ── TASKS ──────────────────────────────────────────────

    @task
    def monitor_external_conditions(self) -> Task:
        return Task(
            config=self.tasks_config["monitor_external_conditions"],
        )

    @task
    def analyze_inventory_health(self) -> Task:
        return Task(
            config=self.tasks_config["analyze_inventory_health"],
        )

    @task
    def identify_bottlenecks(self) -> Task:
        return Task(
            config=self.tasks_config["identify_bottlenecks"],
        )

    @task
    def draft_resolution_plan(self) -> Task:
        return Task(
            config=self.tasks_config["draft_resolution_plan"],
        )

    @task
    def adjust_production_schedule(self) -> Task:
        return Task(
            config=self.tasks_config["adjust_production_schedule"],
        )

    @task
    def generate_smart_alerts(self) -> Task:
        return Task(
            config=self.tasks_config["generate_smart_alerts"],
        )

    # ── CREW ───────────────────────────────────────────────

    @crew
    def crew(self) -> Crew:
        return Crew(
            agents=self.agents,
            tasks=self.tasks,
            process=Process.sequential,
            verbose=True,
        )


def run_monitoring_cycle(trigger: str = "manual") -> dict:
    """
    Execute a full monitoring cycle.
    This is the main entry point called by the API or scheduler.
    
    Args:
        trigger: 'manual', 'scheduled', or 'event'
    
    Returns:
        dict with run results and any generated alerts
    """
    from app.services.supabase_svc import SupabaseService
    from app.config import get_settings

    settings = get_settings()
    svc = SupabaseService()

    # Create agent run record
    run_record = svc.create_agent_run({
        "trigger": trigger,
        "status": "running",
        "agents_involved": [
            "logistics_watcher", "inventory_analyst",
            "procurement_optimizer", "schedule_adjuster"
        ],
    })
    run_id = run_record["id"]

    try:
        # Set up the environment for Gemini
        os.environ["GEMINI_API_KEY"] = settings.gemini_api_key

        # Initialize and run the crew
        logisync_crew = LogiSyncCrew()
        result = logisync_crew.crew().kickoff(
            inputs={
                "company_name": "LogiSync MSME",
                "current_date": datetime.now().strftime("%Y-%m-%d %H:%M IST"),
                "alert_threshold_days": str(settings.alert_threshold_days),
            }
        )

        # Parse alerts from the final task output
        alerts_created = AlertCallback.parse_and_save_alerts(
            result.raw, run_id, svc
        )

        # Update run record
        completed_at = datetime.utcnow()
        svc.update_agent_run(run_id, {
            "status": "completed",
            "completed_at": completed_at.isoformat(),
            "duration_seconds": (
                completed_at - datetime.fromisoformat(run_record["started_at"].replace("Z", "+00:00").replace("+00:00", ""))
            ).total_seconds() if run_record.get("started_at") else 0,
            "tasks_completed": 6,
            "alerts_generated": alerts_created,
            "summary": result.raw[:500] if result.raw else "Completed successfully",
        })

        return {
            "run_id": run_id,
            "status": "completed",
            "alerts_generated": alerts_created,
            "summary": result.raw[:1000] if result.raw else "",
        }

    except Exception as e:
        # Update run record with error
        svc.update_agent_run(run_id, {
            "status": "failed",
            "completed_at": datetime.utcnow().isoformat(),
            "error_message": str(e),
        })

        return {
            "run_id": run_id,
            "status": "failed",
            "error": str(e),
        }
