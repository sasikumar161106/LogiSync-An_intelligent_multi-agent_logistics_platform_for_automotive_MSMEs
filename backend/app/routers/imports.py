"""
Data Import API Router
Handles Excel/CSV file uploads for bulk data import.
"""

from fastapi import APIRouter, UploadFile, File, HTTPException, Query
from app.services.import_svc import ImportService

router = APIRouter()


@router.post("/upload")
async def upload_file(
    file: UploadFile = File(...),
    table: str = Query(..., description="Target table: materials, suppliers, inventory, consumption_logs"),
):
    """
    Upload an Excel (.xlsx) or CSV (.csv) file to import data.
    
    Supported tables:
    - materials: Requires columns: part_number, name, category
    - suppliers: Requires columns: name, supplier_type, location, lead_time_days
    - inventory: Requires columns: part_number, current_stock
    - consumption_logs: Requires columns: part_number, quantity_consumed, consumed_date
    """
    if not file.filename:
        raise HTTPException(status_code=400, detail="No file provided")

    if not file.filename.endswith((".csv", ".xlsx", ".xls")):
        raise HTTPException(
            status_code=400,
            detail="Unsupported file format. Use .csv, .xlsx, or .xls"
        )

    import_svc = ImportService()

    # Read file content
    content = await file.read()

    # Parse file
    try:
        df = import_svc.parse_file(content, file.filename)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Failed to parse file: {str(e)}")

    # Validate columns
    validation = import_svc.validate_columns(df, table)
    if not validation["valid"]:
        raise HTTPException(status_code=400, detail=validation)

    # Import data based on table type
    import_map = {
        "materials": import_svc.import_materials,
        "suppliers": import_svc.import_suppliers,
        "inventory": import_svc.import_inventory,
    }

    importer = import_map.get(table)
    if not importer:
        raise HTTPException(status_code=400, detail=f"Import not supported for table: {table}")

    result = importer(df)

    return {
        "filename": file.filename,
        "table": table,
        "rows_processed": result.get("total", 0),
        "rows_imported": result.get("created", result.get("updated", 0)),
        "errors": result.get("errors", []),
    }


@router.get("/template/{table_name}")
async def get_import_template(table_name: str):
    """Get the required columns and format for importing data into a table."""
    import_svc = ImportService()

    if table_name not in import_svc.SUPPORTED_TABLES:
        raise HTTPException(
            status_code=404,
            detail=f"No template for table: {table_name}. "
                   f"Supported: {list(import_svc.SUPPORTED_TABLES.keys())}"
        )

    config = import_svc.SUPPORTED_TABLES[table_name]

    return {
        "table": table_name,
        "required_columns": config["required_columns"],
        "optional_columns": config["optional_columns"],
        "supported_formats": [".csv", ".xlsx", ".xls"],
    }
