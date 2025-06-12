import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificacionService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static Future<void> initNotifications() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Madrid'));

    const androidInit = AndroidInitializationSettings('icono_citamed');
    const iosInit = DarwinInitializationSettings(
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentSound: true,
    );
    const settings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(settings);

    const canal = AndroidNotificationChannel(
      'canal_citas',
      'Notificaciones de Citas',
      description: 'Recordatorio 1h antes de cita',
      importance: Importance.max,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(canal);

    if (Platform.isAndroid) {
    } else {
      await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }

    await Permission.notification.request();
    if (Platform.isAndroid) {
      await Permission.scheduleExactAlarm.request();
    }
  }

  static Future<void> programarNotificacionUnaHoraAntes({
    required int idNotificacion,
    required String titulo,
    required String cuerpo,
    required DateTime fechaCita,
  }) async {
    final fechaNotif = fechaCita.subtract(const Duration(hours: 1));

    final when = tz.TZDateTime.from(fechaNotif, tz.local);
    debugPrint('🕒 Scheduling 1h-before at: $when');

    final androidDetails = AndroidNotificationDetails(
      'canal_citas',
      'Notificaciones de Citas',
      importance: Importance.max,
      priority: Priority.high,
    );
    final iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final hasExact =
        Platform.isAndroid
            ? await Permission.scheduleExactAlarm.isGranted
            : false;

    await _plugin.zonedSchedule(
      idNotificacion,
      titulo,
      cuerpo,
      when,
      details,
      androidScheduleMode:
          hasExact
              ? AndroidScheduleMode.exactAllowWhileIdle
              : AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}
