import 'medico.dart';

class HorarioMedico {
  final int? id;
  final DateTime dia;
  final DateTime horaInicio;
  final DateTime horaFin;
  final Medico medico;

  HorarioMedico({
    this.id,
    required this.dia,
    required this.horaInicio,
    required this.horaFin,
    required this.medico,
  });

  factory HorarioMedico.fromJson(Map<String, dynamic> json) {
    DateTime parseTime(String timeStr) {
      if (timeStr.contains('T')) return DateTime.parse(timeStr);

      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final now = DateTime.now();
        return DateTime(
          now.year,
          now.month,
          now.day,
          int.tryParse(parts[0]) ?? 0,
          int.tryParse(parts[1]) ?? 0,
        );
      }

      throw FormatException('Formato de hora inválido: $timeStr');
    }

    Medico medico =
        json['medico'] != null
            ? Medico.fromJson(json['medico'] as Map<String, dynamic>)
            : throw Exception('Campo medico ausente');

    return HorarioMedico(
      id: json['id'] as int?,
      dia: DateTime.parse(json['dia']),
      horaInicio: parseTime(json['horaInicio'] as String),
      horaFin: parseTime(json['horaFin'] as String),
      medico: medico,
    );
  }
}
