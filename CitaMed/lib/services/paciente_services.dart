import 'dart:convert';
import 'dart:io';

import 'package:CitaMed/DTO/paciente_dto.dart';
import 'package:CitaMed/config/api_config.dart';
import 'package:CitaMed/infrastructures/models/usuario.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PacienteServices {
  Future<Usuario> editarPaciente({
    required Usuario usuarioActual,
    required PacienteDto cambios,
    File? archivo,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/paciente/editarPaciente/${usuarioActual.id}',
    );

    final request = http.MultipartRequest('PUT', uri)
      ..headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });

    if (cambios.telefono != null) {
      request.fields['telefono'] = cambios.telefono!;
    }
    if (cambios.direccion != null) {
      request.fields['direccion'] = cambios.direccion!;
    }
    if (cambios.imagen != null) request.fields['imagen'] = cambios.imagen!;

    if (archivo != null && await archivo.exists()) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'archivo',
          archivo.path,
          filename: archivo.path.split(Platform.pathSeparator).last,
        ),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    final body = response.body;

    if (response.statusCode == 200) {
      final data =
          (json.decode(body) as Map<String, dynamic>)['data']
              as Map<String, dynamic>;

      final patch = PacienteDto.fromJson(data);

      return usuarioActual.copyWith(
        telefono: patch.telefono,
        direccion: patch.direccion,
        imagen: patch.imagen,
      );
    }

    String msg = 'Error al editar paciente';
    try {
      msg = (json.decode(body) as Map<String, dynamic>)['mensaje'] ?? msg;
    } catch (_) {}
    throw Exception(msg);
  }

  Future<Usuario> listarUnPaciente(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final uri = Uri.parse('${ApiConfig.baseUrl}/paciente/listarUnPaciente/$id');

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

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
