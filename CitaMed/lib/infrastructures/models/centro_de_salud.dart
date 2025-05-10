class CentroDeSalud {
  final int id;
  final String nombre;
  final String direccion;
  final String telefono;
  final String imagen;
  final double longitud;
  final double latitud;

  CentroDeSalud(
      {required this.id,
      required this.nombre,
      required this.direccion,
      required this.telefono,
      required this.imagen,
      required this.longitud,
      required this.latitud});

  factory CentroDeSalud.fromJson(Map<String, dynamic> json) {
    return CentroDeSalud(
        id: json['id'],
        nombre: json['nombre'],
        direccion: json['direccion'],
        telefono: json['telefono'],
        imagen: json['imagen'],
        longitud: json['longitud'],
        latitud: json['latitud']);
  }
}
