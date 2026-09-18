import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../services/api_service.dart';
import '../models/report_model.dart';

class ReportRepository {
  final ApiService _apiService;

  ReportRepository(this._apiService);

  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.userIdKey) ?? 'user-demo-1';
  }

  Future<Report> fetchDailyReport({String? userId}) async {
    final uid = userId ?? await _getUserId();
    try {
      final response = await _apiService.get('/api/reports/daily', queryParameters: {'userId': uid});
      if (response.data != null && response.data is Map) {
        return Report.fromJson(Map<String, dynamic>.from(response.data as Map));
      }
    } catch (_) {}
    return Report(
      id: 'rep-daily-1',
      userId: uid,
      type: 'DAILY',
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now(),
      totalCarbonUsed: 12.4,
      totalCarbonSaved: 4.2,
      totalElectricityUsed: 18.5,
      renewablePercentage: 68.0,
      deviceCount: 4,
      deviceStatistics: [
        DeviceStatistic(deviceName: 'EV Home Charger', deviceType: AppConstants.deviceEVCharger, carbonUsed: 5.2, carbonSaved: 2.1, electricityUsed: 8.0),
        DeviceStatistic(deviceName: 'Living Room AC', deviceType: AppConstants.deviceAirConditioner, carbonUsed: 3.8, carbonSaved: 1.0, electricityUsed: 5.5),
        DeviceStatistic(deviceName: 'Smart Washing Machine', deviceType: AppConstants.deviceWashingMachine, carbonUsed: 1.8, carbonSaved: 0.8, electricityUsed: 2.5),
        DeviceStatistic(deviceName: 'Eco Water Heater', deviceType: AppConstants.deviceWaterHeater, carbonUsed: 1.6, carbonSaved: 0.3, electricityUsed: 2.5),
      ],
      pdfUrl: null,
    );
  }

  Future<Report> fetchWeeklyReport({String? userId}) async {
    final uid = userId ?? await _getUserId();
    try {
      final response = await _apiService.get('/api/reports/weekly', queryParameters: {'userId': uid});
      if (response.data != null && response.data is Map) {
        return Report.fromJson(Map<String, dynamic>.from(response.data as Map));
      }
    } catch (_) {}
    return Report(
      id: 'rep-weekly-1',
      userId: uid,
      type: 'WEEKLY',
      startDate: DateTime.now().subtract(const Duration(days: 7)),
      endDate: DateTime.now(),
      totalCarbonUsed: 84.6,
      totalCarbonSaved: 28.5,
      totalElectricityUsed: 122.0,
      renewablePercentage: 62.5,
      deviceCount: 4,
      deviceStatistics: [
        DeviceStatistic(deviceName: 'EV Home Charger', deviceType: AppConstants.deviceEVCharger, carbonUsed: 35.0, carbonSaved: 12.0, electricityUsed: 52.0),
        DeviceStatistic(deviceName: 'Living Room AC', deviceType: AppConstants.deviceAirConditioner, carbonUsed: 24.0, carbonSaved: 6.5, electricityUsed: 36.0),
        DeviceStatistic(deviceName: 'Smart Washing Machine', deviceType: AppConstants.deviceWashingMachine, carbonUsed: 14.0, carbonSaved: 7.0, electricityUsed: 18.0),
        DeviceStatistic(deviceName: 'Eco Water Heater', deviceType: AppConstants.deviceWaterHeater, carbonUsed: 11.6, carbonSaved: 3.0, electricityUsed: 16.0),
      ],
      pdfUrl: null,
    );
  }

  Future<Report> fetchMonthlyReport({String? userId}) async {
    final uid = userId ?? await _getUserId();
    try {
      final response = await _apiService.get('/api/reports/monthly', queryParameters: {'userId': uid});
      if (response.data != null && response.data is Map) {
        return Report.fromJson(Map<String, dynamic>.from(response.data as Map));
      }
    } catch (_) {}
    return Report(
      id: 'rep-monthly-1',
      userId: uid,
      type: 'MONTHLY',
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      endDate: DateTime.now(),
      totalCarbonUsed: 287.0,
      totalCarbonSaved: 86.1,
      totalElectricityUsed: 350.0,
      renewablePercentage: 57.0,
      deviceCount: 4,
      deviceStatistics: [
        DeviceStatistic(deviceName: 'EV Home Charger', deviceType: AppConstants.deviceEVCharger, carbonUsed: 120.0, carbonSaved: 36.0, electricityUsed: 150.0),
        DeviceStatistic(deviceName: 'Living Room AC', deviceType: AppConstants.deviceAirConditioner, carbonUsed: 85.0, carbonSaved: 15.0, electricityUsed: 105.0),
        DeviceStatistic(deviceName: 'Smart Washing Machine', deviceType: AppConstants.deviceWashingMachine, carbonUsed: 45.0, carbonSaved: 25.0, electricityUsed: 52.0),
        DeviceStatistic(deviceName: 'Eco Water Heater', deviceType: AppConstants.deviceWaterHeater, carbonUsed: 37.0, carbonSaved: 10.0, electricityUsed: 43.0),
      ],
      pdfUrl: null,
    );
  }
}
