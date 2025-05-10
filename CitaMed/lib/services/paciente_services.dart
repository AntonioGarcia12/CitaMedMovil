import 'dart:convert';
import 'dart:io';

import 'package:citamed/config/api_config.dart';
import 'package:citamed/infrastructures/models/usuario.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para operaciones de paciente (editar y obtener uno solo).
class PacienteServices {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  Future<Usuario> editarPaciente({
    required Usuario usuario,
    File? archivo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/paciente/editarPaciente/${usuario.id}',
    );

    final request = http.MultipartRequest('PUT', uri)
      ..headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });

    final fechaStr = _dateFormat.format(usuario.fechaNacimiento);

    request.fields.addAll({
      'nombre': usuario.nombre,
      'apellido': usuario.apellido,
      'email': usuario.email,
      'contrasenya': usuario.contrasenya ?? '',
      'telefono': usuario.telefono,
      'activo': usuario.activo.toString(),
      'rol': usuario.rol,
      'direccion': usuario.direccion,
      'dni': usuario.dni,
      'numeroSeguridadSocial': usuario.numeroSeguridadSocial,
      'sexo': usuario.sexo,
      'fechaNacimiento': fechaStr,
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
    final body = response.body;

    if (response.statusCode == 200) {
      final jsonMap = json.decode(body) as Map<String, dynamic>;
      final data = jsonMap['data'] as Map<String, dynamic>;
      return Usuario.fromJson(data);
    } else {
      String msg = 'Error al editar paciente';
      try {
        final err = json.decode(body) as Map<String, dynamic>;
        msg = err['mensaje'] ?? msg;
      } catch (_) {}
      throw Exception(msg);
    }
  }

  Future<Usuario> listarUnPaciente(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final uri = Uri.parse('${ApiConfig.baseUrl}/paciente/listarUnPaciente/$id');

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    final rawBytes = response.bodyBytes;
    final bodyString = utf8.decode(rawBytes, allowMalformed: true);
    debugPrint('▶️ Status: ${response.statusCode}');
    debugPrint('▶️ Raw body: $bodyString');
    print('listarUnPaciente status: ${response.statusCode}');
    print('listarUnPaciente body: ${response.body}');

    final body = response.body;
    if (response.statusCode == 200) {
      final jsonMap = json.decode(body) as Map<String, dynamic>;
      final data = jsonMap['data'] as Map<String, dynamic>;
      return Usuario.fromJson(data);
    } else {
      String msg = 'Error al obtener paciente';
      try {
        final err = json.decode(body) as Map<String, dynamic>;
        msg = err['mensaje'] ?? msg;
      } catch (_) {}
      throw Exception(msg);
    }
  }
}
