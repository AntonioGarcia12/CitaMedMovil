import 'dart:convert';

import 'package:citamed/config/api_config.dart';
import 'package:citamed/infrastructures/models/historial_medico.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HistorialMedicoServices {
  Future<HistorialMedico> crearHistorialMedico(
    HistorialMedico historial,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final uri = Uri.parse('${ApiConfig.baseUrl}/medico/crearHistorial');

    final payload = {
      'medico': {'id': historial.medico.id},
      'paciente': {'id': historial.paciente.id},
      'diagnostico': historial.diagnostico,
      'tratamiento': historial.tratamiento,
    };

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      final map = json.decode(response.body) as Map<String, dynamic>;
      return HistorialMedico.fromJson(map['data'] as Map<String, dynamic>);
    } else {
      final msg = _extractError(response);
      throw Exception('Error al crear historial: $msg');
    }
  }

  Future<List<HistorialMedico>> obtenerHistorialPaciente(int pacienteId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final uri = Uri.parse('${ApiConfig.baseUrl}/medico/historial/$pacienteId');

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final map = json.decode(response.body) as Map<String, dynamic>;
      final list = map['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => HistorialMedico.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      final msg = _extractError(response);
      throw Exception('Error al obtener historial de paciente: $msg');
    }
  }

  Future<List<HistorialMedico>> obtenerHistorialesMedicos() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final uri = Uri.parse('${ApiConfig.baseUrl}/medico/historiales');

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final map = json.decode(response.body) as Map<String, dynamic>;
      final list = map['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => HistorialMedico.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      final msg = _extractError(response);
      throw Exception('Error al obtener historiales médicos: $msg');
    }
  }

  Future<void> borrarhistorial(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/medico/borrarHistorialMedico/$id',
    );

    final response = await http.delete(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      final msg = _extractError(response);
      throw Exception('Error al eliminar horario: $msg');
    }
  }

  Future<HistorialMedico> editarHistorial(
    int id,
    HistorialMedico historial,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/medico/editarHistorialMedico/$id',
    );

    final payload = {
      'medico': {'id': historial.medico.id},
      'paciente': {'id': historial.paciente.id},
      'diagnostico': historial.diagnostico,
      'tratamiento': historial.tratamiento,
    };

    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(payload),
    );

    if (response.statusCode == 200) {
      final map = json.decode(response.body) as Map<String, dynamic>;
      return HistorialMedico.fromJson(map['data'] as Map<String, dynamic>);
    } else {
      final msg = _extractError(response);
      throw Exception('Error al editar historial: $msg');
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
