import 'package:flutter/material.dart';
import '../repositories/carbon_repository.dart';
import '../models/carbon_intensity_model.dart';

class CarbonProvider extends ChangeNotifier {
  final CarbonRepository _repository;
  CarbonIntensity? _liveIntensity;
  List<CarbonIntensity> _history = [];
  bool _isLoading = false;
  String? _error;

  CarbonProvider(this._repository);

  CarbonIntensity? get liveIntensity => _liveIntensity;
  List<CarbonIntensity> get history => _history;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchLiveIntensity() async {
    _isLoading = true;
    notifyListeners();

    try {
      _liveIntensity = await _repository.fetchLiveIntensity();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCarbonHistory({int days = 30}) async {
    _isLoading = true;
    notifyListeners();

    try {
      _history = await _repository.fetchCarbonHistory(days: days);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
