import 'package:flutter/material.dart';
import 'package:logisync_app/config/theme.dart';

class ShipmentsScreen extends StatelessWidget {
  const ShipmentsScreen({super.key});

  static final List<Map<String, dynamic>> _shipments = [
    {
      'ref': 'SHP-2026-0451',
      'supplier': 'Nippon Steel Japan',
      'material': 'Mild Steel Sheet 3mm',
      'quantity': '5,000 kg',
      'status': 'delayed',
      'origin': 'Tokyo, Japan',
      'port': 'Ennore Port',
      'vessel': 'MV Sakura Maru',
      'eta': 'May 25 (Delayed)',
      'delay': '48h',
      'location': 'Ennore Port Anchorage',
      'progress': 0.85,
    },
    {
      'ref': 'SHP-2026-0452',
      'supplier': 'Bosch Rexroth Germany',
      'material': 'Ball Bearing 6205-2RS',
      'quantity': '1,000 pcs',
      'status': 'in_transit',
      'origin': 'Stuttgart, Germany',
      'port': 'Chennai Port',
      'vessel': 'MSC Lorena',
      'eta': 'May 31',
      'delay': '0h',
      'location': 'Arabian Sea — 800km from Chennai',
      'progress': 0.6,
    },
    {
      'ref': 'SHP-2026-0453',
      'supplier': 'Chennai Auto Parts',
      'material': 'Rubber Oil Seal (55mm)',
      'quantity': '600 pcs',
      'status': 'in_delivery',
      'origin': 'Ambattur, Chennai',
      'port': 'Local',
      'vessel': 'Road Transport',
      'eta': 'Today 4:30 PM',
      'delay': '0h',
      'location': 'Ambattur Industrial Estate',
      'progress': 0.92,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Text('Shipment Tracking',
              style: TextStyle(color: LogiSyncTheme.textPrimary, fontSize: 26, fontWeight: FontWeight.w700)),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _ShipmentCard(shipment: _shipments[index]),
              childCount: _shipments.length,
            ),
          ),
        ),
      ],
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
        gradient: LogiSyncTheme.cardGradient,
        borderRadius: LogiSyncTheme.radiusLg,
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
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
              Text(shipment['ref'], style: TextStyle(color: LogiSyncTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
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
              Expanded(child: _InfoCol(label: 'Supplier', value: shipment['supplier'])),
              Expanded(child: _InfoCol(label: 'Material', value: shipment['material'])),
              Expanded(child: _InfoCol(label: 'Quantity', value: shipment['quantity'])),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _InfoCol(label: 'Origin', value: shipment['origin'])),
              Expanded(child: _InfoCol(label: 'Port', value: shipment['port'])),
              Expanded(child: _InfoCol(label: 'ETA', value: shipment['eta'])),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          Row(
            children: [
              Text('📍 ${shipment['location']}',
                style: TextStyle(color: LogiSyncTheme.textMuted, fontSize: 11)),
              if (shipment['delay'] != '0h') ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: LogiSyncTheme.rose.withValues(alpha: 0.2),
                    borderRadius: LogiSyncTheme.radiusFull,
                  ),
                  child: Text('Delay: ${shipment['delay']}',
                    style: TextStyle(color: LogiSyncTheme.rose, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: LogiSyncTheme.radiusFull,
            child: LinearProgressIndicator(
              value: (shipment['progress'] as double),
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
