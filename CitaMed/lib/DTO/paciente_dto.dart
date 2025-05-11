class PacienteDto {
  final String? telefono;
  final String? direccion;
  final String? imagen;

  PacienteDto({this.telefono, this.direccion, this.imagen});

  factory PacienteDto.fromJson(Map<String, dynamic> json) {
    return PacienteDto(
      telefono: json['telefono'],
      direccion: json['direccion'],
      imagen: json['imagen'],
    );
  }
}
