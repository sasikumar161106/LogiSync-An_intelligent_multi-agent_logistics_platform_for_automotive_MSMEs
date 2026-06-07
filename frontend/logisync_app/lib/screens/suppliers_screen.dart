import 'package:flutter/material.dart';
import 'package:logisync_app/config/theme.dart';

import 'package:logisync_app/services/api_service.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  List<dynamic> _suppliers = [];
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
      final data = await api.getSuppliers();
      if (mounted) {
        setState(() {
          _suppliers = data;
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
            Text('Failed to load suppliers', style: TextStyle(color: LogiSyncTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
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
              (context, index) => _SupplierCard(supplier: _suppliers[index] as Map<String, dynamic>),
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
    final type = supplier['supplier_type'] as String? ?? 'local';
    final reliabilityScore = (supplier['reliability_score'] as num?)?.toDouble() ?? 0.85;
    final reliability = reliabilityScore * 100;
    final onTime = (reliabilityScore * 100).toInt();
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
        color: LogiSyncTheme.cardBg,
        borderRadius: LogiSyncTheme.radiusLg,
        border: Border.all(color: LogiSyncTheme.border),
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
                Text(supplier['name'] ?? 'Unknown', style: TextStyle(color: LogiSyncTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
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
                    Text(supplier['location'] ?? 'Unknown', style: TextStyle(color: LogiSyncTheme.textMuted, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          _Metric(label: 'Lead Time', value: '${supplier['lead_time_days'] ?? 0}d', color: LogiSyncTheme.primary),
          const SizedBox(width: 16),
          _Metric(label: 'Reliability', value: '${reliability.toStringAsFixed(0)}%',
            color: reliability >= 90 ? LogiSyncTheme.emerald : reliability >= 80 ? LogiSyncTheme.amber : LogiSyncTheme.rose),
          const SizedBox(width: 16),
          _Metric(label: 'On-Time', value: '$onTime%',
            color: onTime >= 90 ? LogiSyncTheme.emerald : LogiSyncTheme.amber),
          const SizedBox(width: 16),
          _Metric(label: 'Orders', value: '${supplier['total_orders'] ?? 0}', color: LogiSyncTheme.textSecondary),
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
