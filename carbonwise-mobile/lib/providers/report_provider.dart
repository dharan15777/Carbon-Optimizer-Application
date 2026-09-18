import 'package:flutter/material.dart';
import '../repositories/report_repository.dart';
import '../models/report_model.dart';

class ReportProvider extends ChangeNotifier {
  final ReportRepository _repository;
  Report? _dailyReport;
  Report? _weeklyReport;
  Report? _monthlyReport;
  bool _isLoading = false;
  String? _error;

  ReportProvider(this._repository);

  Report? get dailyReport => _dailyReport;
  Report? get weeklyReport => _weeklyReport;
  Report? get monthlyReport => _monthlyReport;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDailyReport() async {
    _isLoading = true;
    notifyListeners();

    try {
      _dailyReport = await _repository.fetchDailyReport();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchWeeklyReport() async {
    _isLoading = true;
    notifyListeners();

    try {
      _weeklyReport = await _repository.fetchWeeklyReport();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchMonthlyReport() async {
    _isLoading = true;
    notifyListeners();

    try {
      _monthlyReport = await _repository.fetchMonthlyReport();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllReports() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await Future.wait([
        fetchDailyReport(),
        fetchWeeklyReport(),
        fetchMonthlyReport(),
      ]);
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }
}
