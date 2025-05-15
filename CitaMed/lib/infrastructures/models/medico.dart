import 'centro_de_salud.dart';
import 'usuario.dart';

class Medico extends Usuario {
  final String especialidad;
  final CentroDeSalud? centroDeSalud;

  Medico({
    required this.especialidad,
    required this.centroDeSalud,
    required super.id,
    required super.nombre,
    required super.apellidos,
    required super.email,
    required super.contrasenya,
    required super.telefono,
    required super.activo,
    required super.rol,
    required super.direccion,
    required super.dni,
    required super.imagen,
    required super.numeroSeguridadSocial,
    required super.sexo,
    required super.fechaNacimiento,
  });

  factory Medico.fromJson(Map<String, dynamic> json) {
    final apellidoVal =
        json['apellidos'] as String? ?? json['apellido'] as String? ?? '';
    final rolVal = json['rol'] as String? ?? json['role'] as String? ?? '';
    final numeroSS =
        json['numeroSeguridadSocial'] as String? ??
        json['numero_seguridad_social'] as String? ??
        '';
    final fechaStr =
        json['fechaNacimiento'] as String? ??
        json['fecha_nacimiento'] as String?;

    return Medico(
      especialidad: json['especialidad'] as String? ?? '',
      centroDeSalud:
          json['centroDeSalud'] != null
              ? CentroDeSalud.fromJson(
                json['centroDeSalud'] as Map<String, dynamic>,
              )
              : null,
      id: json['id'] as int,
      nombre: json['nombre'] as String? ?? '',
      apellidos: apellidoVal,
      email: json['email'] as String? ?? '',
      contrasenya: '',
      telefono: json['telefono'] as String? ?? '',
      activo: json['activo'] as int? ?? 0,
      rol: rolVal,
      direccion: json['direccion'] as String? ?? '',
      dni: json['dni'] as String? ?? '',
      imagen: json['imagen'] as String? ?? '',
      numeroSeguridadSocial: numeroSS,
      sexo: json['sexo'] as String? ?? '',
      fechaNacimiento:
          fechaStr != null
              ? DateTime.parse(fechaStr)
              : (throw Exception('fechaNacimiento ausente para Medico')),
    );
  }
}
