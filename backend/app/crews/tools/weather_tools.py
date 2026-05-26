"""
Weather Tools for CrewAI Agents
Provides weather data for logistics risk assessment.
"""

import asyncio
from crewai.tools import tool
from app.services.external_apis import WeatherAdapter, TrafficAdapter


@tool("Get Chennai Weather Forecast")
def get_chennai_weather() -> str:
    """
    Fetches the current weather and 3-day forecast for Chennai.
    Includes temperature, wind speed, precipitation, and logistics risk assessment.
    Uses the free Open-Meteo API — no API key required.
    """
    adapter = WeatherAdapter()

    # Run async function in sync context
    try:
        loop = asyncio.get_event_loop()
        if loop.is_running():
            import concurrent.futures
            with concurrent.futures.ThreadPoolExecutor() as pool:
                weather = pool.submit(asyncio.run, adapter.get_chennai_weather()).result()
        else:
            weather = asyncio.run(adapter.get_chennai_weather())
    except Exception:
        weather = asyncio.run(adapter.get_chennai_weather())

    if "error" in weather:
        return f"⚠️ Weather data unavailable: {weather['error']}\nRisk Level: UNKNOWN"

    precip = weather.get("precipitation_forecast_mm", [])
    wind = weather.get("wind_forecast_kmh", [])

    return (
        f"=== CHENNAI WEATHER REPORT ===\n"
        f"Temperature: {weather.get('temperature_c', 'N/A')}°C\n"
        f"Wind Speed: {weather.get('wind_speed_kmh', 'N/A')} km/h\n"
        f"Daytime: {'Yes' if weather.get('is_day') else 'No'}\n\n"
        f"3-DAY FORECAST:\n"
        f"  Precipitation: {', '.join(f'{p}mm' for p in precip)}\n"
        f"  Max Wind: {', '.join(f'{w}km/h' for w in wind)}\n\n"
        f"LOGISTICS RISK: {weather.get('risk_level', 'unknown').upper()}\n"
    )


@tool("Get Traffic Conditions")
def get_traffic_conditions() -> str:
    """
    Gets current traffic conditions on key logistics routes in Chennai.
    Shows estimated travel times from ports to industrial estates.
    """
    adapter = TrafficAdapter()
    routes = adapter.get_route_conditions()

    lines = ["=== CHENNAI LOGISTICS TRAFFIC ===\n"]
    for route in routes:
        delay_indicator = ""
        if route["traffic_level"] == "heavy":
            delay_indicator = "🔴"
        elif route["traffic_level"] == "moderate":
            delay_indicator = "🟡"
        else:
            delay_indicator = "🟢"

        lines.append(
            f"{delay_indicator} {route['from']} → {route['to']}\n"
            f"   Travel Time: {route['estimated_minutes']} min "
            f"(normal: {route['base_minutes']} min)\n"
            f"   Delay: +{route['delay_minutes']} min | "
            f"Traffic: {route['traffic_level'].upper()}\n"
        )

    return "\n".join(lines)
