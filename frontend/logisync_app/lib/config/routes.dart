import 'package:flutter/material.dart';
import 'package:logisync_app/screens/dashboard_screen.dart';
import 'package:logisync_app/screens/alerts_screen.dart';
import 'package:logisync_app/screens/inventory_screen.dart';
import 'package:logisync_app/screens/shipments_screen.dart';
import 'package:logisync_app/screens/suppliers_screen.dart';
import 'package:logisync_app/screens/agent_monitor_screen.dart';
import 'package:logisync_app/widgets/app_shell.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _buildRoute(const AppShell(selectedIndex: 0, child: DashboardScreen()));
      case '/alerts':
        return _buildRoute(const AppShell(selectedIndex: 1, child: AlertsScreen()));
      case '/inventory':
        return _buildRoute(const AppShell(selectedIndex: 2, child: InventoryScreen()));
      case '/shipments':
        return _buildRoute(const AppShell(selectedIndex: 3, child: ShipmentsScreen()));
      case '/suppliers':
        return _buildRoute(const AppShell(selectedIndex: 4, child: SuppliersScreen()));
      case '/agents':
        return _buildRoute(const AppShell(selectedIndex: 5, child: AgentMonitorScreen()));
      default:
        return _buildRoute(const AppShell(selectedIndex: 0, child: DashboardScreen()));
    }
  }

  static MaterialPageRoute _buildRoute(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}
