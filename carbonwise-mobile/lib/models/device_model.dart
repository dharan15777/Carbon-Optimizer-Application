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
  final String? customLocation;
  final double? currentPower;
  final double? energyToday;
  final double? carbonKg;
  final double? temperature;
  final double? vibration;
  final double? runtimeHours;
  final String? riskLevel;

  double get power => powerRating;
  double get liveKw => currentPower ?? (isActive ? powerRating * 0.78 : 0.0);
  double get liveKwh => energyToday ?? (isActive ? powerRating * 5.2 : 0.0);
  double get liveCarbon => carbonKg ?? (liveKwh * 0.38);
  double get temp => temperature ?? (isActive ? 58.4 : 28.0);
  double get vib => vibration ?? (isActive ? 2.4 : 0.0);
  double get runtime => runtimeHours ?? (isActive ? 6.4 : 0.0);
  String get risk => riskLevel ?? (temp > 75 || vib > 4.0 ? 'HIGH' : 'LOW');
  bool get isOn => isActive;
  String get status => isActive ? 'ONLINE' : 'OFFLINE';
  String get location => customLocation ?? 'Sector 3 • Bay A';

  Device({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.powerRating,
    this.isActive = false,
    this.isScheduled = false,
    this.scheduleId,
    this.customLocation,
    this.currentPower,
    this.energyToday,
    this.carbonKg,
    this.temperature,
    this.vibration,
    this.runtimeHours,
    this.riskLevel,
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
