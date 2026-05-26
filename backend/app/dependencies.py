"""
LogiSync Dependency Injection Module
Provides shared dependencies like Supabase client across the application.
"""

from supabase import create_client, Client
from functools import lru_cache
from app.config import get_settings


@lru_cache()
def get_supabase_client() -> Client:
    """Creates and caches a Supabase client instance."""
    settings = get_settings()
    return create_client(settings.supabase_url, settings.supabase_key)


@lru_cache()
def get_supabase_admin_client() -> Client:
    """Creates a Supabase client with service role key for admin operations."""
    settings = get_settings()
    return create_client(settings.supabase_url, settings.supabase_service_key)
