# 🚀 LogiSync — Agentic Control Tower

<p align="center">
  <strong>An intelligent, multi-agent logistics platform for automotive MSMEs</strong>
</p>

LogiSync AI continuously monitors supply chain data, predicts shortages, and autonomously drafts resolution strategies — all with human-in-the-loop approval for high-stakes decisions.

## 🧠 Architecture

| Component | Technology | Purpose |
|-----------|------------|---------|
| **LLM / Brain** | Google Gemini 1.5 Flash | 1M token context, function-calling |
| **Agent Framework** | CrewAI (Python) | Multi-agent orchestration |
| **Backend API** | FastAPI (Python) | REST API bridge |
| **Database** | Supabase (PostgreSQL) | Real-time data sync |
| **Frontend** | Flutter (Web + Mobile) | Cross-platform dashboard |

## 🤖 AI Agents

| Agent | Role |
|-------|------|
| **LogisticsWatcher** | Monitors Chennai & Ennore ports, weather, traffic |
| **InventoryAnalyst** | Analyzes stock levels, predicts shortages |
| **ProcurementOptimizer** | Finds backup suppliers, drafts purchase orders |
| **ScheduleAdjuster** | Recalculates production schedules |

## 📁 Project Structure

```
LogiSync/
├── backend/
│   ├── app/
│   │   ├── main.py              # FastAPI entry point
│   │   ├── config.py            # Environment config
│   │   ├── dependencies.py      # Supabase client
│   │   ├── models/              # Pydantic data models
│   │   ├── routers/             # API endpoints
│   │   ├── services/            # Business logic
│   │   └── crews/               # CrewAI agents & tools
│   │       ├── config/
│   │       │   ├── agents.yaml  # Agent definitions
│   │       │   └── tasks.yaml   # Task definitions
│   │       ├── crew.py          # Orchestration
│   │       └── tools/           # Agent tools
│   ├── supabase_schema.sql      # Database schema
│   ├── seed_data.py             # Demo data
│   ├── requirements.txt
│   └── run.py
├── frontend/
│   └── logisync_app/            # Flutter project
│       └── lib/
│           ├── main.dart
│           ├── config/          # Theme, routes
│           ├── screens/         # All app screens
│           ├── widgets/         # Reusable components
│           └── services/        # API client
└── README.md
```

## 🚀 Quick Start

### 1. Backend Setup

```bash
cd backend

# Create virtual environment
python -m venv venv
venv\Scripts\activate  # Windows
# source venv/bin/activate  # Mac/Linux

# Install dependencies
pip install -r requirements.txt

# Configure environment
copy .env.example .env
# Edit .env with your Supabase URL, key, and Gemini API key

# Run the schema in Supabase SQL Editor
# (paste supabase_schema.sql)

# Seed demo data
python seed_data.py

# Start the server
python run.py
# → API at http://localhost:8000
# → Swagger docs at http://localhost:8000/docs
```

### 2. Frontend Setup

```bash
cd frontend/logisync_app

# Get dependencies
flutter pub get

# Run on web
flutter run -d chrome

# Run on Android
flutter run -d android
```

## 📊 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/dashboard/summary` | KPI dashboard data |
| GET | `/api/dashboard/inventory-health` | Stock levels with risk |
| GET | `/api/alerts/pending` | Pending AI alerts |
| POST | `/api/alerts/{id}/approve` | Approve AI action |
| POST | `/api/alerts/{id}/reject` | Reject with reason |
| POST | `/api/agents/run` | Trigger AI monitoring |
| GET | `/api/agents/history` | Agent run history |
| POST | `/api/imports/upload` | Excel/CSV import |

## 🔑 Environment Variables

| Variable | Description |
|----------|-------------|
| `SUPABASE_URL` | Your Supabase project URL |
| `SUPABASE_KEY` | Supabase anon/public key |
| `SUPABASE_SERVICE_KEY` | Supabase service role key |
| `GEMINI_API_KEY` | Google Gemini API key |

## 📋 License

MIT License — Built for automotive MSMEs in Chennai, India.
