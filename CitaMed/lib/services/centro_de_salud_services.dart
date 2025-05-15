import 'dart:convert';

import 'package:CitaMed/config/api_config.dart';
import 'package:CitaMed/infrastructures/models/centro_de_salud.dart';
import 'package:http/http.dart' as http;

class CentroDeSaludServices {
  Future<List<CentroDeSalud>> listarCentrosDeSalud() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/auth/listaCentros');
    final response = await http.get(
      url,
      headers: {'Accept': 'application/json'},
    );
    final Map<String, dynamic> responseData =
        json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode != 200) {
      throw Exception(
        responseData["mensaje"] ?? "Error en el login: ${response.statusCode}",
      );
    }

    final data = responseData["data"] as List<dynamic>? ?? [];

    return data
        .map((e) => CentroDeSalud.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
