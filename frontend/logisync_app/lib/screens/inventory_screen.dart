import 'package:flutter/material.dart';
import 'package:logisync_app/config/theme.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  static final List<Map<String, dynamic>> _inventory = [
    {'name': 'Brake Pad Set (Front)', 'part': 'BRK-PAD-001', 'stock': 60, 'min': 200, 'status': 'critical', 'rate': 25.3, 'days': 2.4, 'value': 51000},
    {'name': 'Ball Bearing 6205-2RS', 'part': 'BRG-6205', 'stock': 250, 'min': 500, 'status': 'low', 'rate': 18.5, 'days': 13.5, 'value': 46250},
    {'name': 'Cylinder Head Gasket', 'part': 'GSK-CYL-001', 'stock': 15, 'min': 100, 'status': 'critical', 'rate': 14.2, 'days': 1.1, 'value': 18750},
    {'name': 'Mild Steel Sheet 3mm', 'part': 'STL-MS-3MM', 'stock': 1600, 'min': 2000, 'status': 'low', 'rate': 120.0, 'days': 13.3, 'value': 115200},
    {'name': 'Rubber Oil Seal (55mm)', 'part': 'RBR-SEAL-02', 'stock': 0, 'min': 300, 'status': 'out_of_stock', 'rate': 12.0, 'days': 0, 'value': 0},
    {'name': 'Brake Pad Set (Rear)', 'part': 'BRK-PAD-002', 'stock': 225, 'min': 150, 'status': 'healthy', 'rate': 15.0, 'days': 15.0, 'value': 162000},
    {'name': 'Ball Bearing 6308-ZZ', 'part': 'BRG-6308', 'stock': 600, 'min': 300, 'status': 'healthy', 'rate': 10.0, 'days': 60.0, 'value': 204000},
    {'name': 'Oil Pan Gasket', 'part': 'GSK-OIL-001', 'stock': 120, 'min': 100, 'status': 'healthy', 'rate': 8.5, 'days': 14.1, 'value': 45600},
    {'name': 'Shock Absorber (Rear)', 'part': 'SHK-ABS-002', 'stock': 16, 'min': 80, 'status': 'critical', 'rate': 5.2, 'days': 3.1, 'value': 26400},
    {'name': 'Clutch Plate Assembly', 'part': 'CLT-PLT-001', 'stock': 20, 'min': 50, 'status': 'low', 'rate': 3.5, 'days': 5.7, 'value': 64000},
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverToBoxAdapter(child: _buildSummaryCards()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _InventoryRow(item: _inventory[index]),
              childCount: _inventory.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        'Inventory Management',
        style: TextStyle(
          color: LogiSyncTheme.textPrimary,
          fontSize: 26,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final critical = _inventory.where((i) => i['status'] == 'critical').length;
    final low = _inventory.where((i) => i['status'] == 'low').length;
    final outOfStock = _inventory.where((i) => i['status'] == 'out_of_stock').length;
    final totalValue = _inventory.fold<num>(0, (sum, i) => sum + (i['value'] as num));

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          _SummaryChip(label: 'Total Value', value: '₹${(totalValue / 100000).toStringAsFixed(1)}L', color: LogiSyncTheme.primary),
          const SizedBox(width: 12),
          _SummaryChip(label: 'Critical', value: '$critical', color: LogiSyncTheme.rose),
          const SizedBox(width: 12),
          _SummaryChip(label: 'Low', value: '$low', color: LogiSyncTheme.amber),
          const SizedBox(width: 12),
          _SummaryChip(label: 'Out of Stock', value: '$outOfStock', color: LogiSyncTheme.textMuted),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: LogiSyncTheme.radiusFull,
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color.withValues(alpha: 0.7), fontSize: 12)),
        ],
      ),
    );
  }
}

class _InventoryRow extends StatelessWidget {
  final Map<String, dynamic> item;
  const _InventoryRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final status = item['status'] as String;
    final Color statusColor;
    switch (status) {
      case 'critical': statusColor = LogiSyncTheme.rose; break;
      case 'low': statusColor = LogiSyncTheme.amber; break;
      case 'out_of_stock': statusColor = LogiSyncTheme.textMuted; break;
      default: statusColor = LogiSyncTheme.emerald;
    }

    final stockRatio = (item['stock'] as num) / (item['min'] as num);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LogiSyncTheme.cardBg,
        borderRadius: LogiSyncTheme.radiusMd,
        border: Border.all(
          color: status == 'critical' || status == 'out_of_stock'
              ? statusColor.withValues(alpha: 0.2)
              : LogiSyncTheme.border.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: LogiSyncTheme.radiusFull,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['name'], style: TextStyle(color: LogiSyncTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
                Text(item['part'], style: TextStyle(color: LogiSyncTheme.textMuted, fontSize: 11)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item['stock']} / ${item['min']}', style: TextStyle(color: LogiSyncTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                SizedBox(
                  width: 80,
                  child: ClipRRect(
                    borderRadius: LogiSyncTheme.radiusFull,
                    child: LinearProgressIndicator(
                      value: stockRatio.clamp(0, 1).toDouble(),
                      backgroundColor: LogiSyncTheme.surfaceLight,
                      color: statusColor,
                      minHeight: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            child: Text(
              item['days'] > 0 ? '${item['days']}d left' : 'EMPTY',
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 80,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: LogiSyncTheme.radiusFull,
              ),
              child: Text(
                status.replaceAll('_', ' ').toUpperCase(),
                style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
