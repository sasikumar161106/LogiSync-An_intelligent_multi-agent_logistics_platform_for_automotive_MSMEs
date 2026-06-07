# 🚀 LogiSync — Agentic Control Tower

<p align="center">
  <strong>An intelligent, multi-agent logistics platform for automotive MSMEs</strong>
</p>

LogiSync AI is an advanced, autonomous control tower designed specifically for automotive MSMEs. It continuously monitors supply chain data, predicts shortages, and proactively drafts resolution strategies. With a human-in-the-loop design, LogiSync ensures high-stakes decisions are safely approved while eliminating the manual overhead of supply chain management.

---

## 🌟 Key Features

- **Real-Time Supply Chain Monitoring:** Tracks data across multiple sources, including ports (e.g., Chennai, Ennore), weather, and live traffic.
- **Predictive Inventory Analytics:** Anticipates material shortages before they impact production, based on consumption rates and lead times.
- **Autonomous Resolution Drafting:** Automatically creates backup plans such as alternative supplier sourcing and drafted purchase orders.
- **Dynamic Schedule Adjustments:** Recalculates production schedules in real-time when supply chain disruptions occur.
- **Human-in-the-Loop Approval:** Ensures safety and accuracy by requiring manager approval on all high-impact AI recommendations via WhatsApp or the Dashboard.
- **Cross-Platform Dashboard:** A beautiful, responsive Flutter frontend available on Web, iOS, and Android.

---

## 🧠 Architecture & Tech Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| **LLM / Brain** | Google Gemini 1.5 Flash | 1M token context, function-calling & reasoning |
| **Agent Framework** | CrewAI (Python) | Multi-agent orchestration and delegation |
| **Backend API** | FastAPI (Python) | High-performance async REST API bridge |
| **Database** | Supabase (PostgreSQL) | Real-time data sync and persistent storage |
| **Frontend** | Flutter (Dart) | Cross-platform dashboard & UI |

---

## 🤖 AI Agents

The core of LogiSync's intelligence lies in its multi-agent CrewAI orchestration. Each agent is highly specialized:

| Agent | Role & Responsibilities |
|-------|-------------------------|
| **LogisticsWatcher** | Monitors external factors (ports, weather, traffic delays) and flags potential delivery impacts. |
| **InventoryAnalyst** | Analyzes warehouse stock levels, maps them against production schedules, and predicts imminent shortages. |
| **ProcurementOptimizer** | Finds backup suppliers, compares pricing/lead times, and drafts emergency purchase orders. |
| **ScheduleAdjuster** | Recalculates factory production schedules to optimize throughput despite material delays. |

---

## 📁 Project Structure

```text
LogiSync/
├── backend/
│   ├── app/
│   │   ├── main.py              # FastAPI entry point
│   │   ├── config.py            # Environment configurations
│   │   ├── dependencies.py      # Supabase client & DI
│   │   ├── models/              # Pydantic data models
│   │   ├── routers/             # API endpoints
│   │   ├── services/            # Business logic (Notifications, etc.)
│   │   └── crews/               # CrewAI agents & tools
│   │       ├── config/
│   │       │   ├── agents.yaml  # Agent definitions
│   │       │   └── tasks.yaml   # Task definitions
│   │       ├── crew.py          # Orchestration logic
│   │       └── tools/           # Agent tools
│   ├── supabase_schema.sql      # Database schema
│   ├── seed_data.py             # Demo data populator
│   ├── requirements.txt         # Python dependencies
│   └── run.py                   # Server runner
├── frontend/
│   └── logisync_app/            # Flutter project
│       └── lib/
│           ├── main.dart        # Flutter entry point
│           ├── config/          # Theme, routing, constants
│           ├── screens/         # Dashboard & module screens
│           ├── widgets/         # Reusable UI components
│           └── services/        # API integration client
└── README.md
```

---

## 🚀 Setup & Installation

Follow these steps to get LogiSync running locally.

### 1. Backend Setup (FastAPI + CrewAI)

```bash
cd backend

# Create a virtual environment
python -m venv venv

# Activate the virtual environment
# On Windows:
venv\Scripts\activate
# On Mac/Linux:
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Configure environment variables
cp .env.example .env
```

**Database Configuration:**
1. Create a Supabase project.
2. Run the SQL schema found in `supabase_schema.sql` in your Supabase SQL Editor.
3. Edit your `.env` file with your `SUPABASE_URL`, `SUPABASE_KEY`, and `GEMINI_API_KEY`.

```bash
# Seed demo data
python seed_data.py

# Start the development server
python run.py
```
*The API will be available at http://localhost:8000. Swagger UI docs at http://localhost:8000/docs.*

### 2. Frontend Setup (Flutter)

```bash
cd frontend/logisync_app

# Get Flutter dependencies
flutter pub get

# Run on Web (Chrome)
flutter run -d chrome

# Run on Mobile (Android)
flutter run -d android
```

---

## 📊 Core API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/dashboard/summary` | Fetches high-level KPI dashboard data |
| `GET` | `/api/dashboard/inventory-health` | Retrieves stock levels and shortage risk |
| `GET` | `/api/alerts/pending` | Fetches pending AI alerts needing approval |
| `POST` | `/api/alerts/{id}/approve` | Approves an AI-recommended action |
| `POST` | `/api/alerts/{id}/reject` | Rejects an action with feedback reasoning |
| `POST` | `/api/agents/run` | Triggers a manual AI supply chain sweep |
| `GET` | `/api/agents/history` | Fetches agent execution history |
| `POST` | `/api/imports/upload` | Uploads Excel/CSV for bulk data import |

---

## 🔑 Environment Variables

To run LogiSync successfully, you need the following keys in your backend `.env` file:

- `SUPABASE_URL`: Your Supabase project URL.
- `SUPABASE_KEY`: Supabase anon/public key.
- `SUPABASE_SERVICE_KEY`: Supabase service role key (for admin actions).
- `GEMINI_API_KEY`: Google Gemini API key for CrewAI LLM processing.
- `TWILIO_ACCOUNT_SID` & `TWILIO_AUTH_TOKEN`: For WhatsApp notifications (optional).

---

## 🤝 Contributing

Contributions are welcome! If you'd like to improve the platform, please:
1. Fork the repository.
2. Create a new branch for your feature (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

---

## 📋 License

Distributed under the MIT License. Built for automotive MSMEs in Chennai, India.
