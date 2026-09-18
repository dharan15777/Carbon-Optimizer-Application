import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/device_provider.dart';
import '../../models/device_model.dart';

class AppliancesScreen extends StatefulWidget {
  const AppliancesScreen({super.key});

  @override
  State<AppliancesScreen> createState() => _AppliancesScreenState();
}

class _AppliancesScreenState extends State<AppliancesScreen> {
  String _filter = 'ALL';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<DeviceProvider>().fetchDevices());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceDark,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('INDUSTRIAL ASSETS & IOT', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: Colors.white)),
            Text('Smart Edge Controllers & Sensors', style: TextStyle(fontSize: 10, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () => context.read<DeviceProvider>().fetchDevices(),
            tooltip: 'Refresh Assets',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDeviceModal,
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add, color: AppTheme.backgroundDark),
        label: const Text('+ ADD DEVICE', style: TextStyle(color: AppTheme.backgroundDark, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
      ),
      body: Consumer<DeviceProvider>(
        builder: (context, provider, _) {
          final devices = provider.devices;
          final filtered = _filter == 'ALL'
              ? devices
              : _filter == 'ONLINE'
                  ? devices.where((d) => d.status.toUpperCase() == 'ONLINE').toList()
                  : devices.where((d) => d.status.toUpperCase() == 'OFFLINE').toList();

          return Column(
            children: [
              _buildFilterChips(),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.precision_manufacturing_outlined, size: 56, color: Colors.white.withOpacity(0.3)),
                            const SizedBox(height: 16),
                            const Text('No devices match filter', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white70)),
                            const SizedBox(height: 8),
                            ElevatedButton(onPressed: _showAddDeviceModal, child: const Text('+ Add Industrial Sensor')),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final dev = filtered[index];
                          return _buildDeviceCard(dev);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['ALL', 'ONLINE', 'OFFLINE'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: filters.map((f) {
          final isSelected = _filter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(f, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? AppTheme.backgroundDark : Colors.white70)),
              selected: isSelected,
              selectedColor: AppTheme.primaryGreen,
              backgroundColor: AppTheme.surfaceDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.white.withOpacity(0.08))),
              onSelected: (val) => setState(() => _filter = f),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDeviceCard(Device dev) {
    final isOnline = dev.status.toUpperCase() == 'ONLINE';
    final isConnecting = dev.status.toUpperCase() == 'CONNECTING';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isOnline ? AppTheme.primaryGreen.withOpacity(0.25) : Colors.white.withOpacity(0.06)),
      ),
      child: InkWell(
        onTap: () => _showDeviceDetailsModal(dev),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isOnline ? AppTheme.primaryGreen.withOpacity(0.15) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getDeviceIcon(dev.type),
                    color: isOnline ? AppTheme.primaryGreen : Colors.white38,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dev.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 2),
                      Text(
                        'ID: ${dev.id} • ${dev.type} • ${dev.location}',
                        style: TextStyle(fontSize: 10.5, color: Colors.white.withOpacity(0.5)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isConnecting
                        ? AppTheme.primaryYellow.withOpacity(0.15)
                        : isOnline
                            ? AppTheme.primaryGreen.withOpacity(0.15)
                            : Colors.redAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
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
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Colors.white10),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCardMetric('Power Draw', '${dev.power} W'),
                _buildCardMetric('Hourly Impact', '${(dev.power * 0.00082).toStringAsFixed(2)} kg CO₂'),
                Row(
                  children: [
                    Switch(
                      value: dev.isOn,
                      activeColor: AppTheme.primaryGreen,
                      onChanged: (val) {
                        context.read<DeviceProvider>().toggleDevice(dev.id);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: Colors.white38),
                      onPressed: () => _confirmDelete(dev),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardMetric(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 1),
        Text(label, style: const TextStyle(fontSize: 9.5, color: Colors.white38)),
      ],
    );
  }

  IconData _getDeviceIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('smelt') || t.contains('furnace')) return Icons.local_fire_department;
    if (t.contains('hvac') || t.contains('chiller') || t.contains('cool')) return Icons.ac_unit;
    if (t.contains('solar')) return Icons.solar_power;
    if (t.contains('ev') || t.contains('charg')) return Icons.ev_station;
    if (t.contains('motor') || t.contains('pump')) return Icons.settings_power;
    if (t.contains('sensor')) return Icons.sensors;
    return Icons.precision_manufacturing;
  }

  void _showAddDeviceModal() {
    final nameCtrl = TextEditingController();
    final idCtrl = TextEditingController(text: 'CW-NODE-${DateTime.now().millisecondsSinceEpoch % 10000}');
    final locationCtrl = TextEditingController(text: 'Bay A • Sector 3');
    final powerCtrl = TextEditingController(text: '4500');
    String selectedType = 'Industrial Sensor';
    String selectedProtocol = 'MQTT / Sparkplug B';

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
                    const Text('ADD INDUSTRIAL ASSET / IOT NODE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                    IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildModalTextField(nameCtrl, 'Device Name', 'e.g. Compressor Unit #4'),
                const SizedBox(height: 12),
                _buildModalTextField(idCtrl, 'Asset ID / EUI', 'e.g. ESP32-MAC-4F2A'),
                const SizedBox(height: 12),
                _buildModalTextField(locationCtrl, 'Location / Facility Zone', 'e.g. Zone B Assembly'),
                const SizedBox(height: 12),
                _buildModalTextField(powerCtrl, 'Rated Power (Watts)', 'e.g. 5500', isNumber: true),
                const SizedBox(height: 12),
                const Text('Device Type', style: TextStyle(fontSize: 11, color: Colors.white60)),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  dropdownColor: AppTheme.cardDark,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Industrial Sensor', child: Text('Industrial Sensor / Transducer', style: TextStyle(fontSize: 12, color: Colors.white))),
                    DropdownMenuItem(value: 'ESP32 / ESP8266', child: Text('ESP32 Edge Microcontroller', style: TextStyle(fontSize: 12, color: Colors.white))),
                    DropdownMenuItem(value: 'Smart Meter', child: Text('3-Phase Smart Energy Meter', style: TextStyle(fontSize: 12, color: Colors.white))),
                    DropdownMenuItem(value: 'HVAC Chiller', child: Text('Central HVAC Chiller Unit', style: TextStyle(fontSize: 12, color: Colors.white))),
                    DropdownMenuItem(value: 'EV Fleet Charger', child: Text('DC Fast EV Fleet Charger', style: TextStyle(fontSize: 12, color: Colors.white))),
                    DropdownMenuItem(value: 'Motor & Drive', child: Text('VFD Motor & Pump Assembly', style: TextStyle(fontSize: 12, color: Colors.white))),
                  ],
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedType = val);
                  },
                ),
                const SizedBox(height: 12),
                const Text('Telemetry Protocol', style: TextStyle(fontSize: 11, color: Colors.white60)),
                const SizedBox(height: 4),
                DropdownButtonFormField<String>(
                  value: selectedProtocol,
                  dropdownColor: AppTheme.cardDark,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'MQTT / Sparkplug B', child: Text('MQTT (TLS 8883) Sparkplug B', style: TextStyle(fontSize: 12, color: Colors.white))),
                    DropdownMenuItem(value: 'Modbus TCP', child: Text('Modbus TCP / RTU over IP', style: TextStyle(fontSize: 12, color: Colors.white))),
                    DropdownMenuItem(value: 'OPC-UA', child: Text('OPC-UA Industrial Gateway', style: TextStyle(fontSize: 12, color: Colors.white))),
                    DropdownMenuItem(value: 'HTTP REST Webhook', child: Text('HTTP / HTTPS REST Edge', style: TextStyle(fontSize: 12, color: Colors.white))),
                  ],
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedProtocol = val);
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                    onPressed: () {
                      final name = nameCtrl.text.trim().isEmpty ? 'Industrial Node' : nameCtrl.text.trim();
                      final id = idCtrl.text.trim();
                      final power = double.tryParse(powerCtrl.text.trim()) ?? 3000.0;
                      final loc = locationCtrl.text.trim();

                      Navigator.pop(ctx);

                      // Optimistic Add
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
                          content: Text('Asset "$name" registered & streaming telemetry!'),
                          backgroundColor: AppTheme.primaryGreen,
                          behavior: SnackBarBehavior.floating,
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
            const SizedBox(height: 6),
            Text('ID: ${dev.id} • Location: ${dev.location}', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5))),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Colors.white10),
            const SizedBox(height: 12),
            _buildDetailRow('Active Power Rating', '${dev.power} Watts'),
            _buildDetailRow('Estimated Hourly Carbon Impact', '${(dev.power * 0.00082).toStringAsFixed(2)} kg CO₂'),
            _buildDetailRow('Telemetry Protocol', 'MQTT / Sparkplug B (Port 8883)'),
            _buildDetailRow('Last Heartbeat', '1.2s ago (Packet #12894)'),
            _buildDetailRow('Energy Optimization State', 'Grid Load-Aware Active'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryCyan),
                icon: const Icon(Icons.schedule, color: AppTheme.backgroundDark, size: 18),
                label: const Text('CONFIGURE SHIFT SCHEDULE', style: TextStyle(color: AppTheme.backgroundDark, fontWeight: FontWeight.w800)),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white60)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  void _confirmDelete(Device dev) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('Decommission Asset', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to remove ${dev.name} (${dev.id}) from active monitoring?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<DeviceProvider>().deleteDevice(dev.id);
            },
            child: const Text('Decommission', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
