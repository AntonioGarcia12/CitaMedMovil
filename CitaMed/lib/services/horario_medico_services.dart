import 'dart:convert';

import 'package:citamed/config/api_config.dart';
import 'package:citamed/infrastructures/models/horario_medico.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HorarioMedicoServices {
  Future<HorarioMedico> crearHorarioMedico(HorarioMedico horario) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final uri = Uri.parse('${ApiConfig.baseUrl}/medico/crearHorario');

    final payload = {
      'medico': {'id': horario.medico.id},
      'dia': DateFormat('yyyy-MM-dd').format(horario.dia),
      'horaInicio': DateFormat('HH:mm').format(horario.horaInicio),
      'horaFin': DateFormat('HH:mm').format(horario.horaFin),
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
      final data = (json.decode(response.body) as Map<String, dynamic>)['data'];
      return HorarioMedico.fromJson(data as Map<String, dynamic>);
    } else {
      String msg = 'Error al crear horario';
      try {
        final err = json.decode(response.body) as Map<String, dynamic>;
        msg = err['mensaje'] as String? ?? msg;
      } catch (_) {}
      throw Exception(msg);
    }
  }

  Future<List<HorarioMedico>> obtenerHorarios(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final uri = Uri.parse('${ApiConfig.baseUrl}/medico/horarios/$id');

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final bodyMap = json.decode(response.body) as Map<String, dynamic>;
      final list = bodyMap['data'] as List<dynamic>? ?? [];
      return list
          .map((e) => HorarioMedico.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      final msg = _extractError(response);
      throw Exception('Error al obtener horarios: $msg');
    }
  }

  Future<HorarioMedico> editarHorario(int id, HorarioMedico horario) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final uri = Uri.parse('${ApiConfig.baseUrl}/medico/editarHorario/$id');

    final payload = {
      'medico': {'id': horario.medico.id},
      'dia': DateFormat('yyyy-MM-dd').format(horario.dia),
      'horaInicio': DateFormat('HH:mm').format(horario.horaInicio),
      'horaFin': DateFormat('HH:mm').format(horario.horaFin),
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
      final bodyMap = json.decode(response.body) as Map<String, dynamic>;
      return HorarioMedico.fromJson(bodyMap['data'] as Map<String, dynamic>);
    } else {
      final msg = _extractError(response);
      throw Exception('Error al editar horario: $msg');
    }
  }

  Future<void> borrarHorario(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final uri = Uri.parse('${ApiConfig.baseUrl}/medico/eliminarHorario/$id');

    final response = await http.delete(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      final msg = _extractError(response);
      throw Exception('Error al eliminar horario: $msg');
    }
  }

  Future<HorarioMedico> obtenerHorarioPorId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/medico/obtenerHorarioPorId/$id',
    );

    final response = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    final body = response.body;
    if (response.statusCode == 200) {
      final bodyMap = json.decode(body) as Map<String, dynamic>;
      final data = bodyMap['data'] as Map<String, dynamic>;
      return HorarioMedico.fromJson(data);
    } else {
      final msg = _extractError(response);
      throw Exception('Error al obtener horario: $msg');
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

  obtenerHorarioMedico(int horarioId) {}
}
