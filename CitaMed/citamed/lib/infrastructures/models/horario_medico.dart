import 'medico.dart';

class HorarioMedico {
  final int id;
  final String dia;
  final DateTime hora_inicio;
  final DateTime hora_fin;
  final Medico id_medico;

  HorarioMedico(
      {required this.id,
      required this.dia,
      required this.hora_inicio,
      required this.hora_fin,
      required this.id_medico});

  factory HorarioMedico.fromJson(Map<String, dynamic> json) {
    return HorarioMedico(
      id: json['id'],
      dia: json['dia'],
      hora_inicio: DateTime.parse(json['hora_inicio']),
      hora_fin: DateTime.parse(json['hora_fin']),
      id_medico: Medico.fromJson(json['id_medico']),
    );
  }
}
