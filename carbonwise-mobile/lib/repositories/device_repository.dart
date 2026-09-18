import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../services/api_service.dart';
import '../models/device_model.dart';

class DeviceRepository {
  final ApiService _apiService;
  List<Device> _localDevices = [
    Device(
      id: 'CNC-001',
      userId: 'user-1',
      name: 'CNC Milling Machine 5-Axis',
      type: 'CNC Machine',
      powerRating: 15.0,
      currentPower: 11.8,
      energyToday: 74.6,
      carbonKg: 28.3,
      temperature: 68.4,
      vibration: 4.2,
      runtimeHours: 6.3,
      riskLevel: 'MEDIUM',
      customLocation: 'Precision Machining Bay 1',
      isActive: true,
      isScheduled: true,
      createdAt: DateTime.now(),
    ),
    Device(
      id: 'MOT-002',
      userId: 'user-1',
      name: 'Heavy Duty Induction Motor',
      type: 'Industrial Motor',
      powerRating: 22.0,
      currentPower: 17.5,
      energyToday: 112.4,
      carbonKg: 42.7,
      temperature: 58.2,
      vibration: 2.8,
      runtimeHours: 6.4,
      riskLevel: 'LOW',
      customLocation: 'Assembly Line Conveyor',
      isActive: true,
      isScheduled: false,
      createdAt: DateTime.now(),
    ),
    Device(
      id: 'CMP-003',
      userId: 'user-1',
      name: 'Rotary Screw Air Compressor',
      type: 'Air Compressor',
      powerRating: 30.0,
      currentPower: 26.2,
      energyToday: 184.2,
      carbonKg: 70.0,
      temperature: 78.5,
      vibration: 3.4,
      runtimeHours: 7.1,
      riskLevel: 'MEDIUM',
      customLocation: 'Central Utility Plant',
      isActive: true,
      isScheduled: true,
      createdAt: DateTime.now(),
    ),
    Device(
      id: 'HVAC-004',
      userId: 'user-1',
      name: 'Industrial Cleanroom HVAC',
      type: 'Industrial HVAC',
      powerRating: 45.0,
      currentPower: 38.0,
      energyToday: 268.0,
      carbonKg: 101.8,
      temperature: 42.1,
      vibration: 1.9,
      runtimeHours: 7.2,
      riskLevel: 'LOW',
      customLocation: 'Cleanroom Block B',
      isActive: true,
      isScheduled: false,
      createdAt: DateTime.now(),
    ),
    Device(
      id: 'IMM-005',
      userId: 'user-1',
      name: 'Hydraulic Injection Molding Machine',
      type: 'Injection Molding Machine',
      powerRating: 55.0,
      currentPower: 44.5,
      energyToday: 312.5,
      carbonKg: 118.7,
      temperature: 72.8,
      vibration: 4.8,
      runtimeHours: 7.0,
      riskLevel: 'HIGH',
      customLocation: 'Polymer Processing Hall',
      isActive: true,
      isScheduled: false,
      createdAt: DateTime.now(),
    ),
    Device(
      id: 'CONV-006',
      userId: 'user-1',
      name: 'Main Line Roller Conveyor',
      type: 'Conveyor Belt Motor',
      powerRating: 11.0,
      currentPower: 8.2,
      energyToday: 58.1,
      carbonKg: 22.1,
      temperature: 48.0,
      vibration: 2.1,
      runtimeHours: 7.1,
      riskLevel: 'LOW',
      customLocation: 'Warehouse Logistics Hub',
      isActive: true,
      isScheduled: false,
      createdAt: DateTime.now(),
    ),
    Device(
      id: 'PMP-007',
      userId: 'user-1',
      name: 'Centrifugal Effluent Slurry Pump',
      type: 'Industrial Pump',
      powerRating: 18.5,
      currentPower: 14.8,
      energyToday: 98.4,
      carbonKg: 37.4,
      temperature: 52.3,
      vibration: 3.1,
      runtimeHours: 6.6,
      riskLevel: 'LOW',
      customLocation: 'Water & Effluent Treatment',
      isActive: true,
      isScheduled: false,
      createdAt: DateTime.now(),
    ),
    Device(
      id: 'WLD-008',
      userId: 'user-1',
      name: 'Automated Robotic MIG Welder',
      type: 'Welding Machine',
      powerRating: 12.0,
      currentPower: 9.6,
      energyToday: 48.2,
      carbonKg: 18.3,
      temperature: 64.0,
      vibration: 2.6,
      runtimeHours: 5.1,
      riskLevel: 'LOW',
      customLocation: 'Chassis Fabrication Bay',
      isActive: true,
      isScheduled: false,
      createdAt: DateTime.now(),
    ),
    Device(
      id: 'BLR-009',
      userId: 'user-1',
      name: 'Industrial Steam Boiler 2-Ton',
      type: 'Boiler',
      powerRating: 75.0,
      currentPower: 62.0,
      energyToday: 420.0,
      carbonKg: 159.6,
      temperature: 115.0,
      vibration: 4.9,
      runtimeHours: 6.9,
      riskLevel: 'HIGH',
      customLocation: 'Thermal Utility Station',
      isActive: true,
      isScheduled: false,
      createdAt: DateTime.now(),
    ),
    Device(
      id: 'FRN-010',
      userId: 'user-1',
      name: 'Continuous Electric Annealing Furnace',
      type: 'Industrial Furnace',
      powerRating: 110.0,
      currentPower: 88.5,
      energyToday: 590.2,
      carbonKg: 224.3,
      temperature: 840.0,
      vibration: 1.8,
      runtimeHours: 6.7,
      riskLevel: 'HIGH',
      customLocation: 'Heat Treatment Facility',
      isActive: true,
      isScheduled: true,
      createdAt: DateTime.now(),
    ),
    Device(
      id: 'CHL-011',
      userId: 'user-1',
      name: 'Centrifugal Water-Cooled Chiller',
      type: 'Chiller',
      powerRating: 40.0,
      currentPower: 31.4,
      energyToday: 218.0,
      carbonKg: 82.8,
      temperature: 38.5,
      vibration: 2.2,
      runtimeHours: 7.0,
      riskLevel: 'LOW',
      customLocation: 'Refrigeration Plant',
      isActive: true,
      isScheduled: false,
      createdAt: DateTime.now(),
    ),
    Device(
      id: 'PKG-012',
      userId: 'user-1',
      name: 'High-Speed Carton Packaging Unit',
      type: 'Packaging Machine',
      powerRating: 8.0,
      currentPower: 5.8,
      energyToday: 38.2,
      carbonKg: 14.5,
      temperature: 41.2,
      vibration: 1.6,
      runtimeHours: 6.6,
      riskLevel: 'LOW',
      customLocation: 'End-of-Line Packaging',
      isActive: true,
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
