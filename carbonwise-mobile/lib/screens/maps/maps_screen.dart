import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/map_provider.dart';
import '../../providers/device_provider.dart';
import '../../providers/sensor_provider.dart';
import '../../models/device_model.dart';
import '../../models/sensor_model.dart';

class MapsScreen extends StatefulWidget {
  const MapsScreen({super.key});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  final MapController _mapController = MapController();
  String _activeLayer = 'DEVICES'; // DEVICES, SENSORS, RISK, POLLUTION, HEATMAP, HOTSPOTS
  bool _useSchematicView = false;
  String _searchQuery = '';
  dynamic _selectedItem; // Device, IndustrialSensor, or Map<String, dynamic>

  static const List<Map<String, dynamic>> _demoRiskZones = [
    {
      'id': 'RZ-01',
      'name': 'Furnace Thermal Corridor',
      'lat': 13.0850,
      'lng': 80.2720,
      'radius': 1400.0,
      'risk': 'HIGH RISK',
      'reason': 'Continuous thermal radiant heat + high electric demand (>110 kW)',
    },
    {
      'id': 'RZ-02',
      'name': 'Heavy Machining & Press Bay',
      'lat': 13.0805,
      'lng': 80.2690,
      'radius': 1100.0,
      'risk': 'MEDIUM RISK',
      'reason': 'Particulate matter PM2.5 > 80 µg/m³ and acoustic vibration',
    },
    {
      'id': 'RZ-03',
      'name': 'Boiler Fuel Manifold Yard',
      'lat': 13.0880,
      'lng': 80.2760,
      'radius': 1200.0,
      'risk': 'HIGH RISK',
      'reason': 'Scope 1 fuel consumption hotspot and steam generation line',
    },
  ];

  static const List<Map<String, dynamic>> _demoPollutionHotspots = [
    {'id': 'POL-1', 'name': 'Machining Exhaust Plume', 'lat': 13.0810, 'lng': 80.2710, 'intensity': 420.0, 'radius': 900.0},
    {'id': 'POL-2', 'name': 'Chimney Flue Gas Stack', 'lat': 13.0890, 'lng': 80.2730, 'intensity': 480.0, 'radius': 1100.0},
    {'id': 'POL-3', 'name': 'Logistics Loading Dock', 'lat': 13.0780, 'lng': 80.2670, 'intensity': 350.0, 'radius': 850.0},
  ];

  // Coordinates mapping for the 12 machines across the facility
  final List<LatLng> _machineCoordinates = const [
    LatLng(13.0835, 80.2700), // CNC
    LatLng(13.0825, 80.2715), // Motor
    LatLng(13.0842, 80.2692), // Air Compressor
    LatLng(13.0855, 80.2685), // HVAC
    LatLng(13.0818, 80.2730), // Injection Molding
    LatLng(13.0810, 80.2705), // Conveyor
    LatLng(13.0820, 80.2675), // Pump
    LatLng(13.0830, 80.2740), // Welder
    LatLng(13.0865, 80.2725), // Boiler
    LatLng(13.0875, 80.2710), // Furnace
    LatLng(13.0848, 80.2750), // Chiller
    LatLng(13.0805, 80.2720), // Packaging
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapProvider>().fetchAllMapData();
      context.read<DeviceProvider>().fetchDevices();
      context.read<SensorProvider>().fetchIndustrialSensors();
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final devices = context.watch<DeviceProvider>().devices;
    final sensors = context.watch<SensorProvider>().sensors;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceDark,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CARBON GIS & INDUSTRIAL MAP', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: Colors.white)),
            Text('Multi-Layer Asset, Sensor & Hotspot GIS', style: TextStyle(fontSize: 10, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_useSchematicView ? Icons.map_outlined : Icons.account_tree_outlined, color: AppTheme.primaryGreen),
            tooltip: _useSchematicView ? 'Switch to GIS Map' : 'Switch to Plant Schematic View',
            onPressed: () => setState(() => _useSchematicView = !_useSchematicView),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            tooltip: 'Refresh GIS Telemetry',
            onPressed: () {
              context.read<MapProvider>().fetchAllMapData();
              context.read<DeviceProvider>().fetchDevices();
              context.read<SensorProvider>().fetchIndustrialSensors();
            },
          ),
        ],
      ),
      body: _useSchematicView ? _buildSchematicPlantView(devices, sensors) : _buildGisMapView(devices, sensors),
    );
  }

  Widget _buildGisMapView(List<Device> devices, List<IndustrialSensor> sensors) {
    final markers = _buildMarkers(devices, sensors);
    final circles = _buildCircles(devices);

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: const MapOptions(
            initialCenter: LatLng(AppConstants.defaultLat, AppConstants.defaultLng),
            initialZoom: 14.5,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.carbonwise_mobile',
            ),
            if (circles.isNotEmpty) CircleLayer(circles: circles),
            MarkerLayer(markers: markers),
          ],
        ),

        // Search Bar (top)
        Positioned(
          top: 12,
          left: 16,
          right: 90,
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark.withOpacity(0.94),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6)],
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.white54, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    decoration: const InputDecoration(
                      hintText: 'Search machine, sensor, zone...',
                      hintStyle: TextStyle(color: Colors.white38, fontSize: 12),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  GestureDetector(
                    onTap: () => setState(() => _searchQuery = ''),
                    child: const Icon(Icons.close, color: Colors.white54, size: 16),
                  ),
              ],
            ),
          ),
        ),

        // Layer Controls (top right)
        Positioned(
          top: 12,
          right: 12,
          child: Column(
            children: [
              _buildLayerBtn(Icons.precision_manufacturing, 'Devices', 'DEVICES', AppTheme.primaryGreen),
              const SizedBox(height: 6),
              _buildLayerBtn(Icons.sensors, 'Sensors', 'SENSORS', AppTheme.primaryCyan),
              const SizedBox(height: 6),
              _buildLayerBtn(Icons.warning, 'Risk Zones', 'RISK', Colors.redAccent),
              const SizedBox(height: 6),
              _buildLayerBtn(Icons.air, 'Pollution', 'POLLUTION', Colors.orangeAccent),
              const SizedBox(height: 6),
              _buildLayerBtn(Icons.thermostat, 'Heatmap', 'HEATMAP', AppTheme.primaryYellow),
              const SizedBox(height: 6),
              _buildLayerBtn(Icons.local_fire_department, 'Hotspots', 'HOTSPOTS', Colors.deepOrangeAccent),
            ],
          ),
        ),

        // Zoom Controls (bottom right)
        Positioned(
          bottom: _selectedItem != null ? 220 : 70,
          right: 14,
          child: Column(
            children: [
              _buildZoomBtn(Icons.add, () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom + 1)),
              const SizedBox(height: 6),
              _buildZoomBtn(Icons.remove, () => _mapController.move(_mapController.camera.center, _mapController.camera.zoom - 1)),
              const SizedBox(height: 6),
              _buildZoomBtn(Icons.my_location, () => _mapController.move(const LatLng(AppConstants.defaultLat, AppConstants.defaultLng), 14.5)),
            ],
          ),
        ),

        // Active Layer Indicator (bottom left)
        Positioned(
          bottom: _selectedItem != null ? 220 : 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark.withOpacity(0.92),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.primaryGreen, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text('Layer: $_activeLayer', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
        ),

        // Bottom Selected Item Detail Sheet
        if (_selectedItem != null)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: _buildSelectedItemCard(),
          ),
      ],
    );
  }

  Widget _buildSelectedItemCard() {
    if (_selectedItem is Device) {
      final d = _selectedItem as Device;
      final load = d.powerRating > 0 ? ((d.liveKw / d.powerRating) * 100).toStringAsFixed(0) : '0';
      return Card(
        color: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: AppTheme.primaryGreen)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(d.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (d.risk == 'HIGH' ? Colors.redAccent : AppTheme.primaryGreen).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(d.risk, style: TextStyle(color: d.risk == 'HIGH' ? Colors.redAccent : AppTheme.primaryGreen, fontSize: 9.5, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.white54),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => setState(() => _selectedItem = null),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('ID: ${d.id} • ${d.location}', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5))),
              const SizedBox(height: 10),
              const Divider(height: 1, color: Colors.white10),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMetricCol('Power', '${d.liveKw.toStringAsFixed(1)} kW'),
                  _buildMetricCol('Load', '$load%'),
                  _buildMetricCol('Energy', '${d.liveKwh.toStringAsFixed(1)} kWh'),
                  _buildMetricCol('CO₂', '${d.liveCarbon.toStringAsFixed(1)} kg'),
                  _buildMetricCol('Temp', '${d.temp.toStringAsFixed(0)}°C'),
                  _buildMetricCol('Vibration', '${d.vib.toStringAsFixed(1)} mm/s'),
                ],
              ),
            ],
          ),
        ),
      );
    } else if (_selectedItem is IndustrialSensor) {
      final s = _selectedItem as IndustrialSensor;
      final isAbn = s.status == 'WARNING' || s.status == 'CRITICAL';
      return Card(
        color: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: isAbn ? Colors.orangeAccent : AppTheme.primaryCyan)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text('${s.id}: ${s.parameter}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: (isAbn ? Colors.orangeAccent : AppTheme.primaryGreen).withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                    child: Text(s.status, style: TextStyle(color: isAbn ? Colors.orangeAccent : AppTheme.primaryGreen, fontSize: 9.5, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.white54),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => setState(() => _selectedItem = null),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('Reading: ${s.value} ${s.unit} • Threshold: ${s.threshold} • Location: ${s.location}', style: TextStyle(fontSize: 11, color: isAbn ? Colors.orangeAccent : Colors.white70)),
              const SizedBox(height: 4),
              Text('Diagnosis: ${s.reason}', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.6))),
            ],
          ),
        ),
      );
    } else if (_selectedItem is Map<String, dynamic>) {
      final m = _selectedItem as Map<String, dynamic>;
      return Card(
        color: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: const BorderSide(color: Colors.redAccent)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(m['name']?.toString() ?? 'Industrial Risk Area', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: Colors.white54),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => setState(() => _selectedItem = null),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(m['reason']?.toString() ?? 'High emission concentration', style: const TextStyle(fontSize: 11, color: Colors.white70)),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildMetricCol(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(val, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 8.5, color: Colors.white38)),
      ],
    );
  }

  List<Marker> _buildMarkers(List<Device> devices, List<IndustrialSensor> sensors) {
    final List<Marker> list = [];

    // 1. Industrial Devices Layer
    if (_activeLayer == 'DEVICES' || _activeLayer == 'HOTSPOTS') {
      for (var i = 0; i < devices.length; i++) {
        final d = devices[i];
        if (_searchQuery.isNotEmpty && !d.name.toLowerCase().contains(_searchQuery) && !d.id.toLowerCase().contains(_searchQuery)) {
          continue;
        }
        final pos = i < _machineCoordinates.length ? _machineCoordinates[i] : const LatLng(AppConstants.defaultLat, AppConstants.defaultLng);
        final isHighRisk = d.risk == 'HIGH';
        final markerColor = isHighRisk ? Colors.redAccent : AppTheme.primaryGreen;

        list.add(Marker(
          point: pos,
          width: 38,
          height: 38,
          child: GestureDetector(
            onTap: () => setState(() => _selectedItem = d),
            child: Container(
              decoration: BoxDecoration(
                color: markerColor.withOpacity(0.9),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [BoxShadow(color: markerColor.withOpacity(0.5), blurRadius: 8)],
              ),
              child: const Icon(Icons.precision_manufacturing, color: Colors.white, size: 18),
            ),
          ),
        ));
      }
    }

    // 2. Sensors Layer
    if (_activeLayer == 'SENSORS') {
      for (final s in sensors) {
        if (_searchQuery.isNotEmpty && !s.parameter.toLowerCase().contains(_searchQuery) && !s.id.toLowerCase().contains(_searchQuery)) {
          continue;
        }
        final isAbn = s.status == 'WARNING' || s.status == 'CRITICAL';
        final color = isAbn ? Colors.orangeAccent : AppTheme.primaryCyan;

        list.add(Marker(
          point: LatLng(s.latitude, s.longitude),
          width: 36,
          height: 36,
          child: GestureDetector(
            onTap: () => setState(() => _selectedItem = s),
            child: Container(
              decoration: BoxDecoration(
                color: color.withOpacity(0.9),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8)],
              ),
              child: Icon(isAbn ? Icons.warning_amber_rounded : Icons.sensors, color: Colors.white, size: 18),
            ),
          ),
        ));
      }
    }

    // 3. Risk Zones Markers
    if (_activeLayer == 'RISK') {
      for (final r in _demoRiskZones) {
        list.add(Marker(
          point: LatLng(r['lat'] as double, r['lng'] as double),
          width: 36,
          height: 36,
          child: GestureDetector(
            onTap: () => setState(() => _selectedItem = r),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.9),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [BoxShadow(color: Colors.redAccent.withOpacity(0.5), blurRadius: 8)],
              ),
              child: const Icon(Icons.warning, color: Colors.white, size: 18),
            ),
          ),
        ));
      }
    }

    return list;
  }

  List<CircleMarker> _buildCircles(List<Device> devices) {
    if (_activeLayer == 'RISK') {
      return _demoRiskZones.map((r) => CircleMarker(
        point: LatLng(r['lat'] as double, r['lng'] as double),
        radius: r['radius'] as double,
        useRadiusInMeter: true,
        color: Colors.redAccent.withOpacity(0.22),
        borderColor: Colors.redAccent.withOpacity(0.7),
        borderStrokeWidth: 2,
      )).toList();
    }

    if (_activeLayer == 'POLLUTION') {
      return _demoPollutionHotspots.map((p) => CircleMarker(
        point: LatLng(p['lat'] as double, p['lng'] as double),
        radius: p['radius'] as double,
        useRadiusInMeter: true,
        color: Colors.orangeAccent.withOpacity(0.24),
        borderColor: Colors.orangeAccent.withOpacity(0.65),
        borderStrokeWidth: 2,
      )).toList();
    }

    if (_activeLayer == 'HEATMAP') {
      return _demoPollutionHotspots.map((p) => CircleMarker(
        point: LatLng(p['lat'] as double, p['lng'] as double),
        radius: 1200.0,
        useRadiusInMeter: true,
        color: AppTheme.primaryGreen.withOpacity(0.25),
        borderColor: AppTheme.primaryGreen.withOpacity(0.6),
        borderStrokeWidth: 1.5,
      )).toList();
    }

    if (_activeLayer == 'HOTSPOTS') {
      // Highlight top 5 high-power machines
      final topMachines = List<Device>.from(devices)..sort((a, b) => b.powerRating.compareTo(a.powerRating));
      final circles = <CircleMarker>[];
      for (var i = 0; i < topMachines.take(5).length; i++) {
        final pos = i < _machineCoordinates.length ? _machineCoordinates[i] : const LatLng(AppConstants.defaultLat, AppConstants.defaultLng);
        circles.add(CircleMarker(
          point: pos,
          radius: 950.0,
          useRadiusInMeter: true,
          color: Colors.deepOrangeAccent.withOpacity(0.28),
          borderColor: Colors.deepOrangeAccent.withOpacity(0.75),
          borderStrokeWidth: 2,
        ));
      }
      return circles;
    }

    return [];
  }

  Widget _buildLayerBtn(IconData icon, String label, String key, Color color) {
    final isSelected = _activeLayer == key;
    return GestureDetector(
      onTap: () => setState(() {
        _activeLayer = key;
        _selectedItem = null;
      }),
      child: Container(
        width: 72,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.25) : AppTheme.surfaceDark.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? color : Colors.white12, width: isSelected ? 1.5 : 1.0),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: isSelected ? color : Colors.white70),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 8.5, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? Colors.white : Colors.white60)),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomBtn(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark.withOpacity(0.92),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4)],
      ),
      child: IconButton(
        icon: Icon(icon, size: 18, color: Colors.white70),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
      ),
    );
  }

  // Fallback Plant Schematic Layout (never blank even without external tile connectivity)
  Widget _buildSchematicPlantView(List<Device> devices, List<IndustrialSensor> sensors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.account_tree, color: AppTheme.primaryGreen, size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PLANT SCHEMATIC GIS VIEW (OFFLINE READY)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: 2),
                      Text('Industrial shopfloor topology & telemetry nodes active without internet dependency', style: TextStyle(fontSize: 10, color: Colors.white60)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('SHOPFLOOR BAY ALLOCATIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70)),
          const SizedBox(height: 10),
          ...devices.map((d) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: d.risk == 'HIGH' ? Colors.redAccent.withOpacity(0.3) : Colors.white10),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.precision_manufacturing, color: AppTheme.primaryGreen, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('${d.id} • ${d.location}', style: TextStyle(fontSize: 9.5, color: Colors.white.withOpacity(0.5))),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${d.liveKw.toStringAsFixed(1)} kW', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('${d.liveCarbon.toStringAsFixed(1)} kg CO₂', style: const TextStyle(fontSize: 9.5, color: AppTheme.primaryGreen)),
                  ],
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
