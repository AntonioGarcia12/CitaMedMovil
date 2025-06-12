import 'package:CitaMed/infrastructures/models/cita.dart';

import 'medico.dart';
import 'usuario.dart';

class HistorialMedico {
  final int? id;
  final Medico medico;
  final Usuario paciente;
  final Cita? cita;
  final String diagnostico;
  final String tratamiento;

  HistorialMedico({
    this.id,
    required this.medico,
    required this.paciente,
    this.cita,
    required this.diagnostico,
    required this.tratamiento,
  });

  factory HistorialMedico.fromJson(Map<String, dynamic> json) {
    return HistorialMedico(
      id: json['id'],
      medico: Medico.fromJson(json['medico']),
      paciente: Usuario.fromJson(json['paciente']),
      cita: json['cita'] != null ? Cita.fromJson(json['cita']) : null,
      diagnostico: json['diagnostico'],
      tratamiento: json['tratamiento'],
    );
  }
}
