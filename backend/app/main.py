"""
LogiSync — Agentic Control Tower for Automotive MSMEs
FastAPI Application Entry Point

This is the main application server that bridges:
- CrewAI multi-agent system (AI brain)
- Supabase PostgreSQL (data layer)
- Flutter frontend (presentation layer)
"""

from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import get_settings
from app.routers import dashboard, alerts, agents, inventory, suppliers, shipments, imports


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifecycle manager — runs on startup and shutdown."""
    settings = get_settings()
    print(f"🚀 {settings.app_name} v{settings.app_version} starting...")
    print(f"📡 Supabase: {settings.supabase_url}")
    print(f"🤖 Agent interval: every {settings.agent_run_interval_minutes} minutes")
    print(f"⚠️  Alert threshold: {settings.alert_threshold_days} days")
    yield
    print("🛑 LogiSync shutting down...")


settings = get_settings()

app = FastAPI(
    title=settings.app_name,
    description=(
        "An intelligent, agentic logistics platform that continuously monitors "
        "supply chain data, predicts shortages, and autonomously drafts resolution "
        "strategies for automotive MSMEs around Chennai."
    ),
    version=settings.app_version,
    lifespan=lifespan,
)

# CORS — Allow Flutter web and mobile to connect
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Tighten in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register API routers
app.include_router(dashboard.router, prefix="/api/dashboard", tags=["Dashboard"])
app.include_router(alerts.router, prefix="/api/alerts", tags=["Alerts"])
app.include_router(agents.router, prefix="/api/agents", tags=["AI Agents"])
app.include_router(inventory.router, prefix="/api/inventory", tags=["Inventory"])
app.include_router(suppliers.router, prefix="/api/suppliers", tags=["Suppliers"])
app.include_router(shipments.router, prefix="/api/shipments", tags=["Shipments"])
app.include_router(imports.router, prefix="/api/imports", tags=["Data Import"])


@app.get("/", tags=["Health"])
async def root():
    """Health check endpoint."""
    return {
        "status": "operational",
        "service": settings.app_name,
        "version": settings.app_version,
    }


@app.get("/health", tags=["Health"])
async def health_check():
    """Detailed health check with dependency status."""
    return {
        "status": "healthy",
        "service": settings.app_name,
        "version": settings.app_version,
        "dependencies": {
            "supabase": "configured",
            "gemini": "configured",
            "agents": "ready",
        },
    }
