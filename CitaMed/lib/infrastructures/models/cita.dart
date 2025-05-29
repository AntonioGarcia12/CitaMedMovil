import 'package:CitaMed/infrastructures/models/usuario.dart';

import 'centro_de_salud.dart';
import 'medico.dart';

class Cita {
  final int? id;
  final DateTime fecha;
  final Usuario? paciente;
  final Medico idMedico;
  final CentroDeSalud idCentro;
  final String? estado;

  Cita({
    this.id,
    required this.fecha,
    this.paciente,
    required this.idMedico,
    required this.idCentro,
    this.estado,
  });

  factory Cita.fromJson(Map<String, dynamic> json) {
    final rawMed = json['medico'] ?? json['idMedico'];
    final medico =
        rawMed is int
            ? Medico(
              especialidad: '',
              centroDeSalud: null,
              id: rawMed,
              nombre: '',
              apellidos: '',
              email: '',
              contrasenya: '',
              telefono: '',
              activo: 0,
              rol: '',
              direccion: '',
              dni: '',
              imagen: '',
              numeroSeguridadSocial: '',
              sexo: '',
              fechaNacimiento: DateTime(1970),
            )
            : Medico.fromJson(rawMed as Map<String, dynamic>);

    final rawCentro = json['centroDeSalud'] ?? json['idCentro'];
    final centro =
        rawCentro is int
            ? CentroDeSalud(
              id: rawCentro,
              nombre: '',
              direccion: '',
              telefono: '',
              imagen: '',
              longitud: 0,
              latitud: 0,
            )
            : CentroDeSalud.fromJson(rawCentro as Map<String, dynamic>);

    final rawPac = json['paciente'];
    final paciente =
        rawPac == null
            ? null
            : Usuario.fromJson(rawPac as Map<String, dynamic>);

    final raw = json['fecha'] as String;
    final ymd = raw.substring(0, 10).split('-').map(int.parse).toList();
    final hms = raw.substring(11).split(':');
    final segundo = int.parse(hms[2].split('.').first);

    final fechaLocal = DateTime(
      ymd[0],
      ymd[1],
      ymd[2],
      int.parse(hms[0]),
      int.parse(hms[1]),
      segundo,
    );

    return Cita(
      id: json['id'] as int?,
      fecha: fechaLocal,
      paciente: paciente,
      idMedico: medico,
      idCentro: centro,
      estado: json['estado'] as String?,
    );
  }

  Cita copyWith({String? estado}) {
    return Cita(
      id: id,
      fecha: fecha,
      paciente: paciente,
      idCentro: idCentro,
      idMedico: idMedico,
      estado: estado ?? this.estado,
    );
  }
}
