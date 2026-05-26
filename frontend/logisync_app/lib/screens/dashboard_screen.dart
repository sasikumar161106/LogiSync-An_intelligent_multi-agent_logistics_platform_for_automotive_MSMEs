import 'package:flutter/material.dart';
import 'package:logisync_app/config/theme.dart';
import 'package:logisync_app/widgets/kpi_card.dart';
import 'package:logisync_app/widgets/alert_ticker.dart';
import 'package:logisync_app/widgets/inventory_chart.dart';
import 'package:logisync_app/widgets/port_status_card.dart';
import 'package:logisync_app/services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Demo data (works without backend connection)
  final Map<String, dynamic> _summary = {
    'total_inventory_value_inr': 2847500.0,
    'materials_at_risk': 4,
    'active_shipments': 3,
    'delayed_shipments': 1,
    'pending_alerts': 2,
    'critical_alerts': 2,
    'production_efficiency_pct': 87.5,
    'total_suppliers': 5,
    'ai_savings_this_month_inr': 595000.0,
    'last_agent_run': '2026-05-26T10:30:00Z',
  };

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final api = ApiService();
      final data = await api.getDashboardSummary();
      if (mounted) {
        setState(() {
          _summary.addAll(data);
        });
      }
    } catch (_) {
      // Use demo data if backend not available
    }
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(child: _buildHeader()),
          // KPI Cards
          SliverToBoxAdapter(child: _buildKPIGrid()),
          // Charts & Widgets Row
          SliverToBoxAdapter(child: _buildChartsRow()),
          // Alert Ticker
          SliverToBoxAdapter(child: _buildAlertSection()),
          // Port Status
          SliverToBoxAdapter(child: _buildPortSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Agentic Control Tower',
                style: TextStyle(
                  color: LogiSyncTheme.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Real-time supply chain intelligence • Chennai',
                style: TextStyle(
                  color: LogiSyncTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Spacer(),
          _buildAgentStatusChip(),
        ],
      ),
    );
  }

  Widget _buildAgentStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: LogiSyncTheme.emeraldLight,
        borderRadius: LogiSyncTheme.radiusFull,
        border: Border.all(color: LogiSyncTheme.emerald.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulsingDot(color: LogiSyncTheme.emerald),
          const SizedBox(width: 8),
          Text(
            'AI Monitoring Active',
            style: TextStyle(
              color: LogiSyncTheme.emerald,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPIGrid() {
    final kpis = [
      KPIData(
        title: 'Inventory Value',
        value: '₹${_formatLakhs(_summary['total_inventory_value_inr'])}',
        subtitle: '${_summary['materials_at_risk']} materials at risk',
        icon: Icons.inventory_2_rounded,
        color: LogiSyncTheme.primary,
        trend: TrendDirection.stable,
      ),
      KPIData(
        title: 'Active Shipments',
        value: '${_summary['active_shipments']}',
        subtitle: '${_summary['delayed_shipments']} delayed',
        icon: Icons.local_shipping_rounded,
        color: _summary['delayed_shipments'] > 0 ? LogiSyncTheme.amber : LogiSyncTheme.emerald,
        trend: _summary['delayed_shipments'] > 0 ? TrendDirection.down : TrendDirection.up,
      ),
      KPIData(
        title: 'Pending Alerts',
        value: '${_summary['pending_alerts']}',
        subtitle: '${_summary['critical_alerts']} critical',
        icon: Icons.notifications_active_rounded,
        color: _summary['critical_alerts'] > 0 ? LogiSyncTheme.rose : LogiSyncTheme.amber,
        trend: _summary['critical_alerts'] > 0 ? TrendDirection.down : TrendDirection.stable,
      ),
      KPIData(
        title: 'Production Efficiency',
        value: '${_summary['production_efficiency_pct']}%',
        subtitle: 'Target: 95%',
        icon: Icons.precision_manufacturing_rounded,
        color: LogiSyncTheme.accent,
        trend: TrendDirection.up,
      ),
      KPIData(
        title: 'AI Savings (Month)',
        value: '₹${_formatLakhs(_summary['ai_savings_this_month_inr'])}',
        subtitle: 'From optimized procurement',
        icon: Icons.savings_rounded,
        color: LogiSyncTheme.emerald,
        trend: TrendDirection.up,
      ),
      KPIData(
        title: 'Total Suppliers',
        value: '${_summary['total_suppliers']}',
        subtitle: '2 international, 3 local',
        icon: Icons.people_rounded,
        color: LogiSyncTheme.cyan,
        trend: TrendDirection.stable,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount = 3;
          if (constraints.maxWidth < 900) crossAxisCount = 2;
          if (constraints.maxWidth < 500) crossAxisCount = 1;

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.2,
            ),
            itemCount: kpis.length,
            itemBuilder: (context, index) {
              return KPICard(data: kpis[index], animationDelay: index * 100);
            },
          );
        },
      ),
    );
  }

  Widget _buildChartsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: InventoryChart()),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: _buildQuickActions()),
              ],
            );
          }
          return Column(
            children: [
              InventoryChart(),
              const SizedBox(height: 16),
              _buildQuickActions(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: LogiSyncTheme.solidCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              color: LogiSyncTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _QuickActionButton(
            icon: Icons.smart_toy_rounded,
            label: 'Run AI Monitor',
            color: LogiSyncTheme.primary,
            onTap: () => Navigator.pushReplacementNamed(context, '/agents'),
          ),
          const SizedBox(height: 10),
          _QuickActionButton(
            icon: Icons.upload_file_rounded,
            label: 'Import Excel Data',
            color: LogiSyncTheme.accent,
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _QuickActionButton(
            icon: Icons.add_shopping_cart_rounded,
            label: 'New Purchase Order',
            color: LogiSyncTheme.emerald,
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _QuickActionButton(
            icon: Icons.notifications_rounded,
            label: 'View Pending Alerts',
            color: LogiSyncTheme.rose,
            onTap: () => Navigator.pushReplacementNamed(context, '/alerts'),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertSection() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: AlertTicker(),
    );
  }

  Widget _buildPortSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Port Status',
            style: TextStyle(
              color: LogiSyncTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return Row(
                  children: [
                    Expanded(
                      child: PortStatusCard(
                        portName: 'Chennai Port',
                        congestion: 'moderate',
                        delayHours: 12.0,
                        vesselsWaiting: 8,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: PortStatusCard(
                        portName: 'Ennore (Kamarajar) Port',
                        congestion: 'high',
                        delayHours: 48.0,
                        vesselsWaiting: 14,
                      ),
                    ),
                  ],
                );
              }
              return Column(
                children: [
                  PortStatusCard(
                    portName: 'Chennai Port',
                    congestion: 'moderate',
                    delayHours: 12.0,
                    vesselsWaiting: 8,
                  ),
                  const SizedBox(height: 12),
                  PortStatusCard(
                    portName: 'Ennore (Kamarajar) Port',
                    congestion: 'high',
                    delayHours: 48.0,
                    vesselsWaiting: 14,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatLakhs(dynamic value) {
    double n = 0;
    if (value is int) {
      n = value.toDouble();
    } else if (value is double) {
      n = value;
    } else if (value is String) {
      n = double.tryParse(value) ?? 0;
    }
    
    if (n >= 100000) {
      return '${(n / 100000).toStringAsFixed(1)}L';
    } else if (n >= 1000) {
      return '${(n / 1000).toStringAsFixed(1)}K';
    }
    return n.toStringAsFixed(0);
  }
}

// ── QUICK ACTION BUTTON ──────────────────────────────────

class _QuickActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  State<_QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<_QuickActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _isHovered
                ? widget.color.withValues(alpha: 0.1)
                : LogiSyncTheme.surfaceLight,
            borderRadius: LogiSyncTheme.radiusMd,
            border: Border.all(
              color: _isHovered
                  ? widget.color.withValues(alpha: 0.3)
                  : LogiSyncTheme.border,
            ),
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: widget.color, size: 20),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: TextStyle(
                  color: _isHovered ? widget.color : LogiSyncTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                color: _isHovered ? widget.color : LogiSyncTheme.textMuted,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── PULSING DOT ──────────────────────────────────────────

class _PulsingDot extends StatefulWidget {
  final Color color;
  const _PulsingDot({required this.color});

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.15 + _controller.value * 0.2),
                blurRadius: 4 + _controller.value * 4,
              ),
            ],
          ),
        );
      },
    );
  }
}
