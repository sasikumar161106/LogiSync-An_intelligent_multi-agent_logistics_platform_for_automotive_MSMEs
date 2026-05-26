"""
Data Import Service
Handles Excel/CSV file parsing and bulk data import into Supabase.
"""

import pandas as pd
from io import BytesIO
from typing import Optional
from app.services.supabase_svc import SupabaseService


class ImportService:
    """Parses Excel/CSV files and imports data into LogiSync tables."""

    SUPPORTED_TABLES = {
        "materials": {
            "required_columns": ["part_number", "name", "category"],
            "optional_columns": ["description", "unit", "min_stock_level", "reorder_quantity", "unit_price"],
        },
        "suppliers": {
            "required_columns": ["name", "supplier_type", "location", "lead_time_days"],
            "optional_columns": ["contact_person", "phone", "email", "reliability_score", "port_of_entry", "payment_terms"],
        },
        "inventory": {
            "required_columns": ["part_number", "current_stock"],
            "optional_columns": ["warehouse", "reserved_stock"],
        },
        "consumption_logs": {
            "required_columns": ["part_number", "quantity_consumed", "consumed_date"],
            "optional_columns": ["production_order_ref", "notes"],
        },
    }

    def __init__(self):
        self.svc = SupabaseService()

    def parse_file(self, file_content: bytes, filename: str) -> pd.DataFrame:
        """Parse an uploaded Excel or CSV file into a DataFrame."""
        buffer = BytesIO(file_content)

        if filename.endswith(".csv"):
            df = pd.read_csv(buffer)
        elif filename.endswith((".xlsx", ".xls")):
            df = pd.read_excel(buffer, engine="openpyxl")
        else:
            raise ValueError(f"Unsupported file format: {filename}. Use .csv, .xlsx, or .xls")

        # Normalize column names
        df.columns = [col.strip().lower().replace(" ", "_") for col in df.columns]
        return df

    def validate_columns(self, df: pd.DataFrame, table_name: str) -> dict:
        """Validate that the DataFrame has required columns for the target table."""
        if table_name not in self.SUPPORTED_TABLES:
            return {"valid": False, "error": f"Unsupported table: {table_name}"}

        config = self.SUPPORTED_TABLES[table_name]
        missing = [col for col in config["required_columns"] if col not in df.columns]

        if missing:
            return {
                "valid": False,
                "error": f"Missing required columns: {', '.join(missing)}",
                "required": config["required_columns"],
                "found": list(df.columns),
            }

        return {
            "valid": True,
            "rows": len(df),
            "columns": list(df.columns),
        }

    def import_materials(self, df: pd.DataFrame) -> dict:
        """Bulk import materials from a DataFrame."""
        records = df.to_dict(orient="records")
        created = 0
        errors = []

        for record in records:
            try:
                # Clean NaN values
                clean_record = {k: v for k, v in record.items() if pd.notna(v)}
                self.svc.create_material(clean_record)
                created += 1
            except Exception as e:
                errors.append({"row": record.get("part_number", "unknown"), "error": str(e)})

        return {"created": created, "errors": errors, "total": len(records)}

    def import_suppliers(self, df: pd.DataFrame) -> dict:
        """Bulk import suppliers from a DataFrame."""
        records = df.to_dict(orient="records")
        created = 0
        errors = []

        for record in records:
            try:
                clean_record = {k: v for k, v in record.items() if pd.notna(v)}
                self.svc.create_supplier(clean_record)
                created += 1
            except Exception as e:
                errors.append({"row": record.get("name", "unknown"), "error": str(e)})

        return {"created": created, "errors": errors, "total": len(records)}

    def import_inventory(self, df: pd.DataFrame) -> dict:
        """
        Bulk import/update inventory levels.
        Matches by part_number to find the material_id.
        """
        materials = self.svc.get_materials()
        part_to_id = {m["part_number"]: m["id"] for m in materials}

        records = df.to_dict(orient="records")
        updated = 0
        errors = []

        for record in records:
            try:
                part_number = record.get("part_number")
                if part_number not in part_to_id:
                    errors.append({"row": part_number, "error": "Material not found"})
                    continue

                material_id = part_to_id[part_number]
                inv_data = {
                    "material_id": material_id,
                    "current_stock": float(record["current_stock"]),
                    "warehouse": record.get("warehouse", "main"),
                    "reserved_stock": float(record.get("reserved_stock", 0)),
                }

                # Upsert: check if inventory record exists
                existing = self.svc.get_inventory_item(material_id, inv_data["warehouse"])
                if existing:
                    self.svc.update_inventory(existing["id"], inv_data)
                else:
                    self.svc.client.table("inventory").insert(inv_data).execute()
                updated += 1
            except Exception as e:
                errors.append({"row": record.get("part_number", "unknown"), "error": str(e)})

        return {"updated": updated, "errors": errors, "total": len(records)}
