"""
LogiSync Configuration Module
Loads environment variables and provides typed settings across the application.
"""

from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    # Supabase
    supabase_url: str = "https://your-project.supabase.co"
    supabase_key: str = "your-anon-key"
    supabase_service_key: str = "your-service-role-key"

    # Google Gemini
    gemini_api_key: str = "your-gemini-api-key"

    # Twilio / WhatsApp Notifications
    twilio_account_sid: str = ""
    twilio_auth_token: str = ""
    twilio_from_number: str = ""
    manager_phone_number: str = ""

    # Agent Configuration
    agent_run_interval_minutes: int = 30
    alert_threshold_days: int = 3

    # Server
    host: str = "0.0.0.0"
    port: int = 8000
    debug: bool = True

    # App Metadata
    app_name: str = "LogiSync Agentic Control Tower"
    app_version: str = "1.0.0"

    model_config = {
        "env_file": ".env",
        "env_file_encoding": "utf-8",
        "case_sensitive": False,
    }


@lru_cache()
def get_settings() -> Settings:
    """Cached settings singleton."""
    return Settings()
