# Calculadora de Calidad del Aire - Flutter

Aplicación desarrollada para la Evaluación 3 de Programación de Dispositivos Móviles
(Institución Universitaria Pascual Bravo).

## Funcionalidad

- Seleccionar una ciudad de Colombia.
- Seleccionar una fecha (selector de calendario, formato `YYYY-MM-DD`).
- Ingresar las horas promedio de exposición al aire libre.
- Consulta asíncrona a la API Open-Meteo Air Quality.
- Cálculo del promedio diario de PM2.5 a partir de los valores horarios.
- Cálculo del índice:

```
indice_exposicion = promedio_PM2_5 × horas_exposicion
```

- Clasificación del riesgo:

| Valor del índice | Nivel de riesgo |
|------------------|-----------------|
| < 100            | Bajo            |
| 100 – 200        | Moderado        |
| > 200            | Alto            |

## Ejecutar

1. Instalar Flutter y Android Studio o VS Code.
2. Clonar el repositorio y abrir la carpeta en el IDE.
3. Si faltan las carpetas de plataforma (`android/`, `ios/`), generarlas con:

```bash
flutter create .
```

4. Instalar dependencias y ejecutar:

```bash
flutter pub get
flutter run
```

Para correr las pruebas: `flutter test`.

## API

Open-Meteo Air Quality API: https://open-meteo.com/en/docs/air-quality-api

Endpoint usado:

```
https://air-quality-api.open-meteo.com/v1/air-quality?latitude=..&longitude=..&hourly=pm2_5&start_date=YYYY-MM-DD&end_date=YYYY-MM-DD
```

No requiere API key.

## Estructura

- `lib/main.dart`: interfaz y flujo principal.
- `lib/models/city.dart`: modelo `City` y lista de ciudades.
- `lib/models/exposure_risk.dart`: cálculo del índice y clasificación del riesgo.
- `lib/services/air_quality_service.dart`: consumo de Open-Meteo, manejo de errores y timeout.
- `test/widget_test.dart`: pruebas de la pantalla y de la clasificación.
