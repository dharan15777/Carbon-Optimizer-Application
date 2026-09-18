import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/map_provider.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  GoogleMapController? _mapController;
  String _activeLayer = 'HEATMAP'; // 'HEATMAP', 'POLLUTION', 'SENSORS', 'RISK'
  Map<String, dynamic>? _selectedNode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapProvider>().fetchAllMapData();
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Set<Marker> _buildMarkers(MapProvider provider) {
    final markers = <Marker>{};

    if (_activeLayer == 'SENSORS' || _activeLayer == 'HEATMAP') {
      for (final sensor in provider.sensorLocations) {
        final lat = (sensor['lat'] as num?)?.toDouble() ?? AppConstants.defaultLat;
        final lng = (sensor['lng'] as num?)?.toDouble() ?? AppConstants.defaultLng;
        final id = sensor['id']?.toString() ?? 'sensor';

        markers.add(
          Marker(
            markerId: MarkerId(id),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: sensor['name']?.toString() ?? 'Sensor Node',
              snippet: 'CO₂: ${sensor['co2'] ?? 400} ppm • Temp: ${sensor['temp'] ?? 28}°C',
              onTap: () => setState(() => _selectedNode = sensor),
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              sensor['status'] == 'ONLINE' ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueOrange,
            ),
          ),
        );
      }
    }

    if (_activeLayer == 'RISK') {
      for (final zone in provider.highRiskZones) {
        final lat = (zone['lat'] as num?)?.toDouble() ?? AppConstants.defaultLat;
        final lng = (zone['lng'] as num?)?.toDouble() ?? AppConstants.defaultLng;
        final id = zone['id']?.toString() ?? 'zone';

        markers.add(
          Marker(
            markerId: MarkerId(id),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: zone['name']?.toString() ?? 'Risk Zone',
              snippet: zone['reason']?.toString() ?? 'High carbon emission area',
              onTap: () => setState(() => _selectedNode = zone),
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          ),
        );
      }
    }

    return markers;
  }

  Set<Circle> _buildCircles(MapProvider provider) {
    final circles = <Circle>{};

    if (_activeLayer == 'HEATMAP') {
      for (int i = 0; i < provider.heatmapData.length; i++) {
        final pt = provider.heatmapData[i];
        final lat = (pt['lat'] as num?)?.toDouble() ?? AppConstants.defaultLat;
        final lng = (pt['lng'] as num?)?.toDouble() ?? AppConstants.defaultLng;
        final intensity = (pt['intensity'] as num?)?.toDouble() ?? 150.0;
        final radius = (pt['radius'] as num?)?.toDouble() ?? 1200.0;

        Color circleColor;
        if (intensity < AppConstants.carbonCleanThreshold) {
          circleColor = AppTheme.primaryGreen.withOpacity(0.35);
        } else if (intensity < AppConstants.carbonModerateThreshold) {
          circleColor = AppTheme.primaryYellow.withOpacity(0.35);
        } else {
          circleColor = AppTheme.primaryRed.withOpacity(0.35);
        }

        circles.add(
          Circle(
            circleId: CircleId('heat_$i'),
            center: LatLng(lat, lng),
            radius: radius,
            fillColor: circleColor,
            strokeColor: circleColor.withOpacity(0.8),
            strokeWidth: 2,
          ),
        );
      }
    }

    if (_activeLayer == 'RISK') {
      for (int i = 0; i < provider.highRiskZones.length; i++) {
        final zone = provider.highRiskZones[i];
        final lat = (zone['lat'] as num?)?.toDouble() ?? AppConstants.defaultLat;
        final lng = (zone['lng'] as num?)?.toDouble() ?? AppConstants.defaultLng;
        final radius = (zone['radius'] as num?)?.toDouble() ?? 2000.0;

        circles.add(
          Circle(
            circleId: CircleId('risk_$i'),
            center: LatLng(lat, lng),
            radius: radius,
            fillColor: AppTheme.primaryRed.withOpacity(0.4),
            strokeColor: AppTheme.primaryRed,
            strokeWidth: 3,
          ),
        );
      }
    }

    return circles;
  }

  @override
  Widget build(BuildContext context) {
    final mapProvider = context.watch<MapProvider>();
    final markers = _buildMarkers(mapProvider);
    final circles = _buildCircles(mapProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carbon GIS & Heatmap'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<MapProvider>().fetchAllMapData(),
            tooltip: 'Refresh Map Data',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map with safe error boundary
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(AppConstants.defaultLat, AppConstants.defaultLng),
              zoom: AppConstants.defaultZoom,
            ),
            markers: markers,
            circles: circles,
            onMapCreated: (controller) => _mapController = controller,
            mapType: MapType.normal,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          // Layer Control Buttons
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              children: [
                _buildLayerButton(
                  icon: Icons.thermostat,
                  label: 'Heatmap',
                  layerKey: 'HEATMAP',
                  activeColor: AppTheme.primaryGreen,
                ),
                const SizedBox(height: 8),
                _buildLayerButton(
                  icon: Icons.air,
                  label: 'Pollution',
                  layerKey: 'POLLUTION',
                  activeColor: AppTheme.primaryYellow,
                ),
                const SizedBox(height: 8),
                _buildLayerButton(
                  icon: Icons.sensors,
                  label: 'Sensors',
                  layerKey: 'SENSORS',
                  activeColor: AppTheme.primaryCyan,
                ),
                const SizedBox(height: 8),
                _buildLayerButton(
                  icon: Icons.warning,
                  label: 'Risk Zones',
                  layerKey: 'RISK',
                  activeColor: AppTheme.primaryRed,
                ),
              ],
            ),
          ),

          // Map Legend
          Positioned(
            bottom: _selectedNode != null ? 180 : 16,
            left: 16,
            child: Card(
              color: AppTheme.cardDark.withOpacity(0.92),
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
                    _buildLegend(AppTheme.primaryGreen, 'Clean (<150 gCO₂)'),
                    _buildLegend(AppTheme.primaryYellow, 'Moderate (150-300)'),
                    _buildLegend(AppTheme.primaryRed, 'High Risk (>300)'),
                    _buildLegend(AppTheme.primaryCyan, 'Active Sensor Node'),
                  ],
                ),
              ),
            ),
          ),

          // Detail Card when marker selected
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
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedNode!['reason']?.toString() ??
                                  'CO₂: ${_selectedNode!['co2'] ?? 400} ppm • Temp: ${_selectedNode!['temp'] ?? 28}°C',
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
      onTap: () => setState(() => _activeLayer = layerKey),
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
