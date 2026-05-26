"""
Alert Callback
Parses the final agent output and creates structured alerts in Supabase.
"""

import json
import re
from datetime import datetime, timedelta
from typing import Optional


class AlertCallback:
    """Handles parsing agent output into structured alerts."""

    @staticmethod
    def parse_and_save_alerts(
        raw_output: str, run_id: str, svc
    ) -> int:
        """
        Parse the final task output (expected JSON array of alerts)
        and save each alert to the database.
        
        Returns the number of alerts created.
        """
        alerts_data = AlertCallback._extract_json_alerts(raw_output)

        if not alerts_data:
            return 0

        created_count = 0
        for alert_data in alerts_data:
            try:
                # Map deadline_hours to actual datetime
                deadline_hours = alert_data.pop("deadline_hours", 24)
                deadline = (datetime.utcnow() + timedelta(hours=deadline_hours)).isoformat()

                alert_record = {
                    "alert_type": alert_data.get("alert_type", "reorder_suggested"),
                    "severity": alert_data.get("severity", "warning"),
                    "title": alert_data.get("title", "AI Alert")[:200],
                    "description": alert_data.get("description", "")[:2000],
                    "recommended_action": alert_data.get("recommended_action", "Review required"),
                    "estimated_cost_inr": alert_data.get("estimated_cost_inr"),
                    "estimated_savings_inr": alert_data.get("estimated_savings_inr"),
                    "affected_materials": alert_data.get("affected_materials", []),
                    "affected_shipments": alert_data.get("affected_shipments", []),
                    "deadline": deadline,
                    "agent_run_id": run_id,
                    "metadata": {
                        "raw_recommendation": alert_data.get("recommended_action", ""),
                        "confidence": alert_data.get("confidence", "medium"),
                    },
                }

                svc.create_alert(alert_record)
                created_count += 1

            except Exception as e:
                print(f"Failed to create alert: {e}")
                continue

        return created_count

    @staticmethod
    def _extract_json_alerts(raw_output: str) -> list[dict]:
        """
        Extract JSON alert array from agent output.
        The agent might wrap JSON in markdown code blocks or mixed text.
        """
        if not raw_output:
            return []

        # Try 1: Direct JSON parse
        try:
            data = json.loads(raw_output)
            if isinstance(data, list):
                return data
            if isinstance(data, dict) and "alerts" in data:
                return data["alerts"]
        except json.JSONDecodeError:
            pass

        # Try 2: Extract JSON from markdown code blocks
        json_pattern = r'```(?:json)?\s*(\[[\s\S]*?\])\s*```'
        matches = re.findall(json_pattern, raw_output)
        for match in matches:
            try:
                data = json.loads(match)
                if isinstance(data, list):
                    return data
            except json.JSONDecodeError:
                continue

        # Try 3: Find JSON array in the text
        bracket_pattern = r'\[[\s\S]*\]'
        matches = re.findall(bracket_pattern, raw_output)
        for match in matches:
            try:
                data = json.loads(match)
                if isinstance(data, list) and len(data) > 0:
                    return data
            except json.JSONDecodeError:
                continue

        return []
