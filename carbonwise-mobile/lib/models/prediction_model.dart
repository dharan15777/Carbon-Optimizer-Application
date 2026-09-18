class Prediction {
  final String id;
  final DateTime predictedAt;
  final List<PredictionDataPoint> dataPoints;
  final String bestChargingTime;
  final String bestApplianceTime;
  final String recommendation;

  Prediction({
    required this.id,
    required this.predictedAt,
    required this.dataPoints,
    required this.bestChargingTime,
    required this.bestApplianceTime,
    required this.recommendation,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      id: json['id']?.toString() ?? '',
      predictedAt: json['predictedAt'] != null
          ? (DateTime.tryParse(json['predictedAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
      dataPoints: (json['dataPoints'] as List?)
              ?.map((e) => PredictionDataPoint.fromJson(e))
              .toList() ??
          [],
      bestChargingTime: json['bestChargingTime']?.toString() ?? '10:00 AM - 2:00 PM',
      bestApplianceTime: json['bestApplianceTime']?.toString() ?? '11:00 AM - 1:00 PM',
      recommendation: json['recommendation']?.toString() ?? 'Optimal solar production window',
    );
  }
}

class PredictionDataPoint {
  final DateTime time;
  final double predictedIntensity;
  final double confidence;

  PredictionDataPoint({
    required this.time,
    required this.predictedIntensity,
    required this.confidence,
  });

  factory PredictionDataPoint.fromJson(Map<String, dynamic> json) {
    return PredictionDataPoint(
      time: json['time'] != null
          ? (DateTime.tryParse(json['time'].toString()) ?? DateTime.now())
          : DateTime.now(),
      predictedIntensity: (json['predictedIntensity'] as num?)?.toDouble() ?? 0.0,
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.85,
    );
  }

}
