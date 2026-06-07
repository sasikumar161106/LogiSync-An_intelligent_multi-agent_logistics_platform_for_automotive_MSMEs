import 'package:flutter/material.dart';
import 'package:logisync_app/config/theme.dart';

import 'package:logisync_app/services/api_service.dart';

class ShipmentsScreen extends StatefulWidget {
  const ShipmentsScreen({super.key});

  @override
  State<ShipmentsScreen> createState() => _ShipmentsScreenState();
}

class _ShipmentsScreenState extends State<ShipmentsScreen> {
  List<dynamic> _shipments = [];
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
      final data = await api.getShipments();
      if (mounted) {
        setState(() {
          _shipments = data;
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
            Text('Failed to load shipments', style: TextStyle(color: LogiSyncTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w600)),
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
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _ShipmentCard(shipment: _shipments[index] as Map<String, dynamic>),
              childCount: _shipments.length,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Active Shipments',
            style: TextStyle(
              color: LogiSyncTheme.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: LogiSyncTheme.primary.withValues(alpha: 0.1),
              borderRadius: LogiSyncTheme.radiusFull,
            ),
            child: Text(
              '${_shipments.length} Transit',
              style: TextStyle(color: LogiSyncTheme.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShipmentCard extends StatelessWidget {
  final Map<String, dynamic> shipment;
  const _ShipmentCard({required this.shipment});

  @override
  Widget build(BuildContext context) {
    final status = shipment['status'] as String;
    final Color statusColor;
    switch (status) {
      case 'delayed': statusColor = LogiSyncTheme.rose; break;
      case 'in_transit': statusColor = LogiSyncTheme.primary; break;
      case 'in_delivery': statusColor = LogiSyncTheme.emerald; break;
      default: statusColor = LogiSyncTheme.textMuted;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
              Icon(
                status == 'delayed' ? Icons.warning_rounded :
                status == 'in_delivery' ? Icons.local_shipping_rounded :
                Icons.directions_boat_rounded,
                color: statusColor, size: 20,
              ),
              const SizedBox(width: 10),
              Text(shipment['shipment_ref'] ?? 'REF-UNKNOWN', style: TextStyle(color: LogiSyncTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: LogiSyncTheme.radiusFull,
                ),
                child: Text(
                  status.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _InfoCol(label: 'Supplier', value: shipment['suppliers']?['name'] ?? 'Unknown')),
              Expanded(child: _InfoCol(label: 'Material', value: shipment['materials']?['name'] ?? 'Unknown')),
              Expanded(child: _InfoCol(label: 'Quantity', value: shipment['quantity']?.toString() ?? 'N/A')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _InfoCol(label: 'Origin', value: shipment['origin'] ?? 'Unknown')),
              Expanded(child: _InfoCol(label: 'Port', value: shipment['port_of_entry'] ?? 'Unknown')),
              Expanded(child: _InfoCol(label: 'ETA', value: shipment['estimated_arrival']?.toString().split('T').first ?? 'Unknown')),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          Row(
            children: [
              Text('📍 ${shipment['current_location'] ?? 'In Transit'}',
                style: TextStyle(color: LogiSyncTheme.textMuted, fontSize: 11)),
              if ((shipment['delay_hours'] as num? ?? 0) > 0) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: LogiSyncTheme.rose.withValues(alpha: 0.2),
                    borderRadius: LogiSyncTheme.radiusFull,
                  ),
                  child: Text('Delay: ${shipment['delay_hours']}h',
                    style: TextStyle(color: LogiSyncTheme.rose, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: LogiSyncTheme.radiusFull,
            child: LinearProgressIndicator(
              value: 0.5, // Mock progress for API data
              backgroundColor: LogiSyncTheme.surfaceLight,
              color: statusColor,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCol extends StatelessWidget {
  final String label;
  final String value;
  const _InfoCol({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: LogiSyncTheme.textMuted, fontSize: 10, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(color: LogiSyncTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w500),
          overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
