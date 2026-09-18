import 'package:flutter/material.dart';
import '../repositories/sensor_repository.dart';
import '../models/sensor_model.dart';

class SensorProvider extends ChangeNotifier {
  final SensorRepository _repository;
  List<SensorData> _liveData = [];
  bool _isLoading = false;
  String? _error;

  SensorProvider(this._repository);

  List<SensorData> get liveData => _liveData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchLiveSensorData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _liveData = await _repository.fetchLiveSensorData();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
