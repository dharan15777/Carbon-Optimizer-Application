import 'package:flutter/material.dart';
import '../repositories/map_repository.dart';

class MapProvider extends ChangeNotifier {
  final MapRepository _repository;
  List<Map<String, dynamic>> _heatmapData = [];
  List<Map<String, dynamic>> _sensorLocations = [];
  List<Map<String, dynamic>> _highRiskZones = [];
  bool _isLoading = false;
  String? _error;

  MapProvider(this._repository);

  List<Map<String, dynamic>> get heatmapData => _heatmapData;
  List<Map<String, dynamic>> get sensorLocations => _sensorLocations;
  List<Map<String, dynamic>> get highRiskZones => _highRiskZones;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCarbonHeatmap() async {
    _isLoading = true;
    notifyListeners();

    try {
      _heatmapData = await _repository.fetchCarbonHeatmap();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSensorLocations() async {
    try {
      _sensorLocations = await _repository.fetchSensorLocations();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchAllMapData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.fetchCarbonHeatmap(),
        _repository.fetchSensorLocations(),
        _repository.fetchHighRiskZones(),
      ]);

      _heatmapData = results[0];
      _sensorLocations = results[1];
      _highRiskZones = results[2];
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
