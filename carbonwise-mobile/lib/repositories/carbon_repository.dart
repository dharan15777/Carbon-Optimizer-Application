import '../services/api_service.dart';
import '../models/carbon_intensity_model.dart';
import '../services/grid_simulation_service.dart';

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
    return GridSimulationService.instance.current;
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
    final simRecords = GridSimulationService.instance.records;
    if (simRecords.isNotEmpty) {
      return simRecords.take(days).toList();
    }
    final now = DateTime.now();
    return List.generate(7, (i) {
      final dt = now.subtract(Duration(days: 6 - i));
      final val = [345.0, 317.0, 336.0, 385.0, 440.0, 580.0, 320.0][i % 7];
      return CarbonIntensity(
        intensity: val,
        timestamp: dt,
        solarWindPercent: 55.0,
        hydroPercent: 10.0,
        gasPercent: 15.0,
        coalPercent: 20.0,
        status: val < 350 ? 'CLEAN' : 'NORMAL',
        demand: 4300.0,
      );
    });
  }
}
