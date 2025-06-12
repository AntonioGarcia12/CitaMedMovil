import 'dart:convert';

import 'package:CitaMed/config/api_config.dart';
import 'package:CitaMed/infrastructures/models/horario_medico.dart';
import 'package:CitaMed/utils/estado_utils.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HorarioMedicoServices {
  Future<List<HorarioMedico>> obtenerHorarios(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final uri = Uri.parse('${ApiConfig.baseUrl}/medico/horarios/$id');

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
    } else {
      final msg = extractError(response);
      throw Exception(msg);
    }
  }
}
