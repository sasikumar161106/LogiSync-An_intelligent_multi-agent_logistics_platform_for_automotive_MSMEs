import 'package:flutter/material.dart';
import 'package:logisync_app/config/theme.dart';

import 'package:logisync_app/services/api_service.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<dynamic> _inventory = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final api = ApiService();
      final data = await api.getInventoryHealth();
      if (mounted) {
        setState(() {
          _inventory = data;
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: LogiSyncTheme.primary));
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, color: LogiSyncTheme.rose, size: 48),
            const SizedBox(height: 16),
            Text('Failed to load inventory', style: TextStyle(color: LogiSyncTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(_error!, style: TextStyle(color: LogiSyncTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() { _isLoading = true; _error = null; });
                _loadData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: LogiSyncTheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverToBoxAdapter(child: _buildSummaryCards()),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _InventoryRow(item: _inventory[index] as Map<String, dynamic>),
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
    final critical = _inventory.where((i) => i['stock_status'] == 'critical').length;
    final low = _inventory.where((i) => i['stock_status'] == 'low').length;
    final outOfStock = _inventory.where((i) => i['stock_status'] == 'out_of_stock').length;
    final totalValue = _inventory.fold<num>(0, (sum, i) => sum + (i['stock_value_inr'] as num? ?? 0));

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
    final status = item['stock_status'] as String? ?? 'healthy';
    final Color statusColor;
    switch (status) {
      case 'critical': statusColor = LogiSyncTheme.rose; break;
      case 'low': statusColor = LogiSyncTheme.amber; break;
      case 'out_of_stock': statusColor = LogiSyncTheme.textMuted; break;
      default: statusColor = LogiSyncTheme.emerald;
    }

    final stockRatio = (item['current_stock'] as num? ?? 0) / ((item['min_stock_level'] as num? ?? 1) == 0 ? 1 : (item['min_stock_level'] as num));

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LogiSyncTheme.cardBg,
        borderRadius: LogiSyncTheme.radiusMd,
        border: Border.all(
          color: status == 'critical' || status == 'out_of_stock'
              ? statusColor.withValues(alpha: 0.4)
              : LogiSyncTheme.border,
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
                Text(item['material_name'] ?? 'Unknown', style: TextStyle(color: LogiSyncTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w500)),
                Text(item['part_number'] ?? 'N/A', style: TextStyle(color: LogiSyncTheme.textMuted, fontSize: 11)),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${item['current_stock']} / ${item['min_stock_level']}', style: TextStyle(color: LogiSyncTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
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
              (item['days_until_stockout'] != null && (item['days_until_stockout'] as num) > 0) 
                  ? '${item['days_until_stockout']}d left' 
                  : 'EMPTY',
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
