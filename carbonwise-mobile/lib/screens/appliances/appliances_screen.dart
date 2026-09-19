import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/device_provider.dart';
import '../../providers/sensor_provider.dart';
import '../../models/device_model.dart';
import '../../models/sensor_model.dart';

class AppliancesScreen extends StatefulWidget {
  const AppliancesScreen({super.key});

  @override
  State<AppliancesScreen> createState() => _AppliancesScreenState();
}

class _AppliancesScreenState extends State<AppliancesScreen> {
  int _viewMode = 0; // 0 = 12 Machines, 1 = 12 Sensors
  String _machineFilter = 'ALL'; // ALL, ONLINE, OFFLINE, HIGH RISK, HIGH CARBON
  String _sensorFilter = 'ALL'; // ALL, WARNING, NORMAL

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeviceProvider>().fetchDevices();
      context.read<SensorProvider>().fetchIndustrialSensors();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceDark,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _viewMode == 0 ? 'INDUSTRIAL DEVICE CENTER' : 'INDUSTRIAL SENSOR CENTER',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: Colors.white),
            ),
            const Text(
              '12 Monitored Units • Live Telemetry Active',
              style: TextStyle(fontSize: 10, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () {
              context.read<DeviceProvider>().fetchDevices();
              context.read<SensorProvider>().fetchIndustrialSensors();
            },
            tooltip: 'Refresh Assets & Telemetry',
          ),
        ],
      ),
      floatingActionButton: _viewMode == 0
          ? FloatingActionButton.extended(
              onPressed: _showAddDeviceModal,
              backgroundColor: AppTheme.primaryGreen,
              icon: const Icon(Icons.add, color: AppTheme.backgroundDark),
              label: const Text('+ ADD DEVICE', style: TextStyle(color: AppTheme.backgroundDark, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
            )
          : null,
      body: Column(
        children: [
          _buildSegmentedTabSelector(),
          if (_viewMode == 0) _buildMachineFilterChips() else _buildSensorFilterChips(),
          Expanded(
            child: _viewMode == 0 ? _buildMachinesView() : _buildSensorsView(),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedTabSelector() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _viewMode = 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: _viewMode == 0 ? AppTheme.primaryGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.precision_manufacturing, size: 16, color: _viewMode == 0 ? AppTheme.backgroundDark : Colors.white60),
                    const SizedBox(width: 6),
                    Text(
                      '12 MACHINES',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: _viewMode == 0 ? AppTheme.backgroundDark : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _viewMode = 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: _viewMode == 1 ? AppTheme.primaryGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sensors, size: 16, color: _viewMode == 1 ? AppTheme.backgroundDark : Colors.white60),
                    const SizedBox(width: 6),
                    Text(
                      '12 SENSORS',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: _viewMode == 1 ? AppTheme.backgroundDark : Colors.white70,
                      ),
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

  Widget _buildMachineFilterChips() {
    final filters = ['ALL', 'ONLINE', 'OFFLINE', 'HIGH RISK', 'HIGH CARBON'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: filters.map((f) {
          final isSelected = _machineFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                f,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppTheme.backgroundDark : Colors.white70,
                ),
              ),
              selected: isSelected,
              selectedColor: AppTheme.primaryGreen,
              backgroundColor: AppTheme.surfaceDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              onSelected: (val) => setState(() => _machineFilter = f),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSensorFilterChips() {
    final filters = ['ALL', 'WARNING', 'NORMAL'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: filters.map((f) {
          final isSelected = _sensorFilter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                f == 'WARNING' ? 'WARNING / ABNORMAL' : f,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppTheme.backgroundDark : Colors.white70,
                ),
              ),
              selected: isSelected,
              selectedColor: AppTheme.primaryGreen,
              backgroundColor: AppTheme.surfaceDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              onSelected: (val) => setState(() => _sensorFilter = f),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMachinesView() {
    return Consumer<DeviceProvider>(
      builder: (context, provider, _) {
        final devices = provider.devices;
        List<Device> filtered;

        switch (_machineFilter) {
          case 'ONLINE':
            filtered = devices.where((d) => d.status.toUpperCase() == 'ONLINE').toList();
            break;
          case 'OFFLINE':
            filtered = devices.where((d) => d.status.toUpperCase() == 'OFFLINE').toList();
            break;
          case 'HIGH RISK':
            filtered = devices.where((d) => d.risk.toUpperCase() == 'HIGH').toList();
            break;
          case 'HIGH CARBON':
            filtered = devices.where((d) => d.powerRating >= 40.0 || (d.carbonKg ?? 0) >= 50.0).toList();
            break;
          case 'ALL':
          default:
            filtered = devices;
            break;
        }

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.precision_manufacturing_outlined, size: 56, color: Colors.white.withOpacity(0.3)),
                const SizedBox(height: 16),
                const Text('No machines match filter', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white70)),
                const SizedBox(height: 8),
                ElevatedButton(onPressed: _showAddDeviceModal, child: const Text('+ Add Machine')),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
          itemCount: filtered.length,
          itemBuilder: (context, index) => _buildCompactMachineCard(filtered[index]),
        );
      },
    );
  }

  Widget _buildCompactMachineCard(Device dev) {
    final isOnline = dev.status.toUpperCase() == 'ONLINE';
    final isConnecting = dev.status.toUpperCase() == 'CONNECTING';
    final riskColor = dev.risk == 'HIGH'
        ? Colors.redAccent
        : dev.risk == 'MEDIUM'
            ? AppTheme.primaryYellow
            : AppTheme.primaryGreen;

    final loadPercent = dev.powerRating > 0 ? ((dev.liveKw / dev.powerRating) * 100).clamp(0, 100).toStringAsFixed(0) : '0';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: dev.risk == 'HIGH'
              ? Colors.redAccent.withOpacity(0.35)
              : isOnline
                  ? AppTheme.primaryGreen.withOpacity(0.2)
                  : Colors.white.withOpacity(0.06),
        ),
      ),
      child: InkWell(
        onTap: () => _showDeviceDetailsModal(dev),
        child: Column(
          children: [
            // Row 1: Icon, Name, ID, Status Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isOnline ? AppTheme.primaryGreen.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_getDeviceIcon(dev.type), color: isOnline ? AppTheme.primaryGreen : Colors.white38, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dev.name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 2),
                      Text(
                        'ID: ${dev.id} • ${dev.powerRating.toStringAsFixed(0)} kW Rated • ${dev.location}',
                        style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: isConnecting
                        ? AppTheme.primaryYellow.withOpacity(0.15)
                        : isOnline
                            ? AppTheme.primaryGreen.withOpacity(0.15)
                            : Colors.redAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isConnecting ? AppTheme.primaryYellow : isOnline ? AppTheme.primaryGreen : Colors.redAccent,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dev.status.toUpperCase(),
                        style: TextStyle(
                          color: isConnecting ? AppTheme.primaryYellow : isOnline ? AppTheme.primaryGreen : Colors.redAccent,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1, color: Colors.white10),
            const SizedBox(height: 8),
            // Row 2: Load, Energy, Carbon, Temp, Vib, Runtime, Risk
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCardMetric('Load', '$loadPercent%'),
                _buildCardMetric('Power', '${dev.liveKw.toStringAsFixed(1)} kW'),
                _buildCardMetric('Energy', '${dev.liveKwh.toStringAsFixed(1)} kWh'),
                _buildCardMetric('Carbon', '${dev.liveCarbon.toStringAsFixed(1)} kg'),
                _buildCardMetric('Temp/Vib', '${dev.temp.toStringAsFixed(0)}°C • ${dev.vib.toStringAsFixed(1)}'),
                _buildCardMetric('Runtime', '${dev.runtime.toStringAsFixed(1)}h'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: riskColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    dev.risk,
                    style: TextStyle(color: riskColor, fontSize: 8.5, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorsView() {
    return Consumer<SensorProvider>(
      builder: (context, provider, _) {
        final sensors = provider.sensors;
        List<IndustrialSensor> filtered;

        if (_sensorFilter == 'WARNING') {
          filtered = sensors.where((s) => s.status.toUpperCase() == 'WARNING' || s.status.toUpperCase() == 'CRITICAL').toList();
        } else if (_sensorFilter == 'NORMAL') {
          filtered = sensors.where((s) => s.status.toUpperCase() == 'NORMAL').toList();
        } else {
          filtered = sensors;
        }

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sensors_off, size: 56, color: Colors.white.withOpacity(0.3)),
                const SizedBox(height: 16),
                const Text('No sensors match filter', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white70)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
          itemCount: filtered.length,
          itemBuilder: (context, index) => _buildSensorCard(filtered[index]),
        );
      },
    );
  }

  Widget _buildSensorCard(IndustrialSensor s) {
    final isAbnormal = s.status.toUpperCase() == 'WARNING' || s.status.toUpperCase() == 'CRITICAL';
    final statusColor = isAbnormal ? Colors.orangeAccent : AppTheme.primaryGreen;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAbnormal ? Colors.orangeAccent.withOpacity(0.4) : Colors.white.withOpacity(0.06),
          width: isAbnormal ? 1.2 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isAbnormal ? Icons.warning_amber_rounded : Icons.sensors,
                      color: statusColor,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.parameter, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('${s.id} • ${s.location}', style: TextStyle(fontSize: 9.5, color: Colors.white.withOpacity(0.5))),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${s.value} ${s.unit}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isAbnormal ? Colors.orangeAccent : Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      s.status,
                      style: TextStyle(color: statusColor, fontSize: 8.5, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Threshold: ${s.threshold} • ${s.reason}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isAbnormal ? Colors.orangeAccent.withOpacity(0.9) : Colors.white.withOpacity(0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardMetric(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(val, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 1),
        Text(label, style: const TextStyle(fontSize: 8.5, color: Colors.white38)),
      ],
    );
  }

  IconData _getDeviceIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('furnace') || t.contains('boiler')) return Icons.local_fire_department;
    if (t.contains('hvac') || t.contains('chiller')) return Icons.ac_unit;
    if (t.contains('compressor')) return Icons.air;
    if (t.contains('motor') || t.contains('pump')) return Icons.settings_power;
    if (t.contains('weld')) return Icons.flash_on;
    if (t.contains('cnc') || t.contains('molding')) return Icons.precision_manufacturing;
    if (t.contains('pack')) return Icons.inventory_2;
    return Icons.precision_manufacturing;
  }

  void _showAddDeviceModal() {
    final nameCtrl = TextEditingController();
    final idCtrl = TextEditingController(text: 'CW-NODE-${DateTime.now().millisecondsSinceEpoch % 10000}');
    final locationCtrl = TextEditingController(text: 'Bay A • Sector 3');
    final powerCtrl = TextEditingController(text: '22');
    String selectedType = 'CNC Machine';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('ADD INDUSTRIAL MACHINE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                    IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 14),
                _buildModalTextField(nameCtrl, 'Machine Name', 'e.g. 5-Axis CNC Milling Unit'),
                const SizedBox(height: 10),
                _buildModalTextField(idCtrl, 'Machine ID / Asset Tag', 'e.g. CNC-013'),
                const SizedBox(height: 10),
                _buildModalTextField(locationCtrl, 'Shopfloor Location', 'e.g. Precision Machining Bay 2'),
                const SizedBox(height: 10),
                _buildModalTextField(powerCtrl, 'Rated Power (kW)', 'e.g. 22', isNumber: true),
                const SizedBox(height: 10),
                const Text('Machine Category', style: TextStyle(fontSize: 11, color: Colors.white60)),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  dropdownColor: AppTheme.cardDark,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'CNC Machine', child: Text('CNC Machine (15 kW)', style: TextStyle(fontSize: 12, color: Colors.white))),
                    DropdownMenuItem(value: 'Industrial Motor', child: Text('Industrial Motor (22 kW)', style: TextStyle(fontSize: 12, color: Colors.white))),
                    DropdownMenuItem(value: 'Air Compressor', child: Text('Air Compressor (30 kW)', style: TextStyle(fontSize: 12, color: Colors.white))),
                    DropdownMenuItem(value: 'Industrial HVAC', child: Text('Industrial HVAC (45 kW)', style: TextStyle(fontSize: 12, color: Colors.white))),
                    DropdownMenuItem(value: 'Injection Molding Machine', child: Text('Injection Molding (55 kW)', style: TextStyle(fontSize: 12, color: Colors.white))),
                    DropdownMenuItem(value: 'Conveyor Belt Motor', child: Text('Conveyor Belt Motor (11 kW)', style: TextStyle(fontSize: 12, color: Colors.white))),
                    DropdownMenuItem(value: 'Industrial Pump', child: Text('Industrial Pump (18.5 kW)', style: TextStyle(fontSize: 12, color: Colors.white))),
                    DropdownMenuItem(value: 'Welding Machine', child: Text('Welding Machine (12 kW)', style: TextStyle(fontSize: 12, color: Colors.white))),
                    DropdownMenuItem(value: 'Boiler', child: Text('Boiler (75 kW)', style: TextStyle(fontSize: 12, color: Colors.white))),
                    DropdownMenuItem(value: 'Industrial Furnace', child: Text('Industrial Furnace (110 kW)', style: TextStyle(fontSize: 12, color: Colors.white))),
                    DropdownMenuItem(value: 'Chiller', child: Text('Chiller (40 kW)', style: TextStyle(fontSize: 12, color: Colors.white))),
                    DropdownMenuItem(value: 'Packaging Machine', child: Text('Packaging Machine (8 kW)', style: TextStyle(fontSize: 12, color: Colors.white))),
                  ],
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedType = val);
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                    onPressed: () {
                      final name = nameCtrl.text.trim().isEmpty ? 'Industrial Machine' : nameCtrl.text.trim();
                      final id = idCtrl.text.trim();
                      final power = double.tryParse(powerCtrl.text.trim()) ?? 22.0;
                      final loc = locationCtrl.text.trim();

                      Navigator.pop(ctx);

                      // Instant Optimistic Add
                      context.read<DeviceProvider>().addDevice({
                        'id': id,
                        'name': name,
                        'type': selectedType,
                        'powerRating': power,
                        'location': loc,
                        'isActive': true,
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Connecting machine "$name" to telemetry bus...'),
                          backgroundColor: AppTheme.primaryGreen,
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text('PROVISION & CONNECT ASSET', style: TextStyle(color: AppTheme.backgroundDark, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalTextField(TextEditingController ctrl, String label, String hint, {bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white60)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(fontSize: 13, color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12, color: Colors.white30),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  void _showDeviceDetailsModal(Device dev) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dev.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(dev.status.toUpperCase(), style: const TextStyle(color: AppTheme.primaryGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('ID: ${dev.id} • Location: ${dev.location}', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5))),
            const SizedBox(height: 14),
            const Divider(height: 1, color: Colors.white10),
            const SizedBox(height: 10),
            _buildDetailRow('Active Power Draw', '${dev.liveKw.toStringAsFixed(1)} kW / ${dev.powerRating.toStringAsFixed(1)} kW rated'),
            _buildDetailRow('Energy Consumed Today', '${dev.liveKwh.toStringAsFixed(1)} kWh'),
            _buildDetailRow('Carbon Contribution', '${dev.liveCarbon.toStringAsFixed(2)} kg CO₂'),
            _buildDetailRow('Core Temperature', '${dev.temp.toStringAsFixed(1)} °C'),
            _buildDetailRow('Vibration Amplitude', '${dev.vib.toStringAsFixed(2)} mm/s'),
            _buildDetailRow('Continuous Runtime', '${dev.runtime.toStringAsFixed(1)} hrs'),
            _buildDetailRow('Risk Engine Status', dev.risk),
            _buildDetailRow('Telemetry Protocol', 'MQTT / Sparkplug B (Port 8883)'),
            _buildDetailRow('Last Heartbeat', 'Live (15s sync interval)'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('CLOSE ASSET TELEMETRY', style: TextStyle(color: AppTheme.backgroundDark, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11.5, color: Colors.white60)),
          Text(value, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }
}
