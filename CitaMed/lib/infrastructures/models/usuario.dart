class Usuario {
  int id;
  String nombre;
  String apellidos;
  String email;
  String? contrasenya;
  String? telefono;
  int activo;
  String rol;
  String? direccion;
  String? dni;
  String? imagen;
  String? numeroSeguridadSocial;
  String? sexo;
  DateTime? fechaNacimiento;
  Usuario({
    required this.id,
    required this.nombre,
    required this.apellidos,
    required this.email,
    this.contrasenya,
    required this.telefono,
    required this.activo,
    required this.rol,
    required this.direccion,
    required this.dni,
    this.imagen,
    required this.numeroSeguridadSocial,
    required this.sexo,
    required this.fechaNacimiento,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
    id: json['id'] as int,
    nombre: json['nombre'] as String? ?? '',
    apellidos: json['apellidos'] as String? ?? '',
    email: json['email'] as String? ?? '',
    contrasenya: json['contrasenya'] as String?,
    telefono: json['telefono'] as String?,
    activo: json['activo'] as int? ?? 0,
    rol: json['rol'] as String? ?? '',
    direccion: json['direccion'] as String?,
    dni: json['dni'] as String?,
    imagen: json['imagen'] as String?,
    numeroSeguridadSocial: json['numeroSeguridadSocial'] as String?,
    sexo: json['sexo'] as String?,
    fechaNacimiento:
        json['fechaNacimiento'] != null
            ? DateTime.parse(json['fechaNacimiento'])
            : null,
  );

  factory Usuario.vacio() {
    return Usuario(
      id: 0,
      nombre: '',
      apellidos: '',
      email: '',
      contrasenya: '',
      telefono: '',
      activo: 1,
      rol: 'paciente',
      direccion: '',
      dni: '',
      numeroSeguridadSocial: '',
      sexo: '',
      fechaNacimiento: DateTime.now(),
      imagen: '',
    );
  }

  Usuario copyWith({String? telefono, String? direccion, String? imagen}) {
    return Usuario(
      id: id,
      nombre: nombre,
      apellidos: apellidos,
      email: email,
      contrasenya: contrasenya,
      telefono: telefono ?? this.telefono,
      activo: activo,
      rol: rol,
      direccion: direccion ?? this.direccion,
      dni: dni,
      imagen: imagen ?? this.imagen,
      numeroSeguridadSocial: numeroSeguridadSocial,
      sexo: sexo,
      fechaNacimiento: fechaNacimiento,
    );
  }
}
