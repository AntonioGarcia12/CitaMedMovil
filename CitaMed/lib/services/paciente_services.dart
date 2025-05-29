import 'dart:convert';
import 'dart:io';

import 'package:CitaMed/DTO/paciente_dto.dart';
import 'package:CitaMed/config/api_config.dart';
import 'package:CitaMed/infrastructures/models/horario_medico.dart';
import 'package:CitaMed/infrastructures/models/medico.dart';
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

  Future<List<HorarioMedico>> obtenerDisponibilidad(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final uri = Uri.parse('${ApiConfig.baseUrl}/paciente/disponibilidad/$id');

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final bodyMap = json.decode(response.body) as Map<String, dynamic>;
      final list = bodyMap['data'] as List<dynamic>? ?? [];

      final todos =
          list
              .map((e) => HorarioMedico.fromJson(e as Map<String, dynamic>))
              .toList();

      final now = DateTime.now();

      final futuros =
          todos.where((h) {
            final inicioCompleto = DateTime(
              h.dia.year,
              h.dia.month,
              h.dia.day,
              h.horaInicio.hour,
              h.horaInicio.minute,
              h.horaInicio.second,
            );

            return inicioCompleto.isAtSameMomentAs(now) ||
                inicioCompleto.isAfter(now);
          }).toList();

      futuros.sort((a, b) {
        final inicioA = DateTime(
          a.dia.year,
          a.dia.month,
          a.dia.day,
          a.horaInicio.hour,
          a.horaInicio.minute,
          a.horaInicio.second,
        );
        final inicioB = DateTime(
          b.dia.year,
          b.dia.month,
          b.dia.day,
          b.horaInicio.hour,
          b.horaInicio.minute,
          b.horaInicio.second,
        );
        return inicioA.compareTo(inicioB);
      });

      return futuros;
    }
    if (response.statusCode == 404) {
      return <HorarioMedico>[];
    }

    final msg = _extractError(response);
    throw Exception('Error al obtener disponibilidad: $msg');
  }

  Future<Medico> listarUnMedico(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final uri = Uri.parse('${ApiConfig.baseUrl}/paciente/listarUnMedico/$id');

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    final body = response.body;
    if (response.statusCode == 200) {
      final jsonMap = json.decode(body) as Map<String, dynamic>;
      final data = jsonMap['data'] as Map<String, dynamic>;
      return Medico.fromJson(data);
    } else {
      String msg = 'Error al obtener medico';
      try {
        final err = json.decode(body) as Map<String, dynamic>;
        msg = err['mensaje'] ?? msg;
      } catch (_) {}
      throw Exception(msg);
    }
  }

  String _extractError(http.Response response) {
    try {
      final map = json.decode(response.body) as Map<String, dynamic>;
      return map['mensaje'] as String? ?? 'Código ${response.statusCode}';
    } catch (_) {
      return 'Código ${response.statusCode}';
    }
  }
}
