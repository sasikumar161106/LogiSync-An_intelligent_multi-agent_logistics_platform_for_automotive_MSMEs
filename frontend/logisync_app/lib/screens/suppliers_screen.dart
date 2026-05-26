import 'package:flutter/material.dart';
import 'package:logisync_app/config/theme.dart';

class SuppliersScreen extends StatelessWidget {
  const SuppliersScreen({super.key});

  static final List<Map<String, dynamic>> _suppliers = [
    {'name': 'Tata Steel India', 'type': 'domestic', 'location': 'Jamshedpur', 'lead': 12, 'reliability': 0.92, 'onTime': 91, 'orders': 145, 'port': 'Chennai Port'},
    {'name': 'Nippon Steel Japan', 'type': 'international', 'location': 'Tokyo, Japan', 'lead': 25, 'reliability': 0.95, 'onTime': 94, 'orders': 38, 'port': 'Ennore Port'},
    {'name': 'Chennai Auto Parts', 'type': 'local', 'location': 'Ambattur, Chennai', 'lead': 2, 'reliability': 0.78, 'onTime': 76, 'orders': 312, 'port': 'Local'},
    {'name': 'Sundaram Fasteners', 'type': 'local', 'location': 'Padi, Chennai', 'lead': 3, 'reliability': 0.88, 'onTime': 87, 'orders': 198, 'port': 'Local'},
    {'name': 'Bosch Rexroth Germany', 'type': 'international', 'location': 'Stuttgart, Germany', 'lead': 30, 'reliability': 0.97, 'onTime': 96, 'orders': 22, 'port': 'Chennai Port'},
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Text('Supplier Network',
              style: TextStyle(color: LogiSyncTheme.textPrimary, fontSize: 26, fontWeight: FontWeight.w700)),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _SupplierCard(supplier: _suppliers[index]),
              childCount: _suppliers.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _SupplierCard extends StatelessWidget {
  final Map<String, dynamic> supplier;
  const _SupplierCard({required this.supplier});

  @override
  Widget build(BuildContext context) {
    final type = supplier['type'] as String;
    final reliability = (supplier['reliability'] as double) * 100;
    final Color typeColor;
    final IconData typeIcon;
    switch (type) {
      case 'international': typeColor = LogiSyncTheme.accent; typeIcon = Icons.public_rounded; break;
      case 'domestic': typeColor = LogiSyncTheme.primary; typeIcon = Icons.flag_rounded; break;
      default: typeColor = LogiSyncTheme.emerald; typeIcon = Icons.location_city_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LogiSyncTheme.cardGradient,
        borderRadius: LogiSyncTheme.radiusLg,
        border: Border.all(color: LogiSyncTheme.border.withValues(alpha: 0.2)),
        boxShadow: LogiSyncTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.15),
              borderRadius: LogiSyncTheme.radiusMd,
            ),
            child: Icon(typeIcon, color: typeColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(supplier['name'], style: TextStyle(color: LogiSyncTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: typeColor.withValues(alpha: 0.15),
                        borderRadius: LogiSyncTheme.radiusFull,
                      ),
                      child: Text(type.toUpperCase(), style: TextStyle(color: typeColor, fontSize: 9, fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.location_on_rounded, size: 12, color: LogiSyncTheme.textMuted),
                    const SizedBox(width: 2),
                    Text(supplier['location'], style: TextStyle(color: LogiSyncTheme.textMuted, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          _Metric(label: 'Lead Time', value: '${supplier['lead']}d', color: LogiSyncTheme.primary),
          const SizedBox(width: 16),
          _Metric(label: 'Reliability', value: '${reliability.toStringAsFixed(0)}%',
            color: reliability >= 90 ? LogiSyncTheme.emerald : reliability >= 80 ? LogiSyncTheme.amber : LogiSyncTheme.rose),
          const SizedBox(width: 16),
          _Metric(label: 'On-Time', value: '${supplier['onTime']}%',
            color: (supplier['onTime'] as int) >= 90 ? LogiSyncTheme.emerald : LogiSyncTheme.amber),
          const SizedBox(width: 16),
          _Metric(label: 'Orders', value: '${supplier['orders']}', color: LogiSyncTheme.textSecondary),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Metric({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w700)),
          Text(label, style: TextStyle(color: LogiSyncTheme.textMuted, fontSize: 10)),
        ],
      ),
    );
  }
}
