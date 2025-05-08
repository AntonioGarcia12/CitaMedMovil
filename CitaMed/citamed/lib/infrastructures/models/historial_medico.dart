import 'medico.dart';
import 'usuario.dart';

class HistorialMedico {
  final int id;
  final Medico id_medico;
  final Usuario id_paciente;
  final String diagnostico;
  final String tratamiento;

  HistorialMedico(
      {required this.id,
      required this.id_medico,
      required this.id_paciente,
      required this.diagnostico,
      required this.tratamiento});

  factory HistorialMedico.fromJson(Map<String, dynamic> json) {
    return HistorialMedico(
      id: json['id'],
      id_medico: Medico.fromJson(json['id_medico']),
      id_paciente: Usuario.fromJson(json['id_paciente']),
      diagnostico: json['diagnostico'],
      tratamiento: json['tratamiento'],
    );
  }
}
