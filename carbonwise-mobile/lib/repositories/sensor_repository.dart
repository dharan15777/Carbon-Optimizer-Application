import '../services/api_service.dart';
import '../models/sensor_model.dart';

class SensorRepository {
  final ApiService _apiService;

  final List<IndustrialSensor> _defaultSensors = const [
    IndustrialSensor(
      id: 'TEMP-01',
      name: 'Exhaust & Manifold Thermal Sensor',
      parameter: 'Temperature',
      value: 78.4,
      unit: '°C',
      location: 'Furnace & Boiler Core',
      status: 'WARNING',
      threshold: '> 75.0 °C',
      reason: 'Thermal load exceeding standard baseline; check manifold insulation',
      latitude: 13.0827,
      longitude: 80.2707,
    ),
    IndustrialSensor(
      id: 'HUM-02',
      name: 'Ambient Cleanroom Humidity Sensor',
      parameter: 'Humidity',
      value: 54.2,
      unit: '%',
      location: 'Cleanroom Block B',
      status: 'NORMAL',
      threshold: '40–60 %',
      reason: 'Atmospheric moisture well within cleanroom tolerance',
      latitude: 13.0850,
      longitude: 80.2650,
    ),
    IndustrialSensor(
      id: 'PM25-03',
      name: 'Fine Particulate Matter Sensor',
      parameter: 'PM2.5',
      value: 84.0,
      unit: 'µg/m³',
      location: 'Machining Hall Bay 1',
      status: 'WARNING',
      threshold: '> 60.0 µg/m³',
      reason: 'Particulate spike detected near high-speed CNC milling cutters',
      latitude: 13.0800,
      longitude: 80.2720,
    ),
    IndustrialSensor(
      id: 'PM10-04',
      name: 'Coarse Dust Particulate Sensor',
      parameter: 'PM10',
      value: 112.5,
      unit: 'µg/m³',
      location: 'Raw Material Handling Yard',
      status: 'WARNING',
      threshold: '> 100.0 µg/m³',
      reason: 'Bulk hopper dust emissions elevated during unloading cycle',
      latitude: 13.0780,
      longitude: 80.2680,
    ),
    IndustrialSensor(
      id: 'CO2-05',
      name: 'Facility Indoor CO₂ Transmitter',
      parameter: 'CO2',
      value: 720.0,
      unit: 'ppm',
      location: 'Main Assembly Hall',
      status: 'NORMAL',
      threshold: '< 1000 ppm',
      reason: 'Ventilation dilution rate optimal across working zones',
      latitude: 13.0860,
      longitude: 80.2740,
    ),
    IndustrialSensor(
      id: 'AQI-06',
      name: 'Perimeter Environmental AQI Station',
      parameter: 'AQI',
      value: 145.0,
      unit: 'AQI',
      location: 'Plant Perimeter North Gate',
      status: 'WARNING',
      threshold: '> 100 AQI',
      reason: 'External industrial corridor background AQI moderately degraded',
      latitude: 13.0910,
      longitude: 80.2780,
    ),
    IndustrialSensor(
      id: 'NSE-07',
      name: 'Acoustic Sound Pressure Monitor',
      parameter: 'Noise',
      value: 88.2,
      unit: 'dB',
      location: 'Heavy Stamping & Press Bay',
      status: 'WARNING',
      threshold: '> 85.0 dB',
      reason: 'Continuous mechanical pounding noise exceeding hearing threshold',
      latitude: 13.0815,
      longitude: 80.2690,
    ),
    IndustrialSensor(
      id: 'VIB-08',
      name: 'Compressor Skidded Vibration Transducer',
      parameter: 'Vibration',
      value: 4.9,
      unit: 'mm/s',
      location: 'Central Air Compressor Skids',
      status: 'WARNING',
      threshold: '> 4.5 mm/s',
      reason: 'Harmonic vibration indicates bearing wear or loose mounting bolts',
      latitude: 13.0840,
      longitude: 80.2760,
    ),
    IndustrialSensor(
      id: 'GAS-09',
      name: 'Combustible Gas Leak Detector',
      parameter: 'Gas Level',
      value: 12.0,
      unit: 'ppm',
      location: 'Natural Gas Boiler Manifold',
      status: 'NORMAL',
      threshold: '< 25.0 ppm',
      reason: 'Hydrocarbon levels sealed and well below lower explosive limit',
      latitude: 13.0870,
      longitude: 80.2700,
    ),
    IndustrialSensor(
      id: 'ENM-10',
      name: '11kV Incomer Smart Energy Meter',
      parameter: 'Total Load',
      value: 482.0,
      unit: 'kW',
      location: 'Main Substation Bus A',
      status: 'NORMAL',
      threshold: '< 500.0 kW',
      reason: 'Active power demand within contracted substation kVA limit',
      latitude: 13.0830,
      longitude: 80.2640,
    ),
    IndustrialSensor(
      id: 'SMK-11',
      name: 'Flue Gas Opacity & Smoke Monitor',
      parameter: 'Smoke Density',
      value: 1.2,
      unit: '%',
      location: 'Annealing Furnace Chimney',
      status: 'NORMAL',
      threshold: '< 3.0 %',
      reason: 'Clean combustion envelope verified by optical opacity sensor',
      latitude: 13.0890,
      longitude: 80.2730,
    ),
    IndustrialSensor(
      id: 'PRS-12',
      name: 'Pneumatic Ring Main Pressure Sensor',
      parameter: 'Pressure',
      value: 7.4,
      unit: 'bar',
      location: 'Pneumatic Utility Distribution',
      status: 'NORMAL',
      threshold: '6.5–8.0 bar',
      reason: 'Compressed air distribution pressure stable with zero pressure drop',
      latitude: 13.0845,
      longitude: 80.2715,
    ),
  ];

  SensorRepository(this._apiService);

  Future<List<IndustrialSensor>> fetchIndustrialSensors() async {
    try {
      final response = await _apiService.get('/api/sensor/industrial');
      if (response.data is List && (response.data as List).isNotEmpty) {
        return (response.data as List).map((e) => IndustrialSensor.fromJson(e)).toList();
      }
    } catch (_) {}
    return List<IndustrialSensor>.from(_defaultSensors);
  }

  Future<List<SensorData>> fetchLiveSensorData() async {
    try {
      final response = await _apiService.get('/api/sensor/live');
      if (response.data is List && (response.data as List).isNotEmpty) {
        return (response.data as List).map((e) => SensorData.fromJson(e)).toList();
      }
    } catch (_) {}
    return _defaultSensors.map((s) => SensorData(
      sensorId: s.id,
      co2: s.parameter == 'CO2' ? s.value : 410.0,
      pm25: s.parameter == 'PM2.5' ? s.value : 28.0,
      pm10: s.parameter == 'PM10' ? s.value : 50.0,
      temperature: s.parameter == 'Temperature' ? s.value : 28.5,
      humidity: s.parameter == 'Humidity' ? s.value : 52.0,
      timestamp: DateTime.now(),
    )).toList();
  }

  Future<void> postSensorData(Map<String, dynamic> data) async {
    try {
      await _apiService.post('/api/sensor/data', data: data);
    } catch (_) {}
  }
}
