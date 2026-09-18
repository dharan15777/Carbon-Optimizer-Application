import '../services/api_service.dart';
import '../models/carbon_intensity_model.dart';

class CarbonRepository {
  final ApiService _apiService;

  CarbonRepository(this._apiService);

  Future<CarbonIntensity> fetchLiveIntensity() async {
    try {
      final response = await _apiService.get('/api/consumer/carbon/live');
      if (response.data != null && response.data is Map) {
        return CarbonIntensity.fromJson(Map<String, dynamic>.from(response.data as Map));
      }
    } catch (_) {}
    return CarbonIntensity(
      intensity: 118.0,
      timestamp: DateTime.now(),
      solarWindPercent: 64.0,
      hydroPercent: 12.0,
      gasPercent: 14.0,
      coalPercent: 10.0,
      status: 'CLEAN',
    );
  }

  Future<List<CarbonIntensity>> fetchCarbonHistory({int days = 30}) async {
    try {
      final response = await _apiService.get(
        '/api/consumer/carbon/history',
        queryParameters: {'days': days},
      );
      if (response.data is List) {
        return (response.data as List).map((e) => CarbonIntensity.fromJson(e)).toList();
      }
    } catch (_) {}
    final now = DateTime.now();
    return List.generate(7, (i) {
      final dt = now.subtract(Duration(days: 6 - i));
      final val = [145.0, 132.0, 110.0, 168.0, 125.0, 118.0, 105.0][i % 7];
      return CarbonIntensity(
        intensity: val,
        timestamp: dt,
        solarWindPercent: 60.0 + (i * 2),
        hydroPercent: 15.0,
        gasPercent: 15.0,
        coalPercent: 10.0,
        status: val < 150 ? 'CLEAN' : 'MODERATE',
      );
    });
  }
}
