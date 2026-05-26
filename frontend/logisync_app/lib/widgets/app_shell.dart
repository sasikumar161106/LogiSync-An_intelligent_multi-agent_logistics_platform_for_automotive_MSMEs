import 'package:flutter/material.dart';
import 'package:logisync_app/config/theme.dart';

/// Responsive app shell with sidebar navigation (desktop/tablet) 
/// and bottom navigation bar (mobile).
class AppShell extends StatelessWidget {
  final int selectedIndex;
  final Widget child;

  const AppShell({
    super.key,
    required this.selectedIndex,
    required this.child,
  });

  static const List<_NavItem> _navItems = [
    _NavItem(icon: Icons.dashboard_rounded, label: 'Dashboard', route: '/'),
    _NavItem(icon: Icons.notifications_active_rounded, label: 'Alerts', route: '/alerts'),
    _NavItem(icon: Icons.inventory_2_rounded, label: 'Inventory', route: '/inventory'),
    _NavItem(icon: Icons.local_shipping_rounded, label: 'Shipments', route: '/shipments'),
    _NavItem(icon: Icons.people_rounded, label: 'Suppliers', route: '/suppliers'),
    _NavItem(icon: Icons.smart_toy_rounded, label: 'AI Agents', route: '/agents'),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            _buildSidebar(context),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: LogiSyncTheme.surface,
        border: Border(
          right: BorderSide(color: LogiSyncTheme.border.withValues(alpha: 0.3)),
        ),
      ),
      child: Column(
        children: [
          // Logo / Brand
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LogiSyncTheme.primaryGradient,
                    borderRadius: LogiSyncTheme.radiusMd,
                  ),
                  child: const Icon(Icons.hub_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LogiSync',
                      style: TextStyle(
                        color: LogiSyncTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      'Control Tower',
                      style: TextStyle(
                        color: LogiSyncTheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: LogiSyncTheme.divider, height: 1),
          const SizedBox(height: 8),

          // Nav Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = index == selectedIndex;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: LogiSyncTheme.radiusMd,
                        onTap: () {
                          if (!isSelected) {
                            Navigator.pushReplacementNamed(context, item.route);
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? LogiSyncTheme.primary.withValues(alpha: 0.15)
                                : Colors.transparent,
                            borderRadius: LogiSyncTheme.radiusMd,
                            border: isSelected
                                ? Border.all(color: LogiSyncTheme.primary.withValues(alpha: 0.3))
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item.icon,
                                color: isSelected ? LogiSyncTheme.primary : LogiSyncTheme.textMuted,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                item.label,
                                style: TextStyle(
                                  color: isSelected ? LogiSyncTheme.primary : LogiSyncTheme.textSecondary,
                                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                  fontSize: 14,
                                ),
                              ),
                              if (item.label == 'Alerts') ...[
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: LogiSyncTheme.rose.withValues(alpha: 0.2),
                                    borderRadius: LogiSyncTheme.radiusFull,
                                  ),
                                  child: Text(
                                    '2',
                                    style: TextStyle(
                                      color: LogiSyncTheme.rose,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Status indicator
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: LogiSyncTheme.emerald.withValues(alpha: 0.1),
              borderRadius: LogiSyncTheme.radiusMd,
              border: Border.all(color: LogiSyncTheme.emerald.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: LogiSyncTheme.emerald,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: LogiSyncTheme.emerald.withValues(alpha: 0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Online',
                      style: TextStyle(
                        color: LogiSyncTheme.emerald,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Agents monitoring',
                      style: TextStyle(
                        color: LogiSyncTheme.textMuted,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: LogiSyncTheme.surface,
        border: Border(
          top: BorderSide(color: LogiSyncTheme.border.withValues(alpha: 0.3)),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          Navigator.pushReplacementNamed(context, _navItems[index].route);
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        selectedItemColor: LogiSyncTheme.primary,
        unselectedItemColor: LogiSyncTheme.textMuted,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        elevation: 0,
        items: _navItems
            .map((item) => BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  label: item.label,
                ))
            .toList(),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final String route;

  const _NavItem({required this.icon, required this.label, required this.route});
}
