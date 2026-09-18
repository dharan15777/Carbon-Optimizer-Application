import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../services/api_service.dart';
import '../models/device_model.dart';

class DeviceRepository {
  final ApiService _apiService;
  List<Device> _localDevices = [
    Device(
      id: 'dev-1',
      userId: 'user-1',
      name: 'EV Home Charger',
      type: AppConstants.deviceEVCharger,
      powerRating: 7.4,
      isActive: true,
      isScheduled: true,
      createdAt: DateTime.now(),
    ),
    Device(
      id: 'dev-2',
      userId: 'user-1',
      name: 'Living Room AC',
      type: AppConstants.deviceAirConditioner,
      powerRating: 1.8,
      isActive: true,
      isScheduled: false,
      createdAt: DateTime.now(),
    ),
    Device(
      id: 'dev-3',
      userId: 'user-1',
      name: 'Smart Washing Machine',
      type: AppConstants.deviceWashingMachine,
      powerRating: 1.2,
      isActive: false,
      isScheduled: true,
      createdAt: DateTime.now(),
    ),
    Device(
      id: 'dev-4',
      userId: 'user-1',
      name: 'Eco Water Heater',
      type: AppConstants.deviceWaterHeater,
      powerRating: 2.5,
      isActive: false,
      isScheduled: false,
      createdAt: DateTime.now(),
    ),
  ];

  DeviceRepository(this._apiService);

  Future<String> _getUserId([String? explicitUserId]) async {
    if (explicitUserId != null && explicitUserId.isNotEmpty) return explicitUserId;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.userIdKey) ?? 'user-demo-1';
  }

  Future<List<Device>> fetchDevices({String? userId}) async {
    try {
      final uid = await _getUserId(userId);
      final response = await _apiService.get('/api/device', queryParameters: {'userId': uid});
      if (response.data is List) {
        final list = (response.data as List).map((e) => Device.fromJson(e)).toList();
        if (list.isNotEmpty) {
          _localDevices = list;
          return list;
        }
      }
    } catch (_) {}
    return List<Device>.from(_localDevices);
  }

  Future<Device> addDevice(Map<String, dynamic> deviceData, {String? userId}) async {
    final uid = await _getUserId(userId);
    try {
      final response = await _apiService.post('/api/device?userId=$uid', data: deviceData);
      final created = Device.fromJson(response.data);
      _localDevices.add(created);
      return created;
    } catch (_) {
      final newDevice = Device(
        id: 'dev-${DateTime.now().millisecondsSinceEpoch}',
        userId: uid,
        name: deviceData['name']?.toString() ?? 'Smart Appliance',
        type: deviceData['type']?.toString() ?? AppConstants.deviceSmartPlug,
        powerRating: (deviceData['powerRating'] as num?)?.toDouble() ?? 1.0,
        isActive: deviceData['isActive'] == true,
        isScheduled: false,
        createdAt: DateTime.now(),
      );
      _localDevices.add(newDevice);
      return newDevice;
    }
  }

  Future<Device> updateDevice(String id, Map<String, dynamic> deviceData) async {
    try {
      final response = await _apiService.put('/api/device/$id', data: deviceData);
      final updated = Device.fromJson(response.data);
      final idx = _localDevices.indexWhere((d) => d.id == id);
      if (idx != -1) _localDevices[idx] = updated;
      return updated;
    } catch (_) {
      final idx = _localDevices.indexWhere((d) => d.id == id);
      if (idx != -1) {
        final existing = _localDevices[idx];
        final updated = Device(
          id: existing.id,
          userId: existing.userId,
          name: deviceData['name']?.toString() ?? existing.name,
          type: deviceData['type']?.toString() ?? existing.type,
          powerRating: (deviceData['powerRating'] as num?)?.toDouble() ?? existing.powerRating,
          isActive: deviceData['isActive'] != null ? deviceData['isActive'] == true : existing.isActive,
          isScheduled: existing.isScheduled,
          createdAt: existing.createdAt,
        );
        _localDevices[idx] = updated;
        return updated;
      }
      throw Exception('Device not found');
    }
  }

  Future<void> deleteDevice(String id) async {
    try {
      await _apiService.delete('/api/device/$id');
    } catch (_) {}
    _localDevices.removeWhere((d) => d.id == id);
  }
}
