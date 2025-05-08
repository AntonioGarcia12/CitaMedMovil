import 'package:citamed/config/routes/routes.dart';
import 'package:citamed/config/theme/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'CitaMed',
      routerConfig: appRouter,
      theme: AppTheme().getTheme(),
    );
  }
}
