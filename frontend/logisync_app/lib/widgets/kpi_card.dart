import 'package:flutter/material.dart';
import 'package:logisync_app/config/theme.dart';

enum TrendDirection { up, down, stable }

class KPIData {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final TrendDirection trend;

  KPIData({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.trend = TrendDirection.stable,
  });
}

class KPICard extends StatefulWidget {
  final KPIData data;
  final int animationDelay;

  const KPICard({super.key, required this.data, this.animationDelay = 0});

  @override
  State<KPICard> createState() => _KPICardState();
}

class _KPICardState extends State<KPICard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(Duration(milliseconds: widget.animationDelay), () {
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: MouseRegion(
              onEnter: (_) => setState(() => _isHovered = true),
              onExit: (_) => setState(() => _isHovered = false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LogiSyncTheme.cardGradient,
                  borderRadius: LogiSyncTheme.radiusLg,
                  border: Border.all(
                    color: _isHovered
                        ? widget.data.color.withValues(alpha: 0.4)
                        : LogiSyncTheme.border.withValues(alpha: 0.2),
                  ),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: widget.data.color.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : LogiSyncTheme.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: widget.data.color.withValues(alpha: 0.15),
                            borderRadius: LogiSyncTheme.radiusMd,
                          ),
                          child: Icon(
                            widget.data.icon,
                            color: widget.data.color,
                            size: 20,
                          ),
                        ),
                        _buildTrendIndicator(),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      widget.data.value,
                      style: TextStyle(
                        color: LogiSyncTheme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.data.title,
                      style: TextStyle(
                        color: LogiSyncTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      widget.data.subtitle,
                      style: TextStyle(
                        color: LogiSyncTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrendIndicator() {
    IconData icon;
    Color color;
    switch (widget.data.trend) {
      case TrendDirection.up:
        icon = Icons.trending_up_rounded;
        color = LogiSyncTheme.emerald;
        break;
      case TrendDirection.down:
        icon = Icons.trending_down_rounded;
        color = LogiSyncTheme.rose;
        break;
      case TrendDirection.stable:
        icon = Icons.trending_flat_rounded;
        color = LogiSyncTheme.textMuted;
        break;
    }
    return Icon(icon, color: color, size: 20);
  }
}
