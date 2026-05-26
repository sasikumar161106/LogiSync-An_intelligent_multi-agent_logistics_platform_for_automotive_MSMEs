"""
External API Adapters
Provides a unified interface for external data sources (ports, weather, traffic).
Designed with an adapter pattern so real APIs can replace simulated data.
"""

import httpx
import random
from datetime import datetime, timedelta
from typing import Optional


class PortStatusAdapter:
    """
    Adapter for port status data.
    MVP: Uses simulated data with realistic patterns.
    Production: Replace with VesselAPI, Datalastic, or MarineTraffic API.
    """

    # Simulated port conditions for MVP
    _PORT_CONDITIONS = {
        "chennai_port": {
            "base_delay_hours": 8,
            "congestion_range": ("low", "moderate", "high"),
            "vessel_range": (3, 15),
        },
        "ennore_port": {
            "base_delay_hours": 4,
            "congestion_range": ("low", "moderate"),
            "vessel_range": (1, 8),
        },
    }

    def get_port_status(self, port_name: str) -> dict:
        """Get current port status (simulated for MVP)."""
        config = self._PORT_CONDITIONS.get(port_name, self._PORT_CONDITIONS["chennai_port"])

        # Simulate some variability
        congestion = random.choice(config["congestion_range"])
        delay_multiplier = {"low": 0.5, "moderate": 1.0, "high": 2.0, "severe": 3.5}
        delay = config["base_delay_hours"] * delay_multiplier.get(congestion, 1.0)
        delay += random.uniform(-2, 4)  # Add noise

        vessels = random.randint(*config["vessel_range"])

        return {
            "port_name": port_name,
            "congestion_level": congestion,
            "avg_delay_hours": round(max(0, delay), 1),
            "vessels_waiting": vessels,
            "weather_impact": self._get_weather_impact(),
            "last_checked": datetime.utcnow().isoformat(),
        }

    def _get_weather_impact(self) -> Optional[str]:
        """Simulate weather impact (monsoon season = higher impact)."""
        month = datetime.now().month
        if month in (6, 7, 8, 9, 10, 11):  # SW & NE monsoon
            impacts = [None, "Light rain - minimal impact", "Heavy rain - moderate delays",
                       "Cyclone warning - port operations reduced"]
            weights = [0.4, 0.3, 0.2, 0.1]
            return random.choices(impacts, weights=weights)[0]
        return None


class WeatherAdapter:
    """
    Weather data adapter using Open-Meteo free API.
    No API key required!
    """

    BASE_URL = "https://api.open-meteo.com/v1/forecast"
    CHENNAI_LAT = 13.0827
    CHENNAI_LON = 80.2707

    async def get_chennai_weather(self) -> dict:
        """Fetch current weather for Chennai."""
        try:
            async with httpx.AsyncClient() as client:
                response = await client.get(
                    self.BASE_URL,
                    params={
                        "latitude": self.CHENNAI_LAT,
                        "longitude": self.CHENNAI_LON,
                        "current_weather": True,
                        "daily": "precipitation_sum,wind_speed_10m_max",
                        "timezone": "Asia/Kolkata",
                        "forecast_days": 3,
                    },
                    timeout=10.0,
                )
                if response.status_code == 200:
                    data = response.json()
                    current = data.get("current_weather", {})
                    daily = data.get("daily", {})
                    return {
                        "temperature_c": current.get("temperature"),
                        "wind_speed_kmh": current.get("windspeed"),
                        "weather_code": current.get("weathercode"),
                        "is_day": current.get("is_day"),
                        "precipitation_forecast_mm": daily.get("precipitation_sum", []),
                        "wind_forecast_kmh": daily.get("wind_speed_10m_max", []),
                        "risk_level": self._assess_risk(current, daily),
                        "fetched_at": datetime.utcnow().isoformat(),
                    }
        except Exception as e:
            return {"error": str(e), "risk_level": "unknown"}

    def _assess_risk(self, current: dict, daily: dict) -> str:
        """Assess weather risk for logistics operations."""
        precip = daily.get("precipitation_sum", [0])
        wind = daily.get("wind_speed_10m_max", [0])

        max_precip = max(precip) if precip else 0
        max_wind = max(wind) if wind else 0

        if max_precip > 50 or max_wind > 80:
            return "high"
        elif max_precip > 20 or max_wind > 50:
            return "moderate"
        return "low"


class TrafficAdapter:
    """
    Traffic data adapter.
    MVP: Uses simulated data for Chennai routes.
    Production: Replace with Google Maps Directions API.
    """

    # Common logistics routes in Chennai
    _ROUTES = [
        {"from": "Ennore Port", "to": "Ambattur Industrial Estate", "base_minutes": 45},
        {"from": "Chennai Port", "to": "Ambattur Industrial Estate", "base_minutes": 55},
        {"from": "Ennore Port", "to": "Sriperumbudur", "base_minutes": 75},
        {"from": "Chennai Port", "to": "Oragadam", "base_minutes": 90},
        {"from": "Ambattur", "to": "Guindy Industrial Estate", "base_minutes": 40},
    ]

    def get_route_conditions(self) -> list[dict]:
        """Get simulated traffic conditions for key logistics routes."""
        hour = datetime.now().hour
        # Peak hours: 8-10 AM, 5-8 PM
        is_peak = hour in range(8, 11) or hour in range(17, 21)
        multiplier = random.uniform(1.5, 2.5) if is_peak else random.uniform(0.8, 1.3)

        routes = []
        for route in self._ROUTES:
            travel_time = int(route["base_minutes"] * multiplier)
            routes.append({
                "from": route["from"],
                "to": route["to"],
                "estimated_minutes": travel_time,
                "base_minutes": route["base_minutes"],
                "delay_minutes": max(0, travel_time - route["base_minutes"]),
                "traffic_level": "heavy" if multiplier > 1.8 else "moderate" if multiplier > 1.2 else "light",
                "checked_at": datetime.utcnow().isoformat(),
            })
        return routes
