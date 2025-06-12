import 'dart:convert';

import 'package:CitaMed/services/auth_services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

Color getEstadoColor(String estado) {
  switch (estado) {
    case 'PENDIENTE':
      return Colors.orange;
    case 'CONFIRMADA':
      return Colors.green;
    case 'CANCELADA':
      return Colors.red;
    default:
      return const Color(0xFF00838F);
  }
}

IconData getEstadoIcon(String estado) {
  switch (estado) {
    case 'PENDIENTE':
      return Icons.schedule;
    case 'CONFIRMADA':
      return Icons.check_circle;
    case 'CANCELADA':
      return Icons.cancel;
    default:
      return Icons.calendar_today;
  }
}

String getEstadoText(String estado) {
  switch (estado) {
    case 'PENDIENTE':
      return 'Pendiente';
    case 'CONFIRMADA':
      return 'Confirmada';
    case 'CANCELADA':
      return 'Cancelada';
    default:
      return estado;
  }
}

Future<DateTime?> pickDateTime(
  BuildContext context, {
  DateTime? initial,
}) async {
  final now = DateTime.now();
  final initialDate = initial ?? now;

  final DateTime? date = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: now,
    lastDate: now.add(const Duration(days: 365)),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF00838F),
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      );
    },
  );

  if (date == null) return null;

  final TimeOfDay? time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initialDate),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF00838F),
            onPrimary: Colors.white,
            onSurface: Colors.black,
          ),
        ),
        child: child!,
      );
    },
  );

  if (time == null) return null;

  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

void mostrarError(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(mensaje),
      backgroundColor: Colors.red.shade700,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

void mostrarExito(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(mensaje),
      backgroundColor: Colors.green.shade700,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}

Future<void> cerrarSesion(BuildContext context) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder:
        (context) => AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Cerrar sesión'),
            ),
          ],
        ),
  );

  if (confirm == true) {
    await AuthService.logout();
    if (context.mounted) context.go('/login');
  }
}

Widget buildReadOnlyField(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ],
    ),
  );
}

Widget buildBackgroundDecorations() {
  return Stack(
    children: [
      Positioned(top: -50, right: -50, child: buildCircleDecoration(200)),
      Positioned(bottom: -100, left: -50, child: buildCircleDecoration(250)),
    ],
  );
}

Widget buildCircleDecoration(double size) {
  return Container(
    height: size,
    width: size,
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.07),
      borderRadius: BorderRadius.circular(size / 2),
    ),
  );
}

Widget buildCardButton({
  required BuildContext context,
  required String imagePath,
  required String label,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            // ignore: deprecated_member_use
            Colors.black.withOpacity(0.25),
            BlendMode.darken,
          ),
        ),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    ),
  );
}

String extractError(http.Response response) {
  try {
    final err = json.decode(response.body) as Map<String, dynamic>;
    return err['mensaje'] as String? ?? 'Código ${response.statusCode}';
  } catch (_) {
    return 'Código ${response.statusCode}';
  }
}
