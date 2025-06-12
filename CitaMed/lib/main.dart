import 'package:CitaMed/config/routes/routes.dart';
import 'package:CitaMed/config/theme/app_theme.dart';
import 'package:CitaMed/services/notificacion_services.dart';
import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Europe/Madrid'));
  await NotificacionService.initNotifications();
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
