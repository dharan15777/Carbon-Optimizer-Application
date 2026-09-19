import 'package:flutter/material.dart';
import '../repositories/device_repository.dart';
import '../models/device_model.dart';

class DeviceProvider extends ChangeNotifier {
  final DeviceRepository _repository;
  List<Device> _devices = [];
  bool _isLoading = false;
  String? _error;

  DeviceProvider(this._repository);

  List<Device> get devices => _devices;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDevices() async {
    _isLoading = true;
    notifyListeners();

    try {
      _devices = await _repository.fetchDevices();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addDevice(Map<String, dynamic> deviceData) async {
    final newId = deviceData['id']?.toString() ?? 'DEV-${DateTime.now().millisecondsSinceEpoch % 10000}';
    final name = deviceData['name']?.toString() ?? 'Industrial Machine';
    final type = deviceData['type']?.toString() ?? 'CNC Machine';
    final power = (deviceData['powerRating'] as num?)?.toDouble() ?? 15.0;
    final location = deviceData['location']?.toString() ?? 'Plant Bay A';

    // 1. Instant optimistic add with CONNECTING status
    final optimisticDevice = Device(
      id: newId,
      userId: 'user-1',
      name: name,
      type: type,
      powerRating: power,
      currentPower: power * 0.72,
      energyToday: 14.2,
      carbonKg: 5.4,
      temperature: 46.0,
      vibration: 1.9,
      runtimeHours: 0.8,
      riskLevel: 'LOW',
      customLocation: location,
      isActive: true,
      isScheduled: false,
      customStatus: 'CONNECTING',
      createdAt: DateTime.now(),
    );

    _devices.insert(0, optimisticDevice);
    notifyListeners();

    // 2. Transition status to ONLINE after edge handshake simulation
    Future.delayed(const Duration(milliseconds: 1500), () {
      final idx = _devices.indexWhere((d) => d.id == newId);
      if (idx != -1) {
        final current = _devices[idx];
        _devices[idx] = Device(
          id: current.id,
          userId: current.userId,
          name: current.name,
          type: current.type,
          powerRating: current.powerRating,
          currentPower: current.currentPower,
          energyToday: current.energyToday,
          carbonKg: current.carbonKg,
          temperature: current.temperature,
          vibration: current.vibration,
          runtimeHours: current.runtimeHours,
          riskLevel: current.riskLevel,
          customLocation: current.customLocation,
          isActive: true,
          isScheduled: current.isScheduled,
          customStatus: 'ONLINE',
          createdAt: current.createdAt,
        );
        notifyListeners();
      }
    });

    // 3. Persist in background
    _repository.addDevice(deviceData).catchError((_) => optimisticDevice);
    return true;
  }

  Future<bool> updateDevice(String id, Map<String, dynamic> deviceData) async {
    try {
      await _repository.updateDevice(id, deviceData);
      await fetchDevices();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDevice(String id) async {
    try {
      await _repository.deleteDevice(id);
      await fetchDevices();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleDevice(String id) async {
    final index = _devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      final current = _devices[index];
      _devices[index] = Device(
        id: current.id,
        userId: current.userId,
        name: current.name,
        type: current.type,
        powerRating: current.powerRating,
        isActive: !current.isActive,
        isScheduled: current.isScheduled,
        scheduleId: current.scheduleId,
        customLocation: current.customLocation,
        createdAt: current.createdAt,
      );
      notifyListeners();
    }
    return true;
  }
}
