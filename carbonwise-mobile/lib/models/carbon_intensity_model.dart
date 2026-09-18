class CarbonIntensity {
  final double intensity;
  final double solarWindPercent;
  final double hydroPercent;
  final double gasPercent;
  final double coalPercent;
  final String status;
  final DateTime timestamp;

  CarbonIntensity({
    required this.intensity,
    required this.solarWindPercent,
    required this.hydroPercent,
    required this.gasPercent,
    required this.coalPercent,
    required this.status,
    required this.timestamp,
  });

  double get renewablePercent => solarWindPercent + hydroPercent;

  factory CarbonIntensity.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return CarbonIntensity(
        intensity: 220.0,
        solarWindPercent: 42.0,
        hydroPercent: 15.0,
        gasPercent: 18.0,
        coalPercent: 25.0,
        status: 'MODERATE',
        timestamp: DateTime.now(),
      );
    }
    return CarbonIntensity(
      intensity: (json['intensity'] as num?)?.toDouble() ?? 220.0,
      solarWindPercent: (json['solarWindPercent'] as num?)?.toDouble() ?? 42.0,
      hydroPercent: (json['hydroPercent'] as num?)?.toDouble() ?? 15.0,
      gasPercent: (json['gasPercent'] as num?)?.toDouble() ?? 18.0,
      coalPercent: (json['coalPercent'] as num?)?.toDouble() ?? 25.0,
      status: json['status']?.toString() ?? 'MODERATE',
      timestamp: json['timestamp'] != null
          ? (DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'intensity': intensity,
      'solarWindPercent': solarWindPercent,
      'hydroPercent': hydroPercent,
      'gasPercent': gasPercent,
      'coalPercent': coalPercent,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

