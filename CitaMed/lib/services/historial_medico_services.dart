import 'dart:convert';

import 'package:CitaMed/DTO/cita_con_historial_dto.dart';
import 'package:CitaMed/config/api_config.dart';
import 'package:CitaMed/infrastructures/models/cita.dart';
import 'package:CitaMed/infrastructures/models/historial_medico.dart';
import 'package:CitaMed/utils/estado_utils.dart';
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
      'cita': {'id': historial.cita?.id},
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

    if (response.statusCode == 200 || response.statusCode == 201) {
      final map = json.decode(response.body) as Map<String, dynamic>;
      return HistorialMedico.fromJson(map['data'] as Map<String, dynamic>);
    } else {
      final msg = extractError(response);
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
      final msg = extractError(response);
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
      final msg = extractError(response);
      throw Exception('Error al obtener historiales médicos: $msg');
    }
  }

  Future<Map<String, List<dynamic>>> obtenerHistorialCompleto(
    int pacienteId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/medico/historialCompleto/$pacienteId',
    );

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final bodyMap = json.decode(response.body) as Map<String, dynamic>;

      final historialJson = bodyMap['historial'] as List<dynamic>? ?? [];
      final historiales =
          historialJson
              .map((e) => HistorialMedico.fromJson(e as Map<String, dynamic>))
              .toList();

      final citasJson = bodyMap['citas'] as List<dynamic>? ?? [];
      final citas =
          citasJson
              .map((e) => Cita.fromJson(e as Map<String, dynamic>))
              .toList();

      return {'historial': historiales, 'citas': citas};
    } else {
      final msg = extractError(response);
      throw Exception('Error al obtener historial completo: $msg');
    }
  }

  Future<List<CitaConHistorial>> obtenerCitasConHistorial(
    int pacienteId,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/medico/citasConHistorial/$pacienteId',
    );

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final bodyMap = json.decode(response.body) as Map<String, dynamic>;
      final listJson = bodyMap['data'] as List<dynamic>? ?? [];
      return listJson
          .map((e) => CitaConHistorial.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      final msg = extractError(response);
      throw Exception('Error al obtener citas con historial: $msg');
    }
  }
}
