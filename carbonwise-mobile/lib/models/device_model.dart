class Device {
  final String id;
  final String userId;
  final String name;
  final String type;
  final double powerRating;
  final bool isActive;
  final bool isScheduled;
  final String? scheduleId;
  final DateTime createdAt;

  Device({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.powerRating,
    this.isActive = false,
    this.isScheduled = false,
    this.scheduleId,
    required this.createdAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      type: json['type'],
      powerRating: (json['powerRating'] as num).toDouble(),
      isActive: json['isActive'] ?? false,
      isScheduled: json['isScheduled'] ?? false,
      scheduleId: json['scheduleId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'type': type,
      'powerRating': powerRating,
      'isActive': isActive,
      'isScheduled': isScheduled,
      'scheduleId': scheduleId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
