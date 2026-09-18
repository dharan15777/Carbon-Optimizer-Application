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
    try {
      await _repository.addDevice(deviceData);
      await fetchDevices();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
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
}
