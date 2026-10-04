import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class AirQualityResult {
  final double averagePm25;
  final List<double> hourlyValues;

  const AirQualityResult({
    required this.averagePm25,
    required this.hourlyValues,
  });
}

class AirQualityService {
  static const String _baseUrl =
      'https://air-quality-api.open-meteo.com/v1/air-quality';

  static const Duration _timeout = Duration(seconds: 15);

  /// Consulta Open-Meteo y devuelve el promedio diario de PM2.5.
  Future<AirQualityResult> getDailyPm25({
    required double latitude,
    required double longitude,
    required String date,
  }) async {
    final uri = Uri.parse(_baseUrl).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'hourly': 'pm2_5',
        'start_date': date,
        'end_date': date,
        'timezone': 'auto',
      },
    );

    final http.Response response;
    try {
      response = await http.get(uri).timeout(_timeout);
    } on TimeoutException {
      throw Exception('Tiempo de espera agotado. Intenta de nuevo.');
    } on http.ClientException {
      throw Exception('No hay conexion a internet.');
    }

    if (response.statusCode != 200) {
      throw Exception(
        'La API respondio con codigo ${response.statusCode}.',
      );
    }

    final Map<String, dynamic> data = jsonDecode(response.body);

    final hourly = data['hourly'];
    if (hourly is! Map<String, dynamic>) {
      throw Exception('La respuesta de la API no contiene datos horarios.');
    }

    // Se ignoran los valores null que la API puede devolver.
    final values = (hourly['pm2_5'] as List?)
            ?.whereType<num>()
            .map((value) => value.toDouble())
            .where((value) => value.isFinite && value >= 0)
            .toList() ??
        <double>[];

    if (values.isEmpty) {
      throw Exception('No se encontraron datos de PM2.5 para esa fecha.');
    }

    final average = values.reduce((a, b) => a + b) / values.length;

    return AirQualityResult(
      averagePm25: average,
      hourlyValues: values,
    );
  }
}
