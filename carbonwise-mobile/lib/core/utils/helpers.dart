import '../constants/app_constants.dart';

class Helpers {
  /// Get carbon status label based on intensity value
  static String getCarbonStatus(double intensity) {
    if (intensity <= AppConstants.carbonCleanThreshold) {
      return 'Clean Energy Window';
    } else if (intensity <= AppConstants.carbonModerateThreshold) {
      return 'Moderate Carbon Mix';
    } else if (intensity <= AppConstants.carbonDirtyThreshold) {
      return 'High Carbon Load';
    } else {
      return 'Critical Carbon Level';
    }
  }

  /// Get carbon color based on intensity
  static int getCarbonColor(double intensity) {
    if (intensity <= AppConstants.carbonCleanThreshold) {
      return 0xFF00F576; // Green
    } else if (intensity <= AppConstants.carbonModerateThreshold) {
      return 0xFFEAB308; // Yellow
    } else {
      return 0xFFFF3838; // Red
    }
  }

  /// Format carbon intensity with unit
  static String formatIntensity(double intensity) {
    return '${intensity.toStringAsFixed(0)} gCO₂/kWh';
  }

  /// Calculate carbon savings percentage
  static double calculateSavings(double baseline, double optimized) {
    if (baseline == 0) return 0;
    return ((baseline - optimized) / baseline) * 100;
  }

  /// Format date for reports
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  /// Format time for schedules
  static String formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Get device icon name based on type
  static String getDeviceIcon(String deviceType) {
    switch (deviceType) {
      case AppConstants.deviceSmartPlug:
        return 'plug';
      case AppConstants.deviceEVCharger:
        return 'ev_station';
      case AppConstants.deviceAirConditioner:
        return 'ac_unit';
      case AppConstants.deviceWashingMachine:
        return 'local_laundry_service';
      case AppConstants.deviceWaterHeater:
        return 'water_drop';
      default:
        return 'device_unknown';
    }
  }

  /// Get renewable percentage from grid mix
  static double getRenewablePercentage(Map<String, double> gridMix) {
    final renewable = (gridMix['solar'] ?? 0) +
        (gridMix['wind'] ?? 0) +
        (gridMix['hydro'] ?? 0);
    final total = gridMix.values.fold(0.0, (sum, v) => sum + v);
    return total > 0 ? (renewable / total) * 100 : 0;
  }
}
