import 'package:flutter/material.dart';
import 'package:logisync_app/config/theme.dart';

/// Inventory health chart showing stock status distribution.
class InventoryChart extends StatelessWidget {
  InventoryChart({super.key});

  // Demo data for chart bars
  final List<_BarData> _items = [
    _BarData('Brake Pad (F)', 0.30, 'critical'),
    _BarData('Bearing 6205', 0.50, 'low'),
    _BarData('Cyl. Gasket', 0.15, 'critical'),
    _BarData('Steel 3mm', 0.80, 'low'),
    _BarData('Oil Seal 55mm', 0.00, 'out_of_stock'),
    _BarData('Brake Pad (R)', 1.50, 'healthy'),
    _BarData('Bearing 6308', 2.00, 'healthy'),
    _BarData('Oil Gasket', 1.20, 'healthy'),
    _BarData('Shock Abs (R)', 0.20, 'critical'),
    _BarData('Clutch Plate', 0.40, 'low'),
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
              Text(
                'Inventory Health',
                style: TextStyle(
                  color: LogiSyncTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _LegendDot(color: LogiSyncTheme.emerald, label: 'Healthy'),
              const SizedBox(width: 12),
              _LegendDot(color: LogiSyncTheme.amber, label: 'Low'),
              const SizedBox(width: 12),
              _LegendDot(color: LogiSyncTheme.rose, label: 'Critical'),
            ],
          ),
          const SizedBox(height: 20),
          ..._items.map((item) => _BarRow(data: item)),
        ],
      ),
    );
  }
}

class _BarData {
  final String name;
  final double ratio; // stock / min_level (>1 = healthy, <1 = at risk)
  final String status;

  _BarData(this.name, this.ratio, this.status);
}

class _BarRow extends StatefulWidget {
  final _BarData data;
  const _BarRow({required this.data});

  @override
  State<_BarRow> createState() => _BarRowState();
}

class _BarRowState extends State<_BarRow> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _widthAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color barColor;
    switch (widget.data.status) {
      case 'healthy':
        barColor = LogiSyncTheme.emerald;
        break;
      case 'low':
        barColor = LogiSyncTheme.amber;
        break;
      case 'critical':
        barColor = LogiSyncTheme.rose;
        break;
      case 'out_of_stock':
        barColor = LogiSyncTheme.textMuted;
        break;
      default:
        barColor = LogiSyncTheme.primary;
    }

    final percentage = (widget.data.ratio.clamp(0, 2.5) / 2.5);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              widget.data.name,
              style: TextStyle(
                color: LogiSyncTheme.textSecondary,
                fontSize: 11,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AnimatedBuilder(
              animation: _widthAnimation,
              builder: (context, child) {
                return Stack(
                  children: [
                    Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: LogiSyncTheme.surfaceLight,
                        borderRadius: LogiSyncTheme.radiusFull,
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: percentage * _widthAnimation.value,
                      child: Container(
                        height: 16,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              barColor.withValues(alpha: 0.8),
                              barColor,
                            ],
                          ),
                          borderRadius: LogiSyncTheme.radiusFull,
                          boxShadow: [
                            BoxShadow(
                              color: barColor.withValues(alpha: 0.3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 50,
            child: Text(
              '${(widget.data.ratio * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: barColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(color: LogiSyncTheme.textMuted, fontSize: 10),
        ),
      ],
    );
  }
}
