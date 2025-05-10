import 'centro_de_salud.dart';
import 'medico.dart';
import 'usuario.dart';

class Cita {
  final int id;
  final DateTime fecha;
  final Medico id_medico;
  final CentroDeSalud id_centro;
  final Usuario id_paciente;
  final String descripcion;
  final String estado;

  Cita(
      {required this.id,
      required this.fecha,
      required this.id_medico,
      required this.id_centro,
      required this.id_paciente,
      required this.descripcion,
      required this.estado});

  factory Cita.fromJson(Map<String, dynamic> json) {
    return Cita(
        id: json['id'],
        fecha: DateTime.parse(json['fecha']),
        id_medico: Medico.fromJson(json['id_medico']),
        id_centro: CentroDeSalud.fromJson(json['id_centro']),
        id_paciente: Usuario.fromJson(json['id_paciente']),
        descripcion: json['descripcion'],
        estado: json['estado']);
  }
}
