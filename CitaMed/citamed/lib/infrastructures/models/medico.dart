// medico.dart
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
    required super.apellido,
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
    return Medico(
      especialidad: json['especialidad'] as String? ?? '',
      centroDeSalud: json['centroDeSalud'] != null
          ? CentroDeSalud.fromJson(
              json['centroDeSalud'] as Map<String, dynamic>)
          : null,
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      apellido: json['apellido'] as String,
      email: json['email'] as String,
      contrasenya: '', // no se devuelve desde el servidor
      telefono: json['telefono'] as String? ?? '',
      activo: json['activo'] as int? ?? 0,
      rol: json['role'] as String? ?? '',
      direccion: json['direccion'] as String? ?? '',
      dni: json['dni'] as String? ?? '',
      imagen: json['imagen'] as String? ?? '',
      numeroSeguridadSocial: json['numeroSeguridadSocial'] as String? ?? '',
      sexo: json['sexo'] as String? ?? '',
      fechaNacimiento: DateTime.parse(json['fechaNacimiento'] as String),
    );
  }
}
