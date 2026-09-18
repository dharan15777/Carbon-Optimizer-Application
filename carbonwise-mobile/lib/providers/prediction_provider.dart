import 'package:flutter/material.dart';
import '../repositories/prediction_repository.dart';
import '../models/prediction_model.dart';

class PredictionProvider extends ChangeNotifier {
  final PredictionRepository _repository;
  Prediction? _prediction6h;
  Prediction? _prediction12h;
  Prediction? _prediction24h;
  bool _isLoading = false;
  String? _error;

  PredictionProvider(this._repository);

  Prediction? get prediction6h => _prediction6h;
  Prediction? get prediction12h => _prediction12h;
  Prediction? get prediction24h => _prediction24h;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchPrediction6h() async {
    _isLoading = true;
    notifyListeners();

    try {
      _prediction6h = await _repository.fetchPrediction6h();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPrediction12h() async {
    _isLoading = true;
    notifyListeners();

    try {
      _prediction12h = await _repository.fetchPrediction12h();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPrediction24h() async {
    _isLoading = true;
    notifyListeners();

    try {
      _prediction24h = await _repository.fetchPrediction24h();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllPredictions() async {
    await Future.wait([
      fetchPrediction6h(),
      fetchPrediction12h(),
      fetchPrediction24h(),
    ]);
  }
}
