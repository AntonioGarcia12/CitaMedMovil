class Usuario {
  int id;
  String nombre;
  String apellido;
  String email;
  String? contrasenya;
  String telefono;
  int activo;
  String rol;
  String direccion;
  String dni;
  String? imagen;
  String numeroSeguridadSocial;
  String sexo;
  DateTime fechaNacimiento;
  Usuario({
    required this.id,
    required this.nombre,
    required this.apellido,
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
    id: json["id"],
    nombre: json["nombre"],
    apellido: json["apellido"],
    email: json["email"],
    contrasenya: json["contrasenya"],
    telefono: json["telefono"],
    activo: json["activo"],
    rol: json["rol"],
    direccion: json["direccion"],
    dni: json["dni"],
    imagen: json["imagen"],
    numeroSeguridadSocial: json["numeroSeguridadSocial"],
    sexo: json["sexo"],
    fechaNacimiento: DateTime.parse(json["fechaNacimiento"]),
  );

  factory Usuario.vacio() {
    return Usuario(
      id: 0,
      nombre: '',
      apellido: '',
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
      apellido: apellido,
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
