class Report {
  final String id;
  final String userId;
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final double totalCarbonUsed;
  final double totalCarbonSaved;
  final double totalElectricityUsed;
  final double renewablePercentage;
  final int deviceCount;
  final List<DeviceStatistic> deviceStatistics;
  final String? pdfUrl;

  Report({
    required this.id,
    required this.userId,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.totalCarbonUsed,
    required this.totalCarbonSaved,
    required this.totalElectricityUsed,
    required this.renewablePercentage,
    required this.deviceCount,
    required this.deviceStatistics,
    this.pdfUrl,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      type: json['type']?.toString() ?? 'DAILY',
      startDate: json['startDate'] != null
          ? (DateTime.tryParse(json['startDate'].toString()) ?? DateTime.now())
          : DateTime.now(),
      endDate: json['endDate'] != null
          ? (DateTime.tryParse(json['endDate'].toString()) ?? DateTime.now())
          : DateTime.now(),
      totalCarbonUsed: (json['totalCarbonUsed'] as num?)?.toDouble() ?? 0.0,
      totalCarbonSaved: (json['totalCarbonSaved'] as num?)?.toDouble() ?? 0.0,
      totalElectricityUsed: (json['totalElectricityUsed'] as num?)?.toDouble() ?? 0.0,
      renewablePercentage: (json['renewablePercentage'] as num?)?.toDouble() ?? 0.0,
      deviceCount: (json['deviceCount'] as num?)?.toInt() ?? 0,
      deviceStatistics: (json['deviceStatistics'] as List?)
              ?.map((e) => DeviceStatistic.fromJson(e))
              .toList() ??
          [],
      pdfUrl: json['pdfUrl']?.toString(),
    );
  }

}

class DeviceStatistic {
  final String deviceName;
  final String deviceType;
  final double carbonUsed;
  final double carbonSaved;
  final double electricityUsed;

  DeviceStatistic({
    required this.deviceName,
    required this.deviceType,
    required this.carbonUsed,
    required this.carbonSaved,
    required this.electricityUsed,
  });

  factory DeviceStatistic.fromJson(Map<String, dynamic> json) {
    return DeviceStatistic(
      deviceName: json['deviceName'],
      deviceType: json['deviceType'],
      carbonUsed: (json['carbonUsed'] as num).toDouble(),
      carbonSaved: (json['carbonSaved'] as num).toDouble(),
      electricityUsed: (json['electricityUsed'] as num).toDouble(),
    );
  }
}
