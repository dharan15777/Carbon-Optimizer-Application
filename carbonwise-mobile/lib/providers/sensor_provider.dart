import 'package:flutter/material.dart';
import '../repositories/sensor_repository.dart';
import '../models/sensor_model.dart';

class SensorProvider extends ChangeNotifier {
  final SensorRepository _repository;
  List<SensorData> _liveData = [];
  List<IndustrialSensor> _sensors = [];
  bool _isLoading = false;
  String? _error;

  SensorProvider(this._repository) {
    fetchIndustrialSensors();
  }

  List<SensorData> get liveData => _liveData;
  List<IndustrialSensor> get sensors => _sensors;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchIndustrialSensors() async {
    _isLoading = true;
    notifyListeners();

    try {
      _sensors = await _repository.fetchIndustrialSensors();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLiveSensorData() async {
    try {
      _liveData = await _repository.fetchLiveSensorData();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
