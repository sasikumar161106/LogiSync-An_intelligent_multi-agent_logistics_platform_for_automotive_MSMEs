import 'package:flutter/material.dart';
import 'package:logisync_app/config/theme.dart';

/// Live scrolling alert ticker showing the latest AI-generated alerts.
class AlertTicker extends StatefulWidget {
  const AlertTicker({super.key});

  @override
  State<AlertTicker> createState() => _AlertTickerState();
}

class _AlertTickerState extends State<AlertTicker> {
  // Demo alerts (works without backend)
  final List<Map<String, dynamic>> _alerts = [
    {
      'title': 'Ennore Port delayed by 48 hours — Steel shipment stuck',
      'severity': 'critical',
      'type': 'shipment_delayed',
      'cost': '₹1,44,000',
      'time': '2 hours ago',
    },
    {
      'title': 'Cylinder Head Gaskets will run out in 2.1 days',
      'severity': 'urgent',
      'type': 'shortage_predicted',
      'cost': '₹50,000',
      'time': '45 min ago',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: LogiSyncTheme.solidCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_active_rounded,
                  color: LogiSyncTheme.rose, size: 20),
              const SizedBox(width: 8),
              Text(
                'Smart Alerts',
                style: TextStyle(
                  color: LogiSyncTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: LogiSyncTheme.rose.withValues(alpha: 0.2),
                  borderRadius: LogiSyncTheme.radiusFull,
                ),
                child: Text(
                  '${_alerts.length} pending',
                  style: TextStyle(
                    color: LogiSyncTheme.rose,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/alerts');
                },
                child: Text(
                  'View All →',
                  style: TextStyle(
                    color: LogiSyncTheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ..._alerts.map((alert) => _AlertTickerItem(alert: alert)),
        ],
      ),
    );
  }
}

class _AlertTickerItem extends StatefulWidget {
  final Map<String, dynamic> alert;
  const _AlertTickerItem({required this.alert});

  @override
  State<_AlertTickerItem> createState() => _AlertTickerItemState();
}

class _AlertTickerItemState extends State<_AlertTickerItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final severity = widget.alert['severity'] as String;
    final Color severityColor;
    final IconData severityIcon;

    switch (severity) {
      case 'urgent':
        severityColor = LogiSyncTheme.rose;
        severityIcon = Icons.error_rounded;
        break;
      case 'critical':
        severityColor = LogiSyncTheme.amber;
        severityIcon = Icons.warning_rounded;
        break;
      default:
        severityColor = LogiSyncTheme.primary;
        severityIcon = Icons.info_rounded;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _isHovered
              ? severityColor.withValues(alpha: 0.05)
              : LogiSyncTheme.surface,
          borderRadius: LogiSyncTheme.radiusMd,
          border: Border.all(
            color: _isHovered
                ? severityColor.withValues(alpha: 0.3)
                : LogiSyncTheme.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: severityColor.withValues(alpha: 0.15),
                borderRadius: LogiSyncTheme.radiusSm,
              ),
              child: Icon(severityIcon, color: severityColor, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.alert['title'],
                    style: TextStyle(
                      color: LogiSyncTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: severityColor.withValues(alpha: 0.2),
                          borderRadius: LogiSyncTheme.radiusFull,
                        ),
                        child: Text(
                          severity.toUpperCase(),
                          style: TextStyle(
                            color: severityColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Est. cost: ${widget.alert['cost']}',
                        style: TextStyle(
                          color: LogiSyncTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.alert['time'],
                        style: TextStyle(
                          color: LogiSyncTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MiniButton(
                  label: 'Approve',
                  color: LogiSyncTheme.emerald,
                  onTap: () {},
                ),
                const SizedBox(width: 6),
                _MiniButton(
                  label: 'Reject',
                  color: LogiSyncTheme.rose,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MiniButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: LogiSyncTheme.radiusSm,
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
