-- ============================================================
-- LogiSync — Supabase PostgreSQL Schema
-- Agentic Control Tower for Automotive MSMEs
-- ============================================================
-- Run this in the Supabase SQL Editor to create all tables.
-- ============================================================

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================================
-- 1. SUPPLIERS
-- ============================================================
CREATE TABLE IF NOT EXISTS suppliers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    supplier_type TEXT NOT NULL CHECK (supplier_type IN ('local', 'domestic', 'international')),
    location TEXT NOT NULL,
    contact_person TEXT,
    phone TEXT,
    email TEXT,
    lead_time_days INTEGER NOT NULL DEFAULT 7,
    reliability_score NUMERIC(3,2) DEFAULT 0.80 CHECK (reliability_score >= 0 AND reliability_score <= 1),
    port_of_entry TEXT CHECK (port_of_entry IN ('chennai_port', 'ennore_port', NULL)),
    materials_supplied TEXT[] DEFAULT '{}',
    payment_terms TEXT,
    notes TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    total_orders INTEGER DEFAULT 0,
    on_time_delivery_rate NUMERIC(5,2) DEFAULT 0.00,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 2. MATERIALS
-- ============================================================
CREATE TABLE IF NOT EXISTS materials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    part_number TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    category TEXT NOT NULL CHECK (category IN ('raw_material', 'component', 'consumable', 'packaging')),
    unit TEXT DEFAULT 'pcs' CHECK (unit IN ('pcs', 'kg', 'litre', 'metre', 'set', 'box')),
    min_stock_level NUMERIC(12,2) DEFAULT 0,
    reorder_quantity NUMERIC(12,2) DEFAULT 0,
    unit_price NUMERIC(12,2) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 3. INVENTORY (Real-time enabled)
-- ============================================================
CREATE TABLE IF NOT EXISTS inventory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_id UUID NOT NULL REFERENCES materials(id) ON DELETE CASCADE,
    warehouse TEXT DEFAULT 'main',
    current_stock NUMERIC(12,2) NOT NULL DEFAULT 0,
    reserved_stock NUMERIC(12,2) DEFAULT 0,
    available_stock NUMERIC(12,2) GENERATED ALWAYS AS (current_stock - reserved_stock) STORED,
    stock_status TEXT DEFAULT 'healthy' CHECK (stock_status IN ('healthy', 'low', 'critical', 'out_of_stock')),
    days_until_stockout NUMERIC(8,1),
    last_updated TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(material_id, warehouse)
);

CREATE INDEX idx_inventory_material ON inventory(material_id);
CREATE INDEX idx_inventory_status ON inventory(stock_status);

-- ============================================================
-- 4. CONSUMPTION LOGS
-- ============================================================
CREATE TABLE IF NOT EXISTS consumption_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_id UUID NOT NULL REFERENCES materials(id) ON DELETE CASCADE,
    quantity_consumed NUMERIC(12,2) NOT NULL,
    consumed_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    production_order_ref TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_consumption_material ON consumption_logs(material_id);
CREATE INDEX idx_consumption_date ON consumption_logs(consumed_date);

-- ============================================================
-- 5. SHIPMENTS (Real-time enabled)
-- ============================================================
CREATE TABLE IF NOT EXISTS shipments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    shipment_ref TEXT UNIQUE NOT NULL,
    supplier_id UUID REFERENCES suppliers(id),
    purchase_order_id UUID,
    material_id UUID REFERENCES materials(id),
    quantity NUMERIC(12,2) NOT NULL,
    status TEXT DEFAULT 'ordered' CHECK (status IN (
        'ordered', 'in_transit', 'at_port', 'customs_clearance',
        'in_delivery', 'delivered', 'delayed', 'cancelled'
    )),
    port_of_entry TEXT CHECK (port_of_entry IN ('chennai_port', 'ennore_port', 'none')),
    vessel_name TEXT,
    container_id TEXT,
    origin TEXT NOT NULL,
    destination TEXT DEFAULT 'Chennai',
    estimated_departure TIMESTAMPTZ,
    estimated_arrival TIMESTAMPTZ NOT NULL,
    actual_arrival TIMESTAMPTZ,
    delay_hours NUMERIC(8,1) DEFAULT 0,
    delay_reason TEXT,
    current_location TEXT,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_shipments_status ON shipments(status);
CREATE INDEX idx_shipments_supplier ON shipments(supplier_id);
CREATE INDEX idx_shipments_material ON shipments(material_id);

-- ============================================================
-- 6. PURCHASE ORDERS
-- ============================================================
CREATE TABLE IF NOT EXISTS purchase_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    po_number TEXT UNIQUE NOT NULL,
    supplier_id UUID REFERENCES suppliers(id),
    material_id UUID REFERENCES materials(id),
    quantity NUMERIC(12,2) NOT NULL,
    unit_price_inr NUMERIC(12,2) NOT NULL,
    total_amount_inr NUMERIC(14,2) NOT NULL,
    expected_delivery DATE,
    status TEXT DEFAULT 'draft' CHECK (status IN (
        'draft', 'submitted', 'confirmed', 'received', 'cancelled'
    )),
    is_ai_generated BOOLEAN DEFAULT FALSE,
    alert_id UUID,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 7. PRODUCTION SCHEDULES
-- ============================================================
CREATE TABLE IF NOT EXISTS production_schedules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    schedule_ref TEXT UNIQUE NOT NULL,
    product_name TEXT NOT NULL,
    planned_date DATE NOT NULL,
    planned_quantity INTEGER NOT NULL,
    actual_quantity INTEGER DEFAULT 0,
    completion_percentage NUMERIC(5,2) DEFAULT 0,
    priority INTEGER DEFAULT 3 CHECK (priority >= 1 AND priority <= 5),
    status TEXT DEFAULT 'planned' CHECK (status IN (
        'planned', 'in_progress', 'completed', 'delayed', 'on_hold', 'cancelled'
    )),
    material_requirements JSONB DEFAULT '[]',
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_production_date ON production_schedules(planned_date);
CREATE INDEX idx_production_status ON production_schedules(status);

-- ============================================================
-- 8. ALERTS (Real-time enabled — core of human-in-the-loop)
-- ============================================================
CREATE TABLE IF NOT EXISTS alerts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    alert_type TEXT NOT NULL CHECK (alert_type IN (
        'shortage_predicted', 'shipment_delayed', 'port_congestion',
        'weather_risk', 'production_impact', 'supplier_issue',
        'reorder_suggested', 'schedule_change'
    )),
    severity TEXT NOT NULL CHECK (severity IN ('info', 'warning', 'critical', 'urgent')),
    status TEXT DEFAULT 'pending' CHECK (status IN (
        'pending', 'approved', 'rejected', 'modified', 'expired', 'auto_resolved'
    )),
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    recommended_action TEXT NOT NULL,
    estimated_cost_inr NUMERIC(14,2),
    estimated_savings_inr NUMERIC(14,2),
    affected_materials TEXT[] DEFAULT '{}',
    affected_shipments TEXT[] DEFAULT '{}',
    deadline TIMESTAMPTZ,
    agent_run_id UUID,
    metadata JSONB DEFAULT '{}',
    resolved_at TIMESTAMPTZ,
    resolved_by TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_alerts_status ON alerts(status);
CREATE INDEX idx_alerts_severity ON alerts(severity);
CREATE INDEX idx_alerts_type ON alerts(alert_type);

-- ============================================================
-- 9. PORT STATUS (Real-time enabled)
-- ============================================================
CREATE TABLE IF NOT EXISTS port_status (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    port_name TEXT UNIQUE NOT NULL CHECK (port_name IN ('chennai_port', 'ennore_port')),
    congestion_level TEXT DEFAULT 'low' CHECK (congestion_level IN ('low', 'moderate', 'high', 'severe')),
    avg_delay_hours NUMERIC(8,1) DEFAULT 0,
    vessels_waiting INTEGER DEFAULT 0,
    weather_impact TEXT,
    last_checked TIMESTAMPTZ DEFAULT NOW(),
    notes TEXT
);

-- ============================================================
-- 10. AGENT RUNS (Audit Log)
-- ============================================================
CREATE TABLE IF NOT EXISTS agent_runs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    trigger TEXT NOT NULL CHECK (trigger IN ('scheduled', 'manual', 'event')),
    status TEXT DEFAULT 'running' CHECK (status IN ('running', 'completed', 'failed')),
    started_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ,
    duration_seconds NUMERIC(10,2),
    agents_involved TEXT[] DEFAULT '{}',
    tasks_completed INTEGER DEFAULT 0,
    alerts_generated INTEGER DEFAULT 0,
    summary TEXT,
    error_message TEXT
);

CREATE INDEX idx_agent_runs_status ON agent_runs(status);

-- ============================================================
-- AUTO-UPDATE TRIGGERS
-- ============================================================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_suppliers_updated
    BEFORE UPDATE ON suppliers
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_materials_updated
    BEFORE UPDATE ON materials
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_shipments_updated
    BEFORE UPDATE ON shipments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_purchase_orders_updated
    BEFORE UPDATE ON purchase_orders
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_production_schedules_updated
    BEFORE UPDATE ON production_schedules
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_alerts_updated
    BEFORE UPDATE ON alerts
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- ============================================================
-- ENABLE REALTIME on key tables
-- (Run these in the Supabase Dashboard > Database > Replication)
-- ============================================================
-- ALTER PUBLICATION supabase_realtime ADD TABLE alerts;
-- ALTER PUBLICATION supabase_realtime ADD TABLE inventory;
-- ALTER PUBLICATION supabase_realtime ADD TABLE shipments;
-- ALTER PUBLICATION supabase_realtime ADD TABLE port_status;

-- ============================================================
-- INITIAL PORT STATUS DATA
-- ============================================================
INSERT INTO port_status (port_name, congestion_level, avg_delay_hours, vessels_waiting)
VALUES
    ('chennai_port', 'moderate', 12.0, 8),
    ('ennore_port', 'low', 4.0, 3)
ON CONFLICT (port_name) DO NOTHING;

-- ============================================================
-- Done! Your LogiSync database is ready.
-- ============================================================
