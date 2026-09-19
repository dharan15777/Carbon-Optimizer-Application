import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/carbon_intensity_model.dart';

/// Centralized Grid CSV Simulation Service for CarbonWise Mobile
/// Reads bundled CSV telemetry and advances every 15 seconds
class GridSimulationService extends ChangeNotifier {
  static final GridSimulationService instance = GridSimulationService._internal();

  GridSimulationService._internal() {
    _init();
  }

  final List<CarbonIntensity> _records = [];
  int _currentIndex = 12; // Start at ~12:00 PM clean window
  Timer? _timer;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  List<CarbonIntensity> get records => List.unmodifiable(_records);

  CarbonIntensity get current {
    if (_records.isEmpty) {
      return CarbonIntensity(
        intensity: 320.0,
        solarWindPercent: 52.0,
        hydroPercent: 7.0,
        gasPercent: 12.0,
        coalPercent: 29.0,
        status: 'CLEAN',
        timestamp: DateTime.now(),
        demand: 4420.0,
      );
    }
    return _records[_currentIndex];
  }

  void _init() async {
    try {
      final csvString = await rootBundle.loadString('assets/data/grid_telemetry.csv');
      final lines = csvString.trim().split(RegExp(r'\r?\n'));
      if (lines.length > 1) {
        _records.clear();
        for (var i = 1; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.isEmpty) continue;
          final parts = line.split(',');
          if (parts.length >= 8) {
            final intensity = double.tryParse(parts[1]) ?? 400.0;
            final solar = double.tryParse(parts[4]) ?? 20.0;
            final wind = double.tryParse(parts[5]) ?? 10.0;
            final hydro = double.tryParse(parts[6]) ?? 6.0;
            final thermal = double.tryParse(parts[3]) ?? 55.0;
            final demand = double.tryParse(parts[7]) ?? 4000.0;
            
            String status = 'NORMAL';
            if (intensity < 350) {
              status = 'CLEAN';
            } else if (intensity > 600) {
              status = 'HIGH';
            }

            _records.add(CarbonIntensity(
              intensity: intensity,
              solarWindPercent: solar + wind,
              hydroPercent: hydro,
              gasPercent: thermal * 0.4,
              coalPercent: thermal * 0.6,
              status: status,
              timestamp: DateTime.now(),
              demand: demand,
            ));
          }
        }
      }
    } catch (e) {
      debugPrint('GridSimulationService CSV load fallback: $e');
    }

    if (_records.isEmpty) {
      _loadFallbackRecords();
    }

    _isInitialized = true;
    notifyListeners();

    // Advance simulation every 15 seconds
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) {
      stepSimulation();
    });
  }

  void stepSimulation() {
    if (_records.isEmpty) return;
    _currentIndex = (_currentIndex + 1) % _records.length;
    notifyListeners();
  }

  void _loadFallbackRecords() {
    final points = [
      {'intensity': 603.0, 'solar': 0.0, 'wind': 10.0, 'hydro': 7.0, 'status': 'HIGH', 'demand': 3800.0},
      {'intensity': 560.0, 'solar': 4.0, 'wind': 12.0, 'hydro': 7.0, 'status': 'NORMAL', 'demand': 4200.0},
      {'intensity': 440.0, 'solar': 22.0, 'wind': 10.0, 'hydro': 6.0, 'status': 'NORMAL', 'demand': 4600.0},
      {'intensity': 345.0, 'solar': 42.0, 'wind': 8.0, 'hydro': 5.0, 'status': 'CLEAN', 'demand': 4500.0},
      {'intensity': 317.0, 'solar': 52.0, 'wind': 7.0, 'hydro': 5.0, 'status': 'CLEAN', 'demand': 4427.0},
      {'intensity': 336.0, 'solar': 50.0, 'wind': 6.0, 'hydro': 5.0, 'status': 'CLEAN', 'demand': 4240.0},
      {'intensity': 385.0, 'solar': 35.0, 'wind': 9.0, 'hydro': 6.0, 'status': 'NORMAL', 'demand': 4230.0},
      {'intensity': 580.0, 'solar': 1.0, 'wind': 14.0, 'hydro': 7.0, 'status': 'NORMAL', 'demand': 4720.0},
      {'intensity': 648.0, 'solar': 0.0, 'wind': 10.0, 'hydro': 8.0, 'status': 'HIGH', 'demand': 4820.0},
    ];

    for (final p in points) {
      final intensity = p['intensity'] as double;
      final solar = p['solar'] as double;
      final wind = p['wind'] as double;
      final hydro = p['hydro'] as double;
      final renewable = solar + wind + hydro;
      final thermal = 100.0 - renewable;
      _records.add(CarbonIntensity(
        intensity: intensity,
        solarWindPercent: solar + wind,
        hydroPercent: hydro,
        gasPercent: thermal * 0.4,
        coalPercent: thermal * 0.6,
        status: p['status'] as String,
        timestamp: DateTime.now(),
        demand: p['demand'] as double,
      ));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
