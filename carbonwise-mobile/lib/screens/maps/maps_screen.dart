import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/map_provider.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  final MapController _mapController = MapController();
  String _activeLayer = 'HEATMAP'; // 'HEATMAP', 'POLLUTION', 'SENSORS', 'RISK'
  Map<String, dynamic>? _selectedNode;

  // Demo sensor data for the Chennai area
  static const List<Map<String, dynamic>> _demoSensors = [
    {'id': 's1', 'name': 'Ambattur Industrial', 'lat': 13.1143, 'lng': 80.1548, 'co2': 387, 'temp': 31, 'status': 'ONLINE', 'intensity': 280},
    {'id': 's2', 'name': 'Guindy Sensor Hub', 'lat': 13.0069, 'lng': 80.2205, 'co2': 412, 'temp': 29, 'status': 'ONLINE', 'intensity': 340},
    {'id': 's3', 'name': 'Anna Nagar Monitor', 'lat': 13.0850, 'lng': 80.2101, 'co2': 362, 'temp': 28, 'status': 'ONLINE', 'intensity': 180},
    {'id': 's4', 'name': 'Perungudi Tech Park', 'lat': 12.9677, 'lng': 80.2356, 'co2': 445, 'temp': 30, 'status': 'ONLINE', 'intensity': 420},
    {'id': 's5', 'name': 'Manali Refinery Zone', 'lat': 13.1638, 'lng': 80.2613, 'co2': 520, 'temp': 33, 'status': 'ONLINE', 'intensity': 490},
    {'id': 's6', 'name': 'Sholinganallur Node', 'lat': 12.9010, 'lng': 80.2279, 'co2': 325, 'temp': 27, 'status': 'ONLINE', 'intensity': 145},
    {'id': 's7', 'name': 'Padi Junction', 'lat': 13.1204, 'lng': 80.2029, 'co2': 398, 'temp': 30, 'status': 'OFFLINE', 'intensity': 300},
    {'id': 's8', 'name': 'Velachery Monitor', 'lat': 12.9816, 'lng': 80.2209, 'co2': 355, 'temp': 28, 'status': 'ONLINE', 'intensity': 170},
  ];

  static const List<Map<String, dynamic>> _demoRiskZones = [
    {'id': 'r1', 'name': 'Manali Industrial Cluster', 'lat': 13.1638, 'lng': 80.2613, 'radius': 2500.0, 'reason': 'Petroleum refinery — high emission zone'},
    {'id': 'r2', 'name': 'Perungudi IT Corridor', 'lat': 12.9677, 'lng': 80.2356, 'radius': 1800.0, 'reason': 'Dense traffic & generator exhaust'},
    {'id': 'r3', 'name': 'Guindy Industrial Estate', 'lat': 13.0069, 'lng': 80.2205, 'radius': 2000.0, 'reason': 'Manufacturing plant emissions'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapProvider>().fetchAllMapData();
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  List<Marker> _buildMarkers() {
    if (_activeLayer == 'RISK') {
      return _demoRiskZones.map((zone) {
        return Marker(
          point: LatLng((zone['lat'] as num).toDouble(), (zone['lng'] as num).toDouble()),
          width: 36,
          height: 36,
          child: GestureDetector(
            onTap: () => setState(() => _selectedNode = zone),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.primaryRed.withOpacity(0.85),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [BoxShadow(color: AppTheme.primaryRed.withOpacity(0.5), blurRadius: 8)],
              ),
              child: const Icon(Icons.warning_rounded, color: Colors.white, size: 18),
            ),
          ),
        );
      }).toList();
    }

    // SENSORS / HEATMAP layer
    return _demoSensors.map((s) {
      final intensity = (s['intensity'] as num).toDouble();
      Color markerColor;
      if (intensity < AppConstants.carbonCleanThreshold) {
        markerColor = AppTheme.primaryGreen;
      } else if (intensity < AppConstants.carbonModerateThreshold) {
        markerColor = AppTheme.primaryYellow;
      } else {
        markerColor = AppTheme.primaryRed;
      }
      final isOnline = s['status'] == 'ONLINE';

      return Marker(
        point: LatLng((s['lat'] as num).toDouble(), (s['lng'] as num).toDouble()),
        width: 34,
        height: 34,
        child: GestureDetector(
          onTap: () => setState(() => _selectedNode = s),
          child: Container(
            decoration: BoxDecoration(
              color: markerColor.withOpacity(0.9),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: [BoxShadow(color: markerColor.withOpacity(0.5), blurRadius: 8)],
            ),
            child: Icon(
              isOnline ? Icons.sensors : Icons.sensors_off,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      );
    }).toList();
  }

  List<CircleMarker> _buildCircles() {
    if (_activeLayer == 'RISK') {
      return _demoRiskZones.map((zone) {
        return CircleMarker(
          point: LatLng((zone['lat'] as num).toDouble(), (zone['lng'] as num).toDouble()),
          radius: (zone['radius'] as num).toDouble(),
          useRadiusInMeter: true,
          color: AppTheme.primaryRed.withOpacity(0.25),
          borderColor: AppTheme.primaryRed.withOpacity(0.7),
          borderStrokeWidth: 2,
        );
      }).toList();
    }

    if (_activeLayer == 'HEATMAP') {
      return _demoSensors.map((s) {
        final intensity = (s['intensity'] as num).toDouble();
        Color circleColor;
        if (intensity < AppConstants.carbonCleanThreshold) {
          circleColor = AppTheme.primaryGreen;
        } else if (intensity < AppConstants.carbonModerateThreshold) {
          circleColor = AppTheme.primaryYellow;
        } else {
          circleColor = AppTheme.primaryRed;
        }

        return CircleMarker(
          point: LatLng((s['lat'] as num).toDouble(), (s['lng'] as num).toDouble()),
          radius: 1200,
          useRadiusInMeter: true,
          color: circleColor.withOpacity(0.22),
          borderColor: circleColor.withOpacity(0.55),
          borderStrokeWidth: 1.5,
        );
      }).toList();
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    final markers = _buildMarkers();
    final circles = _buildCircles();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceDark,
        title: const Row(
          children: [
            Icon(Icons.map_outlined, color: AppTheme.primaryGreen, size: 20),
            SizedBox(width: 8),
            Text('Carbon GIS & Heatmap'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () => context.read<MapProvider>().fetchAllMapData(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Stack(
        children: [
          // OpenStreetMap (no API key needed)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(AppConstants.defaultLat, AppConstants.defaultLng),
              initialZoom: AppConstants.defaultZoom,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.carbonwise_mobile',
              ),
              if (circles.isNotEmpty)
                CircleLayer(circles: circles),
              MarkerLayer(markers: markers),
            ],
          ),

          // Layer Control Buttons (top right)
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              children: [
                _buildLayerButton(icon: Icons.thermostat, label: 'Heatmap', layerKey: 'HEATMAP', activeColor: AppTheme.primaryGreen),
                const SizedBox(height: 8),
                _buildLayerButton(icon: Icons.air, label: 'Pollution', layerKey: 'POLLUTION', activeColor: AppTheme.primaryYellow),
                const SizedBox(height: 8),
                _buildLayerButton(icon: Icons.sensors, label: 'Sensors', layerKey: 'SENSORS', activeColor: AppTheme.primaryCyan),
                const SizedBox(height: 8),
                _buildLayerButton(icon: Icons.warning, label: 'Risk', layerKey: 'RISK', activeColor: AppTheme.primaryRed),
              ],
            ),
          ),

          // Legend (bottom left)
          Positioned(
            bottom: _selectedNode != null ? 180 : 16,
            left: 16,
            child: Card(
              color: AppTheme.cardDark.withOpacity(0.93),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Layer: $_activeLayer',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    _buildLegend(AppTheme.primaryGreen, 'Clean (<150 gCO₂/kWh)'),
                    _buildLegend(AppTheme.primaryYellow, 'Moderate (150–300)'),
                    _buildLegend(AppTheme.primaryRed, 'High Risk (>300)'),
                    _buildLegend(AppTheme.primaryCyan, 'Active Sensor'),
                    const SizedBox(height: 4),
                    const Text(
                      '© OpenStreetMap contributors',
                      style: TextStyle(fontSize: 8, color: Colors.white38),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Selected node detail card (bottom)
          if (_selectedNode != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                color: AppTheme.cardDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppTheme.primaryGreen),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGreen.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.location_on, color: AppTheme.primaryGreen, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _selectedNode!['name']?.toString() ?? 'Selected Node',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedNode!.containsKey('reason')
                                  ? _selectedNode!['reason'].toString()
                                  : 'CO₂: ${_selectedNode!['co2'] ?? 400} ppm  •  Temp: ${_selectedNode!['temp'] ?? 28}°C  •  ${_selectedNode!['status'] ?? 'ONLINE'}',
                              style: const TextStyle(fontSize: 12, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white54),
                        onPressed: () => setState(() => _selectedNode = null),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLayerButton({
    required IconData icon,
    required String label,
    required String layerKey,
    required Color activeColor,
  }) {
    final isActive = _activeLayer == layerKey;
    return GestureDetector(
      onTap: () => setState(() {
        _activeLayer = layerKey;
        _selectedNode = null;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withOpacity(0.3) : Colors.black.withOpacity(0.75),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? activeColor : Colors.white24,
            width: isActive ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isActive ? activeColor : Colors.white70, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: isActive ? Colors.white : Colors.white60,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String label) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70)),
          ],
        ),
      );
}
