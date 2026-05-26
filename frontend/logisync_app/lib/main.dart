import 'package:flutter/material.dart';
import 'package:logisync_app/config/theme.dart';
import 'package:logisync_app/config/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LogiSyncApp());
}

class LogiSyncApp extends StatelessWidget {
  const LogiSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LogiSync — Agentic Control Tower',
      debugShowCheckedModeBanner: false,
      theme: LogiSyncTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
