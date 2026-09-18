import '../services/api_service.dart';
import '../models/sensor_model.dart';

class SensorRepository {
  final ApiService _apiService;

  SensorRepository(this._apiService);

  Future<List<SensorData>> fetchLiveSensorData() async {
    final response = await _apiService.get('/api/sensor/live');
    return (response.data as List).map((e) => SensorData.fromJson(e)).toList();
  }

  Future<void> postSensorData(Map<String, dynamic> data) async {
    await _apiService.post('/api/sensor/data', data: data);
  }
}
