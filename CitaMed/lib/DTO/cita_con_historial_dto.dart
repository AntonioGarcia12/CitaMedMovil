class CitaConHistorial {
  final int citaId;
  final DateTime fecha;
  final String estado;
  final int medicoId;
  final String medicoNombre;
  final int centroId;
  final String centroNombre;
  final String? diagnostico;
  final String? tratamiento;

  CitaConHistorial({
    required this.citaId,
    required this.fecha,
    required this.estado,
    required this.medicoId,
    required this.medicoNombre,
    required this.centroId,
    required this.centroNombre,
    this.diagnostico,
    this.tratamiento,
  });

  factory CitaConHistorial.fromJson(Map<String, dynamic> json) {
    return CitaConHistorial(
      citaId: json['citaId'] as int,
      fecha: DateTime.parse(json['fecha'] as String),
      estado: json['estado'] as String,
      medicoId: json['medicoId'] as int,
      medicoNombre: json['medicoNombre'] as String,
      centroId: json['centroId'] as int,
      centroNombre: json['centroNombre'] as String,
      diagnostico: json['diagnostico'] as String?,
      tratamiento: json['tratamiento'] as String?,
    );
  }
}
