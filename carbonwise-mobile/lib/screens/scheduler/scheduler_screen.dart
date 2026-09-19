import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/carbon_provider.dart';
import '../../providers/device_provider.dart';

class SchedulerScreen extends StatefulWidget {
  const SchedulerScreen({super.key});

  @override
  State<SchedulerScreen> createState() => _SchedulerScreenState();
}

class _SchedulerScreenState extends State<SchedulerScreen> {
  final List<Map<String, dynamic>> _schedules = [
    {
      'id': 'SCH-01',
      'machine': 'Rotary Screw Air Compressor',
      'power': 30.0,
      'duration': '2 hours',
      'recommendedWindow': '02:00–04:00',
      'reason': 'Lower grid carbon intensity (286 g vs 642 g peak)',
      'co2Avoided': '21.4 kg CO₂',
      'costSaved': '₹380',
      'enabled': true,
    },
    {
      'id': 'SCH-02',
      'machine': 'Centrifugal Effluent Pump',
      'power': 18.5,
      'duration': '3 hours',
      'recommendedWindow': '11:30–14:30',
      'reason': 'Direct solar generation peak window (52% renewable mix)',
      'co2Avoided': '18.2 kg CO₂',
      'costSaved': '₹290',
      'enabled': true,
    },
    {
      'id': 'SCH-03',
      'machine': 'Electric Annealing Furnace',
      'power': 110.0,
      'duration': '1.5 hours',
      'recommendedWindow': '12:00–13:30',
      'reason': 'Maximum renewable grid penetration avoids thermal surcharge',
      'co2Avoided': '58.6 kg CO₂',
      'costSaved': '₹1,120',
      'enabled': true,
    },
    {
      'id': 'SCH-04',
      'machine': 'Industrial HVAC Cleanroom Pre-Cool',
      'power': 45.0,
      'duration': '2 hours',
      'recommendedWindow': '03:00–05:00',
      'reason': 'Thermal pre-cooling during base grid tariff window',
      'co2Avoided': '26.8 kg CO₂',
      'costSaved': '₹540',
      'enabled': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CarbonProvider>().fetchLiveIntensity();
      context.read<DeviceProvider>().fetchDevices();
    });
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
            Text('SMART SCHEDULING & GRID INTELLIGENCE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 1.0, color: Colors.white)),
            Text('Grid-Aware Machine Load Shifting', style: TextStyle(fontSize: 10, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGridIntelligenceBanner(),
            const SizedBox(height: 20),
            _buildScheduleOptimizerHeader(),
            const SizedBox(height: 12),
            ..._schedules.map((s) => _buildScheduleCard(s)),
            const SizedBox(height: 20),
            _buildCustomScheduleCTA(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildGridIntelligenceBanner() {
    return Consumer<CarbonProvider>(
      builder: (context, carbonProv, _) {
        final liveVal = carbonProv.liveIntensity?.intensity ?? 412.0;
        final status = liveVal < 350 ? 'CLEAN' : liveVal < 600 ? 'NORMAL' : 'HIGH CARBON';
        final statusColor = liveVal < 350 ? AppTheme.primaryGreen : liveVal < 600 ? AppTheme.primaryYellow : Colors.redAccent;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [statusColor.withOpacity(0.18), AppTheme.surfaceDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: statusColor.withOpacity(0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.bolt, color: statusColor, size: 22),
                      const SizedBox(width: 8),
                      const Text('CURRENT GRID STATUS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: statusColor.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: Text('$status • ${liveVal.toStringAsFixed(0)} gCO₂/kWh', style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildGridStatCol('GRID INTENSITY', '${liveVal.toStringAsFixed(0)} g', 'CO₂/kWh', statusColor),
                  _buildGridStatCol('RENEWABLE %', '52.0%', 'Solar + Wind + Hydro', AppTheme.primaryGreen),
                  _buildGridStatCol('THERMAL %', '48.0%', 'Coal & Gas', Colors.white70),
                  _buildGridStatCol('GRID DEMAND', '4,420 MW', 'Regional Load', AppTheme.primaryCyan),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.schedule, size: 16, color: AppTheme.primaryGreen),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'NEXT CLEAN ENERGY WINDOW: 02:00–04:00 (Grid drops to 286 gCO₂/kWh)',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridStatCol(String label, String val, String sub, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.4))),
          const SizedBox(height: 2),
          Text(val, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
          Text(sub, style: TextStyle(fontSize: 8.5, color: Colors.white.withOpacity(0.35)), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildScheduleOptimizerHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('OPTIMIZED MACHINE OPERATING PERIODS', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('Ranked by CO₂ avoided and energy tariff savings', style: TextStyle(fontSize: 10, color: Colors.white54)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
          child: const Text('AI SCHEDULE ENGINE', style: TextStyle(color: AppTheme.primaryGreen, fontSize: 9, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> s) {
    final enabled = s['enabled'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: enabled ? AppTheme.primaryGreen.withOpacity(0.3) : Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(s['machine'] as String, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              Switch(
                value: enabled,
                activeColor: AppTheme.primaryGreen,
                onChanged: (val) {
                  setState(() => s['enabled'] = val);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${s['machine']} shift schedule ${val ? "activated" : "paused"}'),
                      backgroundColor: AppTheme.primaryGreen,
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                child: Text('${s['power']} kW • ${s['duration']}', style: const TextStyle(color: AppTheme.primaryGreen, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Text('Recommended: ${s['recommendedWindow']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 8),
          Text(s['reason'] as String, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.65))),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Colors.white10),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.eco, size: 14, color: AppTheme.primaryGreen),
                  const SizedBox(width: 4),
                  Text('Avoided: ${s['co2Avoided']}', style: const TextStyle(color: AppTheme.primaryGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.currency_rupee, size: 14, color: AppTheme.primaryCyan),
                  const SizedBox(width: 2),
                  Text('Saved: ${s['costSaved']}', style: const TextStyle(color: AppTheme.primaryCyan, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomScheduleCTA() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: const Icon(Icons.add, color: AppTheme.backgroundDark),
        label: const Text('+ SCHEDULE ANOTHER MACHINE LOAD', style: TextStyle(color: AppTheme.backgroundDark, fontWeight: FontWeight.w800, letterSpacing: 0.8)),
        onPressed: _showAddScheduleDialog,
      ),
    );
  }

  void _showAddScheduleDialog() {
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
            const Text('SCHEDULE INDUSTRIAL LOAD SHIFT', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 6),
            Text('Calculates the lowest grid carbon intensity slot for your machine power and cycle duration.', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6))),
            const SizedBox(height: 16),
            const Text('Selected Unit: Welding Machine (12 kW)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70)),
            const SizedBox(height: 8),
            const Text('Recommended Window: 13:00–15:00 (Solar Peak)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
            const SizedBox(height: 4),
            const Text('Estimated Savings: 14.8 kg CO₂ • ₹210 tariff reduction', style: TextStyle(fontSize: 11, color: Colors.white60)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _schedules.insert(0, {
                      'id': 'SCH-05',
                      'machine': 'Robotic MIG Welder',
                      'power': 12.0,
                      'duration': '2 hours',
                      'recommendedWindow': '13:00–15:00',
                      'reason': 'Solar generation peak aligns with welder duty cycle',
                      'co2Avoided': '14.8 kg CO₂',
                      'costSaved': '₹210',
                      'enabled': true,
                    });
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Automated shift schedule created!'), backgroundColor: AppTheme.primaryGreen),
                  );
                },
                child: const Text('ACTIVATE SMART SCHEDULE', style: TextStyle(color: AppTheme.backgroundDark, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
