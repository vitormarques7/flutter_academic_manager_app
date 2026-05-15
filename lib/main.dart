import 'package:academic_manager_app/config/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'config/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: AppRoutes.welcome,
      routes: AppRoutes.routes,
    );
  }
}
