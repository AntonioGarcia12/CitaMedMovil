import 'dart:convert';

import 'package:citamed/config/api_config.dart';
import 'package:citamed/infrastructures/models/medico.dart';
import 'package:citamed/infrastructures/models/usuario.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MedicoService {
  Future<Medico> listarUnMedico(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final uri = Uri.parse('${ApiConfig.baseUrl}/medico/listarUnMedico/$id');

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

  Future<List<Medico>> listarMedicos() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/auth/listaMedicos');
    final response = await http.get(
      url,
      headers: {'Accept': 'application/json'},
    );
    final Map<String, dynamic> responseData =
        json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw Exception(
        responseData["mensaje"] ??
            "Error al obtener medicos: ${response.statusCode}",
      );
    }

    final data = responseData["data"] as List<dynamic>? ?? [];

    return data.map((e) => Medico.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Usuario>> obtenerPacientes() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final uri = Uri.parse('${ApiConfig.baseUrl}/medico/obtenerPacientes');

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    final Map<String, dynamic> responseData =
        json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw Exception(
        responseData['mensaje'] as String? ?? 'Error ${response.statusCode}',
      );
    }

    final List<dynamic> data = responseData['data'] as List<dynamic>? ?? [];

    return data
        .map((e) => Usuario.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<String>> buscarPorEspecialidad() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/paciente/buscarPorEspecialidad',
    );

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    final Map<String, dynamic> responseData =
        json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw Exception(
        responseData['mensaje'] as String? ?? 'Error ${response.statusCode}',
      );
    }
    final List<dynamic> data = responseData['data'] as List<dynamic>? ?? [];

    return data.map((e) => e as String).toList();
  }
}
