import 'package:flutter_test/flutter_test.dart';
import 'package:calidad_aire_flutter/main.dart';
import 'package:calidad_aire_flutter/models/exposure_risk.dart';

void main() {
  testWidgets('La pantalla principal se muestra', (WidgetTester tester) async {
    await tester.pumpWidget(const AirQualityApp());

    expect(find.text('Calculadora Calidad del Aire'), findsOneWidget);
    expect(find.text('Índice de exposición diaria'), findsOneWidget);
    expect(find.text('Bogotá'), findsOneWidget);
    expect(find.text('Calcular nivel de riesgo'), findsOneWidget);
  });

  group('Clasificacion del riesgo', () {
    test('menor que 100 es Bajo', () {
      expect(classifyExposure(40.6), RiskLevel.bajo);
      expect(classifyExposure(99.99), RiskLevel.bajo);
    });

    test('de 100 a 200 es Moderado', () {
      expect(classifyExposure(100), RiskLevel.moderado);
      expect(classifyExposure(120), RiskLevel.moderado);
      expect(classifyExposure(200), RiskLevel.moderado);
    });

    test('mayor que 200 es Alto', () {
      expect(classifyExposure(200.01), RiskLevel.alto);
      expect(classifyExposure(350), RiskLevel.alto);
    });

    test('indice = promedio PM2.5 x horas', () {
      expect(calculateExposureIndex(8.12, 5), closeTo(40.6, 0.001));
    });
  });
}
