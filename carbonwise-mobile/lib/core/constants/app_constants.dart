class AppConstants {
  // API
  // Updated to live Render deployment
  static const String baseUrl = 'https://carbonwise-application.onrender.com/api';
  
  // Keep live/default domain fallbacks for AI and MQTT or update if running locally
  static const String aiServerUrl = 'https://ai.carbonwise.in';
  static const String mqttBroker = 'mqtt.carbonwise.in';
  static const int mqttPort = 1883;

  // App Info
  static const String appName = 'CarbonWise';
  static const String appVersion = '1.0.0';

  // Roles
  static const String roleConsumer = 'CONSUMER';
  static const String roleCityAdmin = 'CITY_ADMIN';
  static const String roleSystemAdmin = 'SYSTEM_ADMIN';

  // Carbon Intensity Thresholds (gCO₂/kWh)
  static const double carbonCleanThreshold = 150.0;
  static const double carbonModerateThreshold = 300.0;
  static const double carbonDirtyThreshold = 450.0;

  // Prediction Windows
  static const int prediction6h = 6;
  static const int prediction12h = 12;
  static const int prediction24h = 24;

  // Device Types
  static const String deviceSmartPlug = 'SMART_PLUG';
  static const String deviceEVCharger = 'EV_CHARGER';
  static const String deviceAirConditioner = 'AIR_CONDITIONER';
  static const String deviceWashingMachine = 'WASHING_MACHINE';
  static const String deviceWaterHeater = 'WATER_HEATER';

  // Sensor Types
  static const String sensorCO2 = 'CO2';
  static const String sensorPM25 = 'PM25';
  static const String sensorPM10 = 'PM10';
  static const String sensorTemperature = 'TEMPERATURE';
  static const String sensorHumidity = 'HUMIDITY';

  // Notification Types
  static const String notifGridClean = 'GRID_CLEAN';
  static const String notifGridDirty = 'GRID_DIRTY';
  static const String notifBestCharging = 'BEST_CHARGING';
  static const String notifDeviceCompleted = 'DEVICE_COMPLETED';
  static const String notifHighPollution = 'HIGH_POLLUTION';
  static const String notifWeatherAlert = 'WEATHER_ALERT';
  static const String notifDailyReport = 'DAILY_REPORT';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userRoleKey = 'user_role';
  static const String themeKey = 'theme_mode';

  // Map Defaults
  static const double defaultLat = 13.0827; // Chennai
  static const double defaultLng = 80.2707;
  static const double defaultZoom = 12.0;
}