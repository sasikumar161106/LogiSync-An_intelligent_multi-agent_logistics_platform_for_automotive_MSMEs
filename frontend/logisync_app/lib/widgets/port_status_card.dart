import 'package:flutter/material.dart';
import 'package:logisync_app/config/theme.dart';

/// Port status card showing congestion, delays, and vessel count.
class PortStatusCard extends StatelessWidget {
  final String portName;
  final String congestion;
  final double delayHours;
  final int vesselsWaiting;

  const PortStatusCard({
    super.key,
    required this.portName,
    required this.congestion,
    required this.delayHours,
    required this.vesselsWaiting,
  });

  @override
  Widget build(BuildContext context) {
    final Color statusColor;
    final IconData statusIcon;

    switch (congestion) {
      case 'low':
        statusColor = LogiSyncTheme.emerald;
        statusIcon = Icons.check_circle_rounded;
        break;
      case 'moderate':
        statusColor = LogiSyncTheme.amber;
        statusIcon = Icons.warning_rounded;
        break;
      case 'high':
        statusColor = LogiSyncTheme.rose;
        statusIcon = Icons.error_rounded;
        break;
      case 'severe':
        statusColor = LogiSyncTheme.rose;
        statusIcon = Icons.dangerous_rounded;
        break;
      default:
        statusColor = LogiSyncTheme.textMuted;
        statusIcon = Icons.help_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: LogiSyncTheme.cardBg,
        borderRadius: LogiSyncTheme.radiusLg,
        border: Border.all(color: LogiSyncTheme.border),
        boxShadow: LogiSyncTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.directions_boat_rounded,
                  color: LogiSyncTheme.textSecondary, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  portName,
                  style: TextStyle(
                    color: LogiSyncTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: LogiSyncTheme.radiusFull,
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 12),
                    const SizedBox(width: 4),
                    Text(
                      congestion.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _PortMetric(
                label: 'Avg Delay',
                value: '${delayHours}h',
                color: delayHours > 24 ? LogiSyncTheme.rose : LogiSyncTheme.amber,
              ),
              const SizedBox(width: 24),
              _PortMetric(
                label: 'Vessels',
                value: '$vesselsWaiting',
                color: LogiSyncTheme.primary,
              ),
              const SizedBox(width: 24),
              _PortMetric(
                label: 'Risk',
                value: delayHours > 24 ? 'HIGH' : delayHours > 8 ? 'MED' : 'LOW',
                color: delayHours > 24 ? LogiSyncTheme.rose : delayHours > 8 ? LogiSyncTheme.amber : LogiSyncTheme.emerald,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PortMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _PortMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: LogiSyncTheme.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
