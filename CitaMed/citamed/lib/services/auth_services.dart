import 'dart:convert';
import 'dart:io';

import 'package:citamed/config/api_config.dart';
import 'package:citamed/infrastructures/models/centro_de_salud.dart';
import 'package:citamed/infrastructures/models/medico.dart';
import 'package:citamed/infrastructures/models/usuario.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'token';
  Future<Usuario> login(String email, String contrasenya) async {
    final Uri url = Uri.parse('${ApiConfig.baseUrl}/api/auth/login');

    final response = await http.post(
      url,
      headers: {'Accept': 'application/json'},
      body: {'email': email, 'contrasenya': contrasenya},
    );

    final Map<String, dynamic> responseData = json.decode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        responseData["mensaje"] ?? "Error en el login: ${response.statusCode}",
      );
    }

    final data =
        responseData["data"] as Map<String, dynamic>? ??
        (throw Exception("Datos de usuario no encontrados en la respuesta."));

    final id = data["id"] as int;
    final nombre = data["nombre"] as String? ?? '';
    final apellido = data["apellido"] as String? ?? '';
    final emailResp = data["email"] as String? ?? '';
    final telefono = data["telefono"] as String? ?? '';
    final activo = data["activo"] as int? ?? 0;
    final rol = data["rol"] as String? ?? '';
    final direccion = data["direccion"] as String? ?? '';
    final dni = data["dni"] as String? ?? '';
    final imagen = data["imagen"] as String? ?? '';
    final numeroSSocial = data["numeroSeguridadSocial"] as String? ?? '';
    final sexo = data["sexo"] as String? ?? '';
    final fechaNacimiento = DateTime.parse(data["fechaNacimiento"] as String);

    final token = data["token"] as String? ?? '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('nombre', nombre);

    if (rol == 'MEDICO') {
      return Medico(
        especialidad: data["especialidad"] as String? ?? '',
        centroDeSalud:
            data["centroDeSalud"] != null
                ? CentroDeSalud.fromJson(
                  data["centroDeSalud"] as Map<String, dynamic>,
                )
                : null,
        id: id,
        nombre: nombre,
        apellido: apellido,
        email: emailResp,
        contrasenya: contrasenya,
        telefono: telefono,
        activo: activo,
        rol: rol,
        direccion: direccion,
        dni: dni,
        imagen: imagen,
        numeroSeguridadSocial: numeroSSocial,
        sexo: sexo,
        fechaNacimiento: fechaNacimiento,
      );
    }

    return Usuario(
      id: id,
      nombre: nombre,
      apellido: apellido,
      email: emailResp,
      contrasenya: contrasenya,
      telefono: telefono,
      activo: activo,
      rol: rol,
      direccion: direccion,
      dni: dni,
      imagen: imagen,
      numeroSeguridadSocial: numeroSSocial,
      sexo: sexo,
      fechaNacimiento: fechaNacimiento,
    );
  }

  static Future<Usuario> registrarPaciente({
    required Usuario usuario,
    File? archivo,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/api/auth/registrarPaciente');
    final request = http.MultipartRequest('POST', uri);
    final fechaFormateada = DateFormat(
      'yyyy-MM-dd',
    ).format(usuario.fechaNacimiento);

    request.fields.addAll({
      'nombre': usuario.nombre,
      'apellidos': usuario.apellido,
      'email': usuario.email,
      'contrasenya': usuario.contrasenya,
      'telefono': usuario.telefono,
      'rol': usuario.rol,
      'direccion': usuario.direccion,
      'dni': usuario.dni,
      'numeroSeguridadSocial': usuario.numeroSeguridadSocial,
      'sexo': usuario.sexo,
      'fechaNacimiento': fechaFormateada,
    });

    if (archivo != null && await archivo.exists()) {
      final multipartFile = await http.MultipartFile.fromPath(
        'archivo',
        archivo.path,
        filename: archivo.path.split(Platform.pathSeparator).last,
      );
      request.files.add(multipartFile);
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final rawBody = response.body;

    if (response.statusCode == 200) {
      if (rawBody.isEmpty) {
        throw Exception('El servidor devolvió una respuesta vacía');
      }
      Map<String, dynamic> body;
      try {
        body = jsonDecode(rawBody) as Map<String, dynamic>;
      } catch (e) {
        throw Exception('Error al parsear la respuesta JSON: \$e');
      }
      final data = body['data'] as Map<String, dynamic>;

      final patchedData = <String, dynamic>{
        'id': data['id'] ?? usuario.id,
        'nombre': data['nombre'] ?? usuario.nombre,
        'apellido': data['apellido'] ?? usuario.apellido,
        'email': data['email'] ?? usuario.email,
        'contrasenya': usuario.contrasenya,
        'telefono': data['telefono'] ?? usuario.telefono,
        'activo': data['activo'] ?? usuario.activo,
        'rol': data['rol'] ?? usuario.rol,
        'direccion': data['direccion'] ?? usuario.direccion,
        'dni': data['dni'] ?? usuario.dni,
        'imagen':
            (data['imagen'] as String?)?.isNotEmpty == true
                ? data['imagen']
                : 'assets/imgs/imagenDefault.webp',
        'numeroSeguridadSocial':
            data['numeroSeguridadSocial'] ?? usuario.numeroSeguridadSocial,
        'sexo': data['sexo'] ?? usuario.sexo,
        'fechaNacimiento': data['fechaNacimiento'] ?? fechaFormateada,
      };

      return Usuario.fromJson(patchedData);
    } else {
      String mensaje = 'Error en el servidor';
      if (rawBody.isNotEmpty) {
        try {
          final error = jsonDecode(rawBody) as Map<String, dynamic>;
          mensaje = error['mensaje'] ?? mensaje;
        } catch (e) {
          print('Error parseando JSON de error: $e');
        }
      }
      throw Exception('Registro fallido: $mensaje');
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}
