/// Niveles de riesgo segun el indice de exposicion.
enum RiskLevel { bajo, moderado, alto }

extension RiskLevelLabel on RiskLevel {
  String get label {
    switch (this) {
      case RiskLevel.bajo:
        return 'Bajo';
      case RiskLevel.moderado:
        return 'Moderado';
      case RiskLevel.alto:
        return 'Alto';
    }
  }
}

/// indice_exposicion = promedio_PM2_5 * horas_exposicion
double calculateExposureIndex(double averagePm25, double hours) {
  return averagePm25 * hours;
}

/// Clasificacion:
///  - indice < 100        -> Bajo
///  - 100 <= indice <= 200 -> Moderado
///  - indice > 200        -> Alto
RiskLevel classifyExposure(double index) {
  if (index < 100) return RiskLevel.bajo;
  if (index <= 200) return RiskLevel.moderado;
  return RiskLevel.alto;
}
