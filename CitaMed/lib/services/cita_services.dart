import 'dart:convert';

import 'package:CitaMed/config/api_config.dart';
import 'package:CitaMed/infrastructures/models/cita.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CitaServices {
  Future<Cita> crearCita({required Cita cita, required int id}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final uri = Uri.parse('${ApiConfig.baseUrl}/paciente/crearCita/$id');

    final payload = {
      'idMedico': cita.idMedico.id,
      'idCentro': cita.idCentro.id,
      'fecha': cita.fecha.toIso8601String(),
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

    final body = response.body;
    if (response.statusCode == 200) {
      final map = json.decode(body) as Map<String, dynamic>;
      final data = map['data'] as Map<String, dynamic>;
      return Cita.fromJson(data);
    } else {
      String msg;
      try {
        final err = json.decode(body) as Map<String, dynamic>;
        msg = err['mensaje'] as String? ?? 'Código ${response.statusCode}';
      } catch (_) {
        msg = 'Código ${response.statusCode}';
      }
      throw Exception('Error al crear cita: $msg');
    }
  }

  Future<List<Cita>> obtenerHistorialCitas(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final uri = Uri.parse('${ApiConfig.baseUrl}/paciente/historialCitas/$id');

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    final body = response.body;
    if (response.statusCode == 200) {
      final map = json.decode(body) as Map<String, dynamic>;
      final list = map['data'] as List<dynamic>? ?? [];
      return list.map((e) => Cita.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      String msg;
      try {
        final err = json.decode(body) as Map<String, dynamic>;
        msg = err['mensaje'] as String? ?? 'Código ${response.statusCode}';
      } catch (_) {
        msg = 'Código ${response.statusCode}';
      }
      throw Exception('Error al obtener historial de citas: $msg');
    }
  }

  Future<List<Cita>> obtenerCitasDeUnMedico() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final uri = Uri.parse('${ApiConfig.baseUrl}/medico/listadoCitas');

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Error ${response.statusCode}');
    }

    final Map<String, dynamic> map = json.decode(response.body);
    final citasJson = map['citas'] as List? ?? [];
    return citasJson
        .map((e) => Cita.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> actualizarEstadoCitaMedico(int idCita, String estado) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/medico/actualizarEstadoCita/$idCita?estado=$estado',
    );
    final response = await http.put(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );
    if (response.statusCode != 200) {
      throw Exception('Error al actualizar estado: ${response.statusCode}');
    }
  }

  Future<void> cancelarCitaPaciente({
    required int citaId,
    required int pacienteId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/paciente/cancelarCita/$citaId?'
      'idPaciente=$pacienteId',
    );

    final response = await http.put(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      String msg;
      try {
        final err = json.decode(response.body) as Map<String, dynamic>;
        msg = err['mensaje'] as String? ?? 'Código ${response.statusCode}';
      } catch (_) {
        msg = 'Código ${response.statusCode}';
      }
      throw Exception('Error al cancelar cita: $msg');
    }
  }

  Future<Cita> editarCita({required Cita cita, required int citaId}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final uri = Uri.parse('${ApiConfig.baseUrl}/medico/editarCita/$citaId');

    final payload = {
      'id': cita.id,
      'fecha': cita.fecha.toIso8601String(),
      'idMedico': cita.idMedico.id,
      'idCentro': cita.idCentro.id,
      'estado': cita.estado,
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
      return Cita.fromJson(map['data'] as Map<String, dynamic>);
    } else {
      final msg = _extractError(response);
      throw Exception('Error al editar cita: $msg');
    }
  }

  Future<Cita> obtenerCitaPorId(int citaId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final uri = Uri.parse('${ApiConfig.baseUrl}/medico/citas/$citaId');

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final map = json.decode(response.body) as Map<String, dynamic>;
      return Cita.fromJson(map['data'] as Map<String, dynamic>);
    } else {
      final msg = _extractError(response);
      throw Exception('Error al obtener cita: $msg');
    }
  }

  String _extractError(http.Response response) {
    try {
      final err = json.decode(response.body) as Map<String, dynamic>;
      return err['mensaje'] as String? ?? 'Código ${response.statusCode}';
    } catch (_) {
      return 'Código ${response.statusCode}';
    }
  }
}
