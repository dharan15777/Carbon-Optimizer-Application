class Sensor {
  final String id;
  final String cityId;
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final bool isActive;
  final DateTime lastReading;

  Sensor({
    required this.id,
    required this.cityId,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    this.isActive = true,
    required this.lastReading,
  });

  factory Sensor.fromJson(Map<String, dynamic> json) {
    return Sensor(
      id: json['id'],
      cityId: json['cityId'],
      name: json['name'],
      type: json['type'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      isActive: json['isActive'] ?? true,
      lastReading: DateTime.parse(json['lastReading']),
    );
  }
}

class SensorData {
  final String sensorId;
  final double co2;
  final double pm25;
  final double pm10;
  final double temperature;
  final double humidity;
  final DateTime timestamp;

  SensorData({
    required this.sensorId,
    required this.co2,
    required this.pm25,
    required this.pm10,
    required this.temperature,
    required this.humidity,
    required this.timestamp,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      sensorId: json['sensorId'],
      co2: (json['co2'] as num).toDouble(),
      pm25: (json['pm25'] as num).toDouble(),
      pm10: (json['pm10'] as num).toDouble(),
      temperature: (json['temperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
