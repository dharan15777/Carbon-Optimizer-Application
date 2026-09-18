import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/device_provider.dart';

class SchedulerScreen extends StatefulWidget {
  const SchedulerScreen({super.key});

  @override
  State<SchedulerScreen> createState() => _SchedulerScreenState();
}

class _SchedulerScreenState extends State<SchedulerScreen> {
  final List<Map<String, dynamic>> _schedules = [
    {
      'title': 'EV Charging (AI Optimized)',
      'time': '11:00 AM – 2:00 PM',
      'device': 'EV Home Charger',
      'saving': '32% CO₂ Saved',
      'isAi': true,
      'enabled': true,
    },
    {
      'title': 'Dishwasher Eco Cycle',
      'time': '1:30 PM – 3:00 PM',
      'device': 'Smart Washing Machine',
      'saving': '24% CO₂ Saved',
      'isAi': false,
      'enabled': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Appliance Scheduler')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryGreen.withOpacity(0.15), AppTheme.primaryCyan.withOpacity(0.08)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.bolt, color: AppTheme.primaryGreen, size: 32),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Clean Energy Window Active',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Solar generation is peaking now. Shift heavy loads to maximize green energy.',
                          style: TextStyle(fontSize: 13, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Create New Schedule', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Card(
                    child: InkWell(
                      onTap: _showManualScheduleDialog,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: AppTheme.primaryCyan.withOpacity(0.15), shape: BoxShape.circle),
                              child: const Icon(Icons.edit_calendar, color: AppTheme.primaryCyan, size: 24),
                            ),
                            const SizedBox(height: 10),
                            const Text('Manual Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 4),
                            const Text('Custom hours', style: TextStyle(fontSize: 12, color: Colors.white54)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppTheme.primaryGreen, width: 1.2),
                    ),
                    child: InkWell(
                      onTap: _showAiScheduleDialog,
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.15), shape: BoxShape.circle),
                              child: const Icon(Icons.smart_toy, color: AppTheme.primaryGreen, size: 24),
                            ),
                            const SizedBox(height: 10),
                            const Text('AI Eco Optimizer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryGreen)),
                            const SizedBox(height: 4),
                            const Text('Auto lowest CO₂', style: TextStyle(fontSize: 12, color: Colors.white54)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Text('Active Automation Schedules', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...List.generate(_schedules.length, (index) {
              final s = _schedules[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (s['isAi'] ? AppTheme.primaryGreen : AppTheme.primaryCyan).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          s['isAi'] ? Icons.smart_toy : Icons.schedule,
                          color: s['isAi'] ? AppTheme.primaryGreen : AppTheme.primaryCyan,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s['title'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                            const SizedBox(height: 4),
                            Text('${s['device']} • ${s['time']}', style: const TextStyle(fontSize: 12, color: Colors.white54)),
                            const SizedBox(height: 2),
                            Text(s['saving'], style: const TextStyle(fontSize: 12, color: AppTheme.primaryGreen, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                      Switch(
                        value: s['enabled'],
                        activeColor: AppTheme.primaryGreen,
                        onChanged: (val) {
                          setState(() => s['enabled'] = val);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${s['title']} ${val ? 'enabled' : 'paused'}'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showManualScheduleDialog() {
    final devices = context.read<DeviceProvider>().devices;
    String selectedDevice = devices.isNotEmpty ? devices.first.name : 'Smart Appliance';
    TimeOfDay startTime = const TimeOfDay(hour: 14, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 16, minute: 0);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlg) => AlertDialog(
          title: const Text('New Manual Schedule'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedDevice,
                decoration: const InputDecoration(labelText: 'Select Appliance'),
                items: (devices.isNotEmpty ? devices.map((d) => d.name) : ['Living Room AC', 'EV Charger', 'Washing Machine'])
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setDlg(() => selectedDevice = v!),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Start Time', style: TextStyle(fontSize: 14)),
                trailing: TextButton(
                  onPressed: () async {
                    final t = await showTimePicker(context: context, initialTime: startTime);
                    if (t != null) setDlg(() => startTime = t);
                  },
                  child: Text(startTime.format(context), style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('End Time', style: TextStyle(fontSize: 14)),
                trailing: TextButton(
                  onPressed: () async {
                    final t = await showTimePicker(context: context, initialTime: endTime);
                    if (t != null) setDlg(() => endTime = t);
                  },
                  child: Text(endTime.format(context), style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _schedules.add({
                    'title': '$selectedDevice Schedule',
                    'time': '${startTime.format(context)} – ${endTime.format(context)}',
                    'device': selectedDevice,
                    'saving': '18% CO₂ Saved',
                    'isAi': false,
                    'enabled': true,
                  });
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Manual schedule created for $selectedDevice!')),
                );
              },
              child: const Text('Save Schedule'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAiScheduleDialog() {
    final devices = context.read<DeviceProvider>().devices;
    String selectedDevice = devices.isNotEmpty ? devices.first.name : 'EV Home Charger';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlg) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.smart_toy, color: AppTheme.primaryGreen),
              SizedBox(width: 8),
              Text('AI Smart Optimization'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI will analyze real-time grid forecasts and automatically trigger this appliance during maximum solar production.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedDevice,
                decoration: const InputDecoration(labelText: 'Target Appliance'),
                items: (devices.isNotEmpty ? devices.map((d) => d.name) : ['EV Home Charger', 'Water Heater', 'Smart Washing Machine'])
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setDlg(() => selectedDevice = v!),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle_outline, color: AppTheme.primaryGreen, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('Expected Window: 11:00 AM – 2:00 PM (~34% carbon reduction)', style: TextStyle(fontSize: 12, color: AppTheme.primaryGreen)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _schedules.insert(0, {
                    'title': '$selectedDevice (AI Auto-Pilot)',
                    'time': '11:00 AM – 2:00 PM (Solar Peak)',
                    'device': selectedDevice,
                    'saving': '34% Carbon Saved',
                    'isAi': true,
                    'enabled': true,
                  });
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('AI Eco Automation activated for $selectedDevice!')),
                );
              },
              child: const Text('Activate AI Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}
