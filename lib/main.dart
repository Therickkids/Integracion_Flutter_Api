import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'models/city.dart';
import 'models/exposure_risk.dart';
import 'services/air_quality_service.dart';

void main() {
  runApp(const AirQualityApp());
}

class AirQualityApp extends StatelessWidget {
  const AirQualityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Calculadora Calidad del Aire',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.light,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const AirQualityHomePage(),
    );
  }
}

class AirQualityHomePage extends StatefulWidget {
  const AirQualityHomePage({super.key});

  @override
  State<AirQualityHomePage> createState() => _AirQualityHomePageState();
}

class _AirQualityHomePageState extends State<AirQualityHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _hoursController = TextEditingController();

  final _service = AirQualityService();

  City _selectedCity = colombianCities.first;
  DateTime _selectedDate = DateTime.now();

  bool _loading = false;
  String? _errorMessage;
  double? _averagePm25;
  double? _exposureIndex;
  RiskLevel? _riskLevel;

  @override
  void dispose() {
    _hoursController.dispose();
    super.dispose();
  }

  String get _formattedDate => DateFormat('yyyy-MM-dd').format(_selectedDate);

  void _clearResult() {
    _errorMessage = null;
    _averagePm25 = null;
    _exposureIndex = null;
    _riskLevel = null;
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      // La API global de calidad del aire tiene datos desde mediados de 2022.
      firstDate: DateTime(2022, 8, 1),
      lastDate: DateTime.now(),
      helpText: 'Selecciona la fecha de consulta',
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
        _clearResult();
      });
    }
  }

  Future<void> _calculateIndex() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final hours = double.parse(
      _hoursController.text.trim().replaceAll(',', '.'),
    );

    setState(() {
      _loading = true;
      _clearResult();
    });

    try {
      final result = await _service.getDailyPm25(
        latitude: _selectedCity.latitude,
        longitude: _selectedCity.longitude,
        date: _formattedDate,
      );

      final index = calculateExposureIndex(result.averagePm25, hours);
      final risk = classifyExposure(index);

      if (!mounted) return;

      setState(() {
        _averagePm25 = result.averagePm25;
        _exposureIndex = index;
        _riskLevel = risk;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            'No fue posible consultar la calidad del aire.\n${error.toString().replaceFirst('Exception: ', '')}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Color _riskColor() {
    switch (_riskLevel) {
      case RiskLevel.bajo:
        return Colors.green;
      case RiskLevel.moderado:
        return Colors.orange;
      case RiskLevel.alto:
        return Colors.red;
      case null:
        return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculadora Calidad del Aire'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.air,
                  size: 64,
                  color: Colors.teal,
                ),
                const SizedBox(height: 8),
                Text(
                  'Índice de exposición diaria',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),

                // Ciudad
                DropdownButtonFormField<City>(
                  // ignore: deprecated_member_use
                  value: _selectedCity,
                  decoration: const InputDecoration(
                    labelText: 'Ciudad',
                    prefixIcon: Icon(Icons.location_city),
                  ),
                  items: colombianCities.map((city) {
                    return DropdownMenuItem<City>(
                      value: city,
                      child: Text(city.name),
                    );
                  }).toList(),
                  onChanged: _loading
                      ? null
                      : (city) {
                          if (city == null) return;
                          setState(() {
                            _selectedCity = city;
                            _clearResult();
                          });
                        },
                ),

                const SizedBox(height: 18),

                // Fecha (se elige con el selector de calendario)
                TextFormField(
                  key: ValueKey(_formattedDate),
                  initialValue: _formattedDate,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Fecha de consulta',
                    prefixIcon: Icon(Icons.calendar_month),
                  ),
                  onTap: _loading ? null : _pickDate,
                ),

                const SizedBox(height: 18),

                // Horas de exposicion
                TextFormField(
                  controller: _hoursController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Horas de exposición diaria',
                    hintText: 'Ejemplo: 5',
                    prefixIcon: Icon(Icons.schedule),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa las horas de exposición.';
                    }

                    final hours = double.tryParse(
                      value.trim().replaceAll(',', '.'),
                    );

                    if (hours == null) {
                      return 'Ingresa un número válido.';
                    }

                    if (hours <= 0 || hours > 24) {
                      return 'Las horas deben estar entre 0 y 24.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 24),

                FilledButton.icon(
                  onPressed: _loading ? null : _calculateIndex,
                  icon: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.calculate),
                  label: Text(
                    _loading ? 'Consultando API...' : 'Calcular nivel de riesgo',
                  ),
                ),

                const SizedBox(height: 20),

                if (_errorMessage != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),

                if (_exposureIndex != null && _riskLevel != null)
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Text(
                            'Resultado',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Índice de exposición: ${_exposureIndex!.toStringAsFixed(1)}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _riskColor(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Nivel de riesgo: ${_riskLevel!.label}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: _riskColor(),
                            ),
                          ),
                          const Divider(height: 28),
                          Text(
                            'Promedio diario de PM2.5: ${_averagePm25!.toStringAsFixed(2)} µg/m³',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ciudad: ${_selectedCity.name}',
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'Fecha: $_formattedDate',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 20),

                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Clasificación',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text('• Menor que 100 → Bajo'),
                        Text('• 100 a 200 → Moderado'),
                        Text('• Mayor que 200 → Alto'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
