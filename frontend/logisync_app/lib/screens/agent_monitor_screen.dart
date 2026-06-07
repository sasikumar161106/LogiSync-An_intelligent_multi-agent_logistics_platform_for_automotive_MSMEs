import 'package:flutter/material.dart';
import 'package:logisync_app/config/theme.dart';

import 'package:logisync_app/services/api_service.dart';

class AgentMonitorScreen extends StatefulWidget {
  const AgentMonitorScreen({super.key});

  @override
  State<AgentMonitorScreen> createState() => _AgentMonitorScreenState();
}

class _AgentMonitorScreenState extends State<AgentMonitorScreen> {
  bool _isRunning = false;
  List<dynamic> _history = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final api = ApiService();
      final data = await api.getAgentHistory();
      if (mounted) {
        setState(() {
          _history = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  final List<Map<String, dynamic>> _agents = [
    {
      'name': 'LogisticsWatcher',
      'role': 'Port & Logistics Monitor',
      'icon': Icons.directions_boat_rounded,
      'color': LogiSyncTheme.primary,
      'tools': ['Port Status', 'Weather API', 'Traffic'],
      'status': 'idle',
    },
    {
      'name': 'InventoryAnalyst',
      'role': 'Inventory Intelligence',
      'icon': Icons.analytics_rounded,
      'color': LogiSyncTheme.emerald,
      'tools': ['Stock Levels', 'Consumption Rates', 'Shortage Detection'],
      'status': 'idle',
    },
    {
      'name': 'ProcurementOptimizer',
      'role': 'Supplier & PO Specialist',
      'icon': Icons.shopping_cart_rounded,
      'color': LogiSyncTheme.accent,
      'tools': ['Supplier Search', 'Cost Comparison', 'PO Drafting'],
      'status': 'idle',
    },
    {
      'name': 'ScheduleAdjuster',
      'role': 'Production Scheduler',
      'icon': Icons.calendar_month_rounded,
      'color': LogiSyncTheme.amber,
      'tools': ['Schedule Analysis', 'Priority Reordering'],
      'status': 'idle',
    },
  ];

  // History fetched from backend

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI Agent Monitor',
                      style: TextStyle(color: LogiSyncTheme.textPrimary, fontSize: 26, fontWeight: FontWeight.w700)),
                    Text('Powered by Google Gemini 1.5 Flash + CrewAI',
                      style: TextStyle(color: LogiSyncTheme.textSecondary, fontSize: 14)),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _isRunning ? null : _triggerRun,
                  icon: _isRunning
                      ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.play_arrow_rounded, size: 20),
                  label: Text(_isRunning ? 'Running...' : 'Run Monitor'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LogiSyncTheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Agent Cards
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Text('Agent Crew',
              style: TextStyle(color: LogiSyncTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 400,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.8,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _AgentCard(agent: _agents[index], isRunning: _isRunning),
              childCount: _agents.length,
            ),
          ),
        ),

        // Run History
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Text('Run History',
              style: TextStyle(color: LogiSyncTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
          ),
        ),
        _isLoading
            ? const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            : _error != null
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text('Error loading history: $_error', style: TextStyle(color: LogiSyncTheme.rose)),
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _HistoryRow(run: _history[index] as Map<String, dynamic>),
                        childCount: _history.length,
                      ),
                    ),
                  ),
      ],
    );
  }

  Future<void> _triggerRun() async {
    setState(() => _isRunning = true);
    try {
      final api = ApiService();
      await api.triggerAgentRun();
      await _loadHistory();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('🤖 Agent monitoring cycle started'),
            backgroundColor: LogiSyncTheme.emerald,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to trigger run: $e'),
            backgroundColor: LogiSyncTheme.rose,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRunning = false);
      }
    }
  }
}

class _AgentCard extends StatelessWidget {
  final Map<String, dynamic> agent;
  final bool isRunning;
  const _AgentCard({required this.agent, required this.isRunning});

  @override
  Widget build(BuildContext context) {
    final color = agent['color'] as Color;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: LogiSyncTheme.cardBg,
        borderRadius: LogiSyncTheme.radiusLg,
        border: Border.all(
          color: isRunning ? color.withValues(alpha: 0.4) : LogiSyncTheme.border,
        ),
        boxShadow: isRunning
            ? [BoxShadow(color: color.withValues(alpha: 0.15), blurRadius: 16)]
            : LogiSyncTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: LogiSyncTheme.radiusMd,
                ),
                child: Icon(agent['icon'] as IconData, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(agent['name'], style: TextStyle(color: LogiSyncTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                    Text(agent['role'], style: TextStyle(color: LogiSyncTheme.textMuted, fontSize: 11)),
                  ],
                ),
              ),
              if (isRunning)
                SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: color),
                )
              else
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: LogiSyncTheme.emerald,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const Spacer(),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: (agent['tools'] as List<String>).map((tool) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: LogiSyncTheme.surfaceLight,
                borderRadius: LogiSyncTheme.radiusFull,
              ),
              child: Text(tool, style: TextStyle(color: LogiSyncTheme.textMuted, fontSize: 10)),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final Map<String, dynamic> run;
  const _HistoryRow({required this.run});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: LogiSyncTheme.cardBg,
        borderRadius: LogiSyncTheme.radiusMd,
      ),
      child: Row(
        children: [
          Icon(
            run['trigger_type'] == 'scheduled' ? Icons.schedule_rounded : Icons.play_circle_rounded,
            color: LogiSyncTheme.textMuted, size: 18,
          ),
          const SizedBox(width: 12),
          Text(run['started_at']?.toString().split('T').last.substring(0, 5) ?? '00:00', style: TextStyle(color: LogiSyncTheme.textSecondary, fontSize: 13)),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: LogiSyncTheme.emerald.withValues(alpha: 0.15),
              borderRadius: LogiSyncTheme.radiusFull,
            ),
            child: Text(run['status']?.toString().toUpperCase() ?? 'COMPLETED',
              style: TextStyle(color: LogiSyncTheme.emerald, fontSize: 9, fontWeight: FontWeight.w700)),
          ),
          const Spacer(),
          Text('${run['alerts_generated'] ?? 0} Alerts', style: TextStyle(color: LogiSyncTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(width: 16),
          Text('Done', style: TextStyle(color: LogiSyncTheme.textMuted, fontSize: 12)),
        ],
      ),
    );
  }
}
