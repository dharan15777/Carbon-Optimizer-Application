class Schedule {
  final String id;
  final String deviceId;
  final String userId;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAiRecommended;
  final double estimatedCarbonSaving;
  final String status;

  Schedule({
    required this.id,
    required this.deviceId,
    required this.userId,
    required this.startTime,
    required this.endTime,
    this.isAiRecommended = false,
    this.estimatedCarbonSaving = 0.0,
    this.status = 'PENDING',
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      deviceId: json['deviceId'],
      userId: json['userId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      isAiRecommended: json['isAiRecommended'] ?? false,
      estimatedCarbonSaving: (json['estimatedCarbonSaving'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'PENDING',
    );
  }
}
