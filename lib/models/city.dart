class City {
  final String name;
  final double latitude;
  final double longitude;

  const City({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

const colombianCities = <City>[
  City(name: 'Bogotá', latitude: 4.7110, longitude: -74.0721),
  City(name: 'Medellín', latitude: 6.2442, longitude: -75.5812),
  City(name: 'Cali', latitude: 3.4516, longitude: -76.5320),
  City(name: 'Barranquilla', latitude: 10.9685, longitude: -74.7813),
  City(name: 'Cartagena', latitude: 10.3910, longitude: -75.4794),
  City(name: 'Bucaramanga', latitude: 7.1193, longitude: -73.1227),
  City(name: 'Pereira', latitude: 4.8143, longitude: -75.6946),
  City(name: 'Manizales', latitude: 5.0703, longitude: -75.5138),
];
