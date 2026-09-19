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
      sensorId: json['sensorId'] ?? '',
      co2: (json['co2'] as num?)?.toDouble() ?? 400.0,
      pm25: (json['pm25'] as num?)?.toDouble() ?? 25.0,
      pm10: (json['pm10'] as num?)?.toDouble() ?? 45.0,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 28.0,
      humidity: (json['humidity'] as num?)?.toDouble() ?? 50.0,
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
    );
  }
}

class IndustrialSensor {
  final String id;
  final String name;
  final String parameter;
  final double value;
  final String unit;
  final String location;
  final String status; // NORMAL, WARNING, CRITICAL
  final String threshold;
  final String reason;
  final double latitude;
  final double longitude;

  const IndustrialSensor({
    required this.id,
    required this.name,
    required this.parameter,
    required this.value,
    required this.unit,
    required this.location,
    required this.status,
    required this.threshold,
    required this.reason,
    required this.latitude,
    required this.longitude,
  });

  factory IndustrialSensor.fromJson(Map<String, dynamic> json) {
    return IndustrialSensor(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      parameter: json['parameter'] ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? '',
      location: json['location'] ?? '',
      status: json['status'] ?? 'NORMAL',
      threshold: json['threshold'] ?? '',
      reason: json['reason'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 13.0827,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 80.2707,
    );
  }
}

