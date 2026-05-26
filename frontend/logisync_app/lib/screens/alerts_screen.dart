import 'package:flutter/material.dart';
import 'package:logisync_app/config/theme.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  String _filter = 'pending';

  final List<Map<String, dynamic>> _alerts = [
    {
      'id': '1',
      'alert_type': 'shipment_delayed',
      'severity': 'critical',
      'status': 'pending',
      'title': 'Ennore Port delayed by 48 hours — Steel shipment stuck',
      'description': 'Shipment SHP-2026-0451 from Nippon Steel Japan carrying 5,000 kg of Mild Steel Sheet 3mm is delayed by 48 hours at Ennore Port outer anchorage. Port congestion level is HIGH with 12 vessels waiting.',
      'recommended_action': 'Approve emergency order of 2,000 kg Mild Steel Sheet 3mm from Tata Steel India (lead time: 12 days, ₹72/kg). Total cost: ₹1,44,000.',
      'estimated_cost_inr': 144000,
      'estimated_savings_inr': 380000,
      'affected_materials': ['STL-MS-3MM'],
      'created_at': '2026-05-26T08:30:00Z',
    },
    {
      'id': '2',
      'alert_type': 'shortage_predicted',
      'severity': 'urgent',
      'status': 'pending',
      'title': 'Cylinder Head Gaskets will run out in 2.1 days',
      'description': 'Critical shortage predicted for GSK-CYL-001. Current stock: 15 units. Minimum level: 100 units. Average daily consumption: 14.2 units/day. Stockout in approximately 1.1 days.',
      'recommended_action': 'Approve ₹50,000 emergency order from Chennai Auto Parts. Order 250 units at ₹1,250/unit. Lead time: 2 days.',
      'estimated_cost_inr': 50000,
      'estimated_savings_inr': 215000,
      'affected_materials': ['GSK-CYL-001'],
      'created_at': '2026-05-26T09:15:00Z',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == 'all'
        ? _alerts
        : _alerts.where((a) => a['status'] == _filter).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverToBoxAdapter(child: _buildFilters()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _AlertCard(
                alert: filtered[index],
                onApprove: () => _handleAction(filtered[index]['id'], 'approved'),
                onReject: () => _handleAction(filtered[index]['id'], 'rejected'),
              ),
              childCount: filtered.length,
            ),
          ),
        ),
      ],
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
                'Smart Alerts',
                style: TextStyle(
                  color: LogiSyncTheme.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'AI-generated alerts requiring your decision',
                style: TextStyle(
                  color: LogiSyncTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final filters = ['pending', 'approved', 'rejected', 'all'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      child: Row(
        children: filters.map((f) {
          final isActive = _filter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? LogiSyncTheme.primary.withValues(alpha: 0.2)
                      : LogiSyncTheme.surfaceLight,
                  borderRadius: LogiSyncTheme.radiusFull,
                  border: Border.all(
                    color: isActive
                        ? LogiSyncTheme.primary
                        : LogiSyncTheme.border.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  f[0].toUpperCase() + f.substring(1),
                  style: TextStyle(
                    color: isActive ? LogiSyncTheme.primary : LogiSyncTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _handleAction(String alertId, String action) {
    setState(() {
      final alert = _alerts.firstWhere((a) => a['id'] == alertId);
      alert['status'] = action;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Alert ${action == 'approved' ? 'approved ✅' : 'rejected ❌'}'),
        backgroundColor: action == 'approved' ? LogiSyncTheme.emerald : LogiSyncTheme.rose,
      ),
    );
  }
}

class _AlertCard extends StatefulWidget {
  final Map<String, dynamic> alert;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _AlertCard({
    required this.alert,
    required this.onApprove,
    required this.onReject,
  });

  @override
  State<_AlertCard> createState() => _AlertCardState();
}

class _AlertCardState extends State<_AlertCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final severity = widget.alert['severity'] as String;
    final status = widget.alert['status'] as String;

    final Color severityColor;
    switch (severity) {
      case 'urgent':
        severityColor = LogiSyncTheme.rose;
        break;
      case 'critical':
        severityColor = LogiSyncTheme.amber;
        break;
      default:
        severityColor = LogiSyncTheme.primary;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: LogiSyncTheme.cardBg,
        borderRadius: LogiSyncTheme.radiusLg,
        border: Border.all(
          color: status == 'pending'
              ? severityColor.withValues(alpha: 0.5)
              : LogiSyncTheme.border,
        ),
        boxShadow: LogiSyncTheme.cardShadow,
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: LogiSyncTheme.radiusLg,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: severityColor.withValues(alpha: 0.15),
                      borderRadius: LogiSyncTheme.radiusMd,
                    ),
                    child: Icon(
                      severity == 'urgent' ? Icons.error_rounded : Icons.warning_rounded,
                      color: severityColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: severityColor.withValues(alpha: 0.2),
                                borderRadius: LogiSyncTheme.radiusFull,
                              ),
                              child: Text(
                                severity.toUpperCase(),
                                style: TextStyle(
                                  color: severityColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: LogiSyncTheme.surfaceLight,
                                borderRadius: LogiSyncTheme.radiusFull,
                              ),
                              child: Text(
                                widget.alert['alert_type'].toString().replaceAll('_', ' ').toUpperCase(),
                                style: TextStyle(
                                  color: LogiSyncTheme.textMuted,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.alert['title'],
                          style: TextStyle(
                            color: LogiSyncTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _MetricChip(
                              icon: Icons.attach_money_rounded,
                              label: 'Cost: ₹${_formatNumber(widget.alert['estimated_cost_inr'])}',
                              color: LogiSyncTheme.amber,
                            ),
                            const SizedBox(width: 8),
                            _MetricChip(
                              icon: Icons.savings_rounded,
                              label: 'Saves: ₹${_formatNumber(widget.alert['estimated_savings_inr'])}',
                              color: LogiSyncTheme.emerald,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                    color: LogiSyncTheme.textMuted,
                  ),
                ],
              ),
            ),
          ),

          // Expanded details
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: LogiSyncTheme.divider),
                  const SizedBox(height: 12),
                  Text(
                    'Analysis',
                    style: TextStyle(
                      color: LogiSyncTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.alert['description'],
                    style: TextStyle(
                      color: LogiSyncTheme.textSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: LogiSyncTheme.primary.withValues(alpha: 0.08),
                      borderRadius: LogiSyncTheme.radiusMd,
                      border: Border.all(color: LogiSyncTheme.primary.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.smart_toy_rounded, color: LogiSyncTheme.primary, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'AI Recommendation',
                              style: TextStyle(
                                color: LogiSyncTheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.alert['recommended_action'],
                          style: TextStyle(
                            color: LogiSyncTheme.textPrimary,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (status == 'pending') ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: widget.onApprove,
                            icon: const Icon(Icons.check_rounded, size: 18),
                            label: const Text('Approve Action'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: LogiSyncTheme.emerald,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: widget.onReject,
                            icon: const Icon(Icons.close_rounded, size: 18),
                            label: const Text('Reject'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: LogiSyncTheme.rose,
                              side: BorderSide(color: LogiSyncTheme.rose.withValues(alpha: 0.5)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }

  String _formatNumber(dynamic value) {
    double n = 0;
    if (value is int) {
      n = value.toDouble();
    } else if (value is double) {
      n = value;
    } else if (value is String) {
      n = double.tryParse(value) ?? 0;
    }
    
    if (n >= 100000) return '${(n / 100000).toStringAsFixed(1)}L';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
    return n.toStringAsFixed(0);
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetricChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: LogiSyncTheme.radiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
