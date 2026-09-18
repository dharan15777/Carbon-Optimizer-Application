import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/device_provider.dart';
import '../../models/device_model.dart';

class AppliancesScreen extends StatefulWidget {
  const AppliancesScreen({super.key});

  @override
  State<AppliancesScreen> createState() => _AppliancesScreenState();
}

class _AppliancesScreenState extends State<AppliancesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<DeviceProvider>().fetchDevices());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Appliances'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DeviceProvider>().fetchDevices(),
            tooltip: 'Refresh devices',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDeviceDialog(),
        backgroundColor: AppTheme.primaryGreen,
        icon: const Icon(Icons.add, color: AppTheme.backgroundDark),
        label: const Text('Add Device', style: TextStyle(color: AppTheme.backgroundDark, fontWeight: FontWeight.bold)),
      ),
      body: Consumer<DeviceProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.devices.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.devices.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.devices_other, size: 64, color: Colors.white.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text('No devices added yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Tap below to add your first smart appliance', style: TextStyle(color: Colors.white54)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showAddDeviceDialog,
                    child: const Text('Add Appliance'),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => context.read<DeviceProvider>().fetchDevices(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: provider.devices.length,
              itemBuilder: (context, index) => _buildDeviceCard(provider.devices[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDeviceCard(Device device) {
    final iconData = _getDeviceIconData(device.type);
    final color = device.isActive ? AppTheme.primaryGreen : Colors.white54;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(iconData, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(device.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    '${device.powerRating} kW • ${_getDeviceTypeName(device.type)}',
                    style: const TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                ],
              ),
            ),
            Switch(
              value: device.isActive,
              activeColor: AppTheme.primaryGreen,
              onChanged: (val) async {
                final success = await context.read<DeviceProvider>().updateDevice(
                  device.id,
                  {'name': device.name, 'type': device.type, 'powerRating': device.powerRating, 'isActive': val},
                );
                if (mounted && success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${device.name} turned ${val ? 'ON' : 'OFF'}'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 20),
              onPressed: () async {
                await context.read<DeviceProvider>().deleteDevice(device.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${device.name} removed')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDeviceIconData(String type) => switch (type) {
        AppConstants.deviceSmartPlug => Icons.power,
        AppConstants.deviceEVCharger => Icons.ev_station,
        AppConstants.deviceAirConditioner => Icons.ac_unit,
        AppConstants.deviceWashingMachine => Icons.local_laundry_service,
        AppConstants.deviceWaterHeater => Icons.water_drop,
        _ => Icons.device_unknown,
      };

  String _getDeviceTypeName(String type) => switch (type) {
        AppConstants.deviceSmartPlug => 'Smart Plug',
        AppConstants.deviceEVCharger => 'EV Charger',
        AppConstants.deviceAirConditioner => 'Air Conditioner',
        AppConstants.deviceWashingMachine => 'Washing Machine',
        AppConstants.deviceWaterHeater => 'Water Heater',
        _ => 'Unknown',
      };

  void _showAddDeviceDialog() {
    final nameController = TextEditingController();
    String selectedType = AppConstants.deviceSmartPlug;
    double powerRating = 1.0;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Smart Device'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Device Name',
                  hintText: 'e.g. Living Room AC',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(labelText: 'Device Type'),
                items: const [
                  DropdownMenuItem(value: AppConstants.deviceSmartPlug, child: Text('Smart Plug')),
                  DropdownMenuItem(value: AppConstants.deviceEVCharger, child: Text('EV Charger')),
                  DropdownMenuItem(value: AppConstants.deviceAirConditioner, child: Text('Air Conditioner')),
                  DropdownMenuItem(value: AppConstants.deviceWashingMachine, child: Text('Washing Machine')),
                  DropdownMenuItem(value: AppConstants.deviceWaterHeater, child: Text('Water Heater')),
                ],
                onChanged: (v) => setDialogState(() => selectedType = v!),
              ),
              const SizedBox(height: 16),
              TextField(
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Power Rating (kW)',
                  hintText: '1.5',
                ),
                onChanged: (v) => powerRating = double.tryParse(v) ?? 1.0,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(ctx);
                await context.read<DeviceProvider>().addDevice({
                  'name': name,
                  'type': selectedType,
                  'powerRating': powerRating,
                  'isActive': true,
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added $name successfully!')),
                  );
                }
              },
              child: const Text('Add Device'),
            ),
          ],
        ),
      ),
    );
  }
}
