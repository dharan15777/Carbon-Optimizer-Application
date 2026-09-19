import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/carbon_provider.dart';
import '../../providers/device_provider.dart';
import '../../providers/sensor_provider.dart';
import '../../widgets/carbon_gauge.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedOrg = 'Alpha MegaFactory (HQ)';
  double _sustainabilityBudget = 1000000; // ₹10,00,000 baseline budget

  final List<Map<String, dynamic>> _allActions = [
    {
      'name': 'Rooftop Solar 500kW',
      'cost': 4500000.0,
      'reduction': 52.0,
      'category': 'Renewable',
      'payback': '3.2 yrs',
      'priority': 'HIGH',
      'reason': 'Solar generation peak offsets dirty grid during highest tariff window',
    },
    {
      'name': 'Factory-wide LED Retrofit',
      'cost': 350000.0,
      'reduction': 12.5,
      'category': 'Lighting',
      'payback': '0.8 yrs',
      'priority': 'HIGH',
      'reason': 'Fastest payback; cuts baseline continuous factory lighting load by 60%',
    },
    {
      'name': 'IE4 Super Premium Motor Upgrade',
      'cost': 600000.0,
      'reduction': 18.0,
      'category': 'Motors',
      'payback': '1.9 yrs',
      'priority': 'HIGH',
      'reason': 'Upgrades 22kW industrial motor and pump efficiency to reduce losses',
    },
    {
      'name': 'Variable Frequency Drives (VFD) on HVAC',
      'cost': 450000.0,
      'reduction': 14.2,
      'category': 'HVAC',
      'payback': '1.4 yrs',
      'priority': 'MEDIUM',
      'reason': 'Modulates cooling air volume automatically based on thermal load',
    },
    {
      'name': 'Electric Forklift & EV Shuttle Transition',
      'cost': 1200000.0,
      'reduction': 16.5,
      'category': 'Logistics',
      'payback': '2.6 yrs',
      'priority': 'MEDIUM',
      'reason': 'Eliminates factory yard diesel exhaust and diesel generator dependencies',
    },
    {
      'name': 'Combustion Air Pre-Heater on Furnace',
      'cost': 850000.0,
      'reduction': 22.0,
      'category': 'Thermal',
      'payback': '2.1 yrs',
      'priority': 'HIGH',
      'reason': 'Recovers waste stack heat to preheat combustion intake air',
    },
    {
      'name': 'Pneumatic Header Leak Sealing & VSD',
      'cost': 200000.0,
      'reduction': 8.0,
      'category': 'Compressors',
      'payback': '0.6 yrs',
      'priority': 'HIGH',
      'reason': 'Stops idle air leakage on 30kW central compressor ring',
    },
    {
      'name': 'Smart Shift Scheduling Automation',
      'cost': 150000.0,
      'reduction': 9.5,
      'category': 'Software/IoT',
      'payback': '0.4 yrs',
      'priority': 'HIGH',
      'reason': 'Automates non-critical batch heating to clean energy grid windows',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CarbonProvider>().fetchLiveIntensity();
      context.read<DeviceProvider>().fetchDevices();
      context.read<SensorProvider>().fetchIndustrialSensors();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        color: AppTheme.primaryGreen,
        onRefresh: () async {
          final carbonProv = context.read<CarbonProvider>();
          final deviceProv = context.read<DeviceProvider>();
          final sensorProv = context.read<SensorProvider>();
          await carbonProv.fetchLiveIntensity();
          await deviceProv.fetchDevices();
          await sensorProv.fetchIndustrialSensors();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLiveSystemHeader(),
              const SizedBox(height: 16),
              _buildKPICardsGrid(),
              const SizedBox(height: 20),
              _buildCarbonIntelligenceStory(),
              const SizedBox(height: 24),
              _buildLiveGaugeSection(),
              const SizedBox(height: 24),
              _buildCarbonSourcesSection(),
              const SizedBox(height: 24),
              _buildCarbonHotspotsSection(),
              const SizedBox(height: 24),
              _buildQuickActionsSection(),
              const SizedBox(height: 24),
              _buildAIOptimizationEngine(),
              const SizedBox(height: 24),
              _buildRoadmapSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.surfaceDark,
      elevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.eco, color: AppTheme.primaryGreen, size: 20),
          ),
          const SizedBox(width: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CARBONWISE INDUSTRIAL',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: Colors.white),
              ),
              Text(
                'Industrial Carbon Intelligence & Reduction',
                style: TextStyle(fontSize: 10, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white70),
          onPressed: _showGlobalSearchDialog,
          tooltip: 'Global Search',
        ),
        IconButton(
          icon: Stack(
            children: [
              const Icon(Icons.notifications_outlined, color: Colors.white70),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          onPressed: () => context.go('/notifications'),
          tooltip: 'Notifications',
        ),
        IconButton(
          icon: const CircleAvatar(
            radius: 14,
            backgroundColor: AppTheme.primaryGreen,
            child: Text('CW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.backgroundDark)),
          ),
          onPressed: () => context.go('/profile'),
          tooltip: 'Profile',
        ),
      ],
    );
  }

  Widget _buildLiveSystemHeader() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppTheme.primaryGreen, blurRadius: 8, spreadRadius: 1.5),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '● LIVE DEMO TELEMETRY',
                    style: TextStyle(color: AppTheme.primaryGreen, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('12 MACHINES • 12 SENSORS', style: TextStyle(color: Colors.white70, fontSize: 9.5, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedOrg,
              isExpanded: true,
              dropdownColor: AppTheme.cardDark,
              icon: const Icon(Icons.arrow_drop_down, color: AppTheme.primaryGreen),
              items: const [
                DropdownMenuItem(value: 'Alpha MegaFactory (HQ)', child: Text('🏢 Alpha MegaFactory (HQ) • Chennai Plant', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white))),
                DropdownMenuItem(value: 'Beta Chemical Plant', child: Text('🏭 Beta Chemical Plant • Gujarat Complex', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white))),
                DropdownMenuItem(value: 'Delta Metallurgy Complex', child: Text('⚡ Delta Metallurgy Complex • Jamshedpur', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white))),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedOrg = val);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPICardsGrid() {
    return Consumer<CarbonProvider>(
      builder: (context, carbonProv, _) {
        final liveIntensity = carbonProv.liveIntensity?.intensity ?? 412.0;
        final renewablePct = carbonProv.liveIntensity?.solarWindPercent != null
            ? (carbonProv.liveIntensity!.solarWindPercent + carbonProv.liveIntensity!.hydroPercent).clamp(10.0, 95.0)
            : 52.0;

        return Column(
          children: [
            // Row 1: Total Carbon & Today's Emissions
            Row(
              children: [
                Expanded(
                  child: _buildKPICard(
                    title: 'TOTAL CARBON',
                    value: '1,284 t',
                    sub: '12,84,000 kg CO₂',
                    trend: '↓ 8.4% vs baseline',
                    trendColor: AppTheme.primaryGreen,
                    icon: Icons.cloud_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildKPICard(
                    title: "TODAY'S EMISSIONS",
                    value: '4,180 kg',
                    sub: 'kg CO₂ emitted',
                    trend: '320 kg clean saved',
                    trendColor: AppTheme.primaryCyan,
                    icon: Icons.today,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Row 2: Carbon Intensity & Grid Intensity
            Row(
              children: [
                Expanded(
                  child: _buildKPICard(
                    title: 'CARBON INTENSITY',
                    value: '0.42 kg',
                    sub: 'CO₂ / production unit',
                    trend: 'Target: 0.38 kg',
                    trendColor: AppTheme.primaryYellow,
                    icon: Icons.speed,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildKPICard(
                    title: 'GRID INTENSITY',
                    value: '${liveIntensity.toStringAsFixed(0)} g',
                    sub: 'g CO₂ / kWh',
                    trend: liveIntensity < 350 ? 'CLEAN WINDOW' : liveIntensity < 600 ? 'NORMAL GRID' : 'HIGH CARBON',
                    trendColor: liveIntensity < 350 ? AppTheme.primaryGreen : liveIntensity < 600 ? AppTheme.primaryYellow : Colors.redAccent,
                    icon: Icons.bolt,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Row 3: Renewable % & Active Machines & Risk Level
            Row(
              children: [
                Expanded(
                  child: _buildKPICard(
                    title: 'RENEWABLE %',
                    value: '${renewablePct.toStringAsFixed(1)}%',
                    sub: 'Solar, Wind & Hydro',
                    trend: 'Grid Clean Window',
                    trendColor: AppTheme.primaryGreen,
                    icon: Icons.solar_power,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildKPICard(
                    title: 'ACTIVE MACHINES',
                    value: '12 / 12',
                    sub: '100% online telemetry',
                    trend: 'All nodes syncd',
                    trendColor: AppTheme.primaryCyan,
                    icon: Icons.precision_manufacturing,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildKPICard(
                    title: 'RISK LEVEL',
                    value: 'MEDIUM',
                    sub: 'Furnace & Boiler',
                    trend: '3 warnings',
                    trendColor: AppTheme.primaryYellow,
                    icon: Icons.warning_amber,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildKPICard({
    required String title,
    required String value,
    required String sub,
    required String trend,
    required Color trendColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(title, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9.0, fontWeight: FontWeight.w800, letterSpacing: 0.5), overflow: TextOverflow.ellipsis),
              ),
              Icon(icon, size: 14, color: Colors.white38),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 2),
          Text(sub, style: TextStyle(fontSize: 9.5, color: Colors.white.withOpacity(0.4))),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: trendColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(trend, style: TextStyle(color: trendColor, fontSize: 9.0, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCarbonIntelligenceStory() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryCyan.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.analytics_outlined, color: AppTheme.primaryCyan, size: 18),
                  SizedBox(width: 8),
                  Text('CARBON INTELLIGENCE HIGHLIGHTS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.8)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: AppTheme.primaryCyan.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                child: const Text('FORMULA: CO₂ = Energy × EF', style: TextStyle(color: AppTheme.primaryCyan, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStoryHighlightRow('TOP EMISSION SOURCE', 'Purchased Electricity (667 t CO₂ • 52%)', 'Highest continuous load factor', AppTheme.primaryGreen),
          _buildStoryHighlightRow('TOP CARBON-HOTSPOT MACHINE', 'Industrial Furnace (110 kW • 224.3 kg CO₂/shift)', 'High continuous heat demand', Colors.redAccent),
          _buildStoryHighlightRow('HIGHEST-RISK AREA', 'Thermal Utility & Boiler Manifold', 'Elevated temperature + fuel vibration', AppTheme.primaryYellow),
          _buildStoryHighlightRow('BIGGEST REDUCTION OPPORTUNITY', 'Rooftop Solar 500kW & Pump VFDs', 'Estimated ↓ 64.0 t CO₂/yr (ROI: 2.1y)', AppTheme.primaryCyan),
        ],
      ),
    );
  }

  Widget _buildStoryHighlightRow(String label, String value, String reason, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.w800)),
                Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(reason, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveGaugeSection() {
    return Consumer<CarbonProvider>(
      builder: (context, provider, _) {
        final val = provider.liveIntensity?.intensity ?? 412.0;
        final status = val < 350 ? 'CLEAN' : val < 600 ? 'NORMAL' : 'HIGH CARBON';
        final statusColor = val < 350 ? AppTheme.primaryGreen : val < 600 ? AppTheme.primaryYellow : Colors.redAccent;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('REAL-TIME GRID INTENSITY', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                      SizedBox(height: 2),
                      Text('National & Regional Generation Mix', style: TextStyle(fontSize: 10, color: Colors.white38)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('$status • ${val.toStringAsFixed(0)} gCO₂/kWh', style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              CarbonGauge(intensity: val),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSubMixIndicator('Solar & Wind', '52%', AppTheme.primaryGreen),
                  _buildSubMixIndicator('Hydroelectric', '18%', AppTheme.primaryCyan),
                  _buildSubMixIndicator('Natural Gas', '16%', AppTheme.primaryYellow),
                  _buildSubMixIndicator('Coal/Thermal', '14%', Colors.redAccent),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt, size: 16, color: AppTheme.primaryGreen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        val < 350
                            ? 'Currently in Clean Window! Run high-load motors now.'
                            : 'Next Clean Window: 02:00–04:00 (Grid intensity drops to 286 gCO₂/kWh)',
                        style: const TextStyle(fontSize: 11, color: Colors.white70),
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

  Widget _buildSubMixIndicator(String label, String percent, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text(percent, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9.5)),
      ],
    );
  }

  Widget _buildCarbonSourcesSection() {
    final sources = [
      {'name': 'Electricity', 'percent': 52, 'emissions': '667 t CO₂', 'trend': '↓ 4.2%', 'color': AppTheme.primaryGreen},
      {'name': 'Fuel', 'percent': 21, 'emissions': '269 t CO₂', 'trend': '↓ 1.8%', 'color': AppTheme.primaryCyan},
      {'name': 'Production', 'percent': 15, 'emissions': '192 t CO₂', 'trend': '↑ 1.1%', 'color': AppTheme.primaryYellow},
      {'name': 'Logistics', 'percent': 8, 'emissions': '103 t CO₂', 'trend': '↓ 2.5%', 'color': Colors.purpleAccent},
      {'name': 'Waste', 'percent': 4, 'emissions': '53 t CO₂', 'trend': '↓ 0.9%', 'color': Colors.redAccent},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('EMISSION SOURCE BREAKDOWN', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
              TextButton(
                onPressed: _showEmissionFactorsModal,
                style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                child: const Text('Emission Factors ›', style: TextStyle(color: AppTheme.primaryGreen, fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: sources.map((s) {
                  return Expanded(
                    flex: s['percent'] as int,
                    child: Container(color: s['color'] as Color),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...sources.map((s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: s['color'] as Color, shape: BoxShape.circle)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(s['name'] as String, style: const TextStyle(fontSize: 12, color: Colors.white70))),
                    Text('${s['percent']}%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: s['color'] as Color)),
                    const SizedBox(width: 12),
                    Text(s['emissions'] as String, style: const TextStyle(fontSize: 11, color: Colors.white)),
                    const SizedBox(width: 10),
                    Text(s['trend'] as String, style: TextStyle(fontSize: 10.5, color: (s['trend'] as String).startsWith('↓') ? AppTheme.primaryGreen : Colors.redAccent, fontWeight: FontWeight.bold)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildCarbonHotspotsSection() {
    final hotspots = [
      {
        'name': 'Industrial Furnace (110 kW)',
        'emission': '224.3 kg CO₂/shift',
        'rank': '#1',
        'severity': 'HIGH RISK',
        'color': Colors.redAccent,
        'action': 'Contributes highest estimated carbon due to 110 kW power demand and 6.7h continuous runtime.',
      },
      {
        'name': 'Industrial Steam Boiler (75 kW)',
        'emission': '159.6 kg CO₂/shift',
        'rank': '#2',
        'severity': 'HIGH RISK',
        'color': Colors.redAccent,
        'action': 'High thermal requirement; boiler manifold temperature reaches 115°C.',
      },
      {
        'name': 'Injection Molding Machine (55 kW)',
        'emission': '118.7 kg CO₂/shift',
        'rank': '#3',
        'severity': 'HIGH RISK',
        'color': Colors.redAccent,
        'action': 'Heavy hydraulic cycle; vibration spikes to 4.8 mm/s on high pressure clamp.',
      },
      {
        'name': 'Industrial HVAC Cleanroom (45 kW)',
        'emission': '101.8 kg CO₂/shift',
        'rank': '#4',
        'severity': 'MEDIUM',
        'color': AppTheme.primaryYellow,
        'action': 'Continuous 24/7 circulation; candidate for night setpoint relaxation.',
      },
      {
        'name': 'Rotary Air Compressor (30 kW)',
        'emission': '70.0 kg CO₂/shift',
        'rank': '#5',
        'severity': 'MEDIUM',
        'color': AppTheme.primaryYellow,
        'action': 'Idle pressure cycle losses; can be scheduled to 02:00 clean energy window.',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOP 5 CARBON SOURCES & HOTSPOTS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                child: const Text('RANKED BY CO₂', style: TextStyle(color: Colors.redAccent, fontSize: 9.5, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...hotspots.map((h) => _buildHotspotCard(h)),
        ],
      ),
    );
  }

  Widget _buildHotspotCard(Map<String, dynamic> h) {
    final color = h['color'] as Color;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
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
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(4)),
                    child: Text(h['rank'] as String, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                  Text(h['name'] as String, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                child: Text(h['severity'] as String, style: TextStyle(color: color, fontSize: 8.5, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(h['action'] as String, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
          const SizedBox(height: 4),
          Text('Contribution: ${h['emission']}', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    final actions = [
      {
        'title': 'View Carbon Hotspots',
        'desc': 'Inspect high-emission machines, thermal contours, and facility hotspot ranking.',
        'btn': 'View Hotspots',
        'route': '/maps',
        'icon': Icons.local_fire_department,
        'color': Colors.deepOrangeAccent,
      },
      {
        'title': 'Optimize Budget',
        'desc': 'Run 0/1 Knapsack optimization to allocate capital for maximum CO₂ reduction.',
        'btn': 'Optimize Budget',
        'route': '/prediction',
        'icon': Icons.auto_awesome,
        'color': AppTheme.primaryGreen,
      },
      {
        'title': 'Find Clean Energy Window',
        'desc': 'Identify upcoming hours where renewable grid energy peaks to schedule shift loads.',
        'btn': 'Find Clean Window',
        'route': '/scheduler',
        'icon': Icons.solar_power,
        'color': AppTheme.primaryCyan,
      },
      {
        'title': 'View High Risk Machines',
        'desc': 'Review units exceeding temperature, vibration, or carbon safety thresholds.',
        'btn': 'View High Risk',
        'route': '/appliances',
        'icon': Icons.warning_amber,
        'color': Colors.redAccent,
      },
      {
        'title': 'Generate Report',
        'desc': 'Create auditor-compliant PDF report with GHG Scope 1–3 emissions breakdown.',
        'btn': 'Generate Report',
        'route': '/reports',
        'icon': Icons.picture_as_pdf,
        'color': AppTheme.primaryYellow,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('INTELLIGENT QUICK ACTIONS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 12),
        ...actions.map((a) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: (a['color'] as Color).withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (a['color'] as Color).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(a['icon'] as IconData, color: a['color'] as Color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a['title'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 3),
                        Text(a['desc'] as String, style: TextStyle(fontSize: 10.5, color: Colors.white.withOpacity(0.6), height: 1.3)),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => context.go(a['route'] as String),
                          child: Text(
                            '${a['btn']} ›',
                            style: TextStyle(color: a['color'] as Color, fontSize: 11.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildAIOptimizationEngine() {
    double allocated = 0;
    double totalReduction = 0;
    List<Map<String, dynamic>> selectedActions = [];

    // Deterministic 0/1 Knapsack optimization sorted by reduction per rupee
    List<Map<String, dynamic>> sorted = List.from(_allActions);
    sorted.sort((a, b) {
      double ratioA = (a['reduction'] as double) / (a['cost'] as double);
      double ratioB = (b['reduction'] as double) / (b['cost'] as double);
      return ratioB.compareTo(ratioA);
    });

    for (var act in sorted) {
      double cost = act['cost'] as double;
      if (allocated + cost <= _sustainabilityBudget) {
        allocated += cost;
        totalReduction += act['reduction'] as double;
        selectedActions.add(act);
      }
    }
    double remaining = _sustainabilityBudget - allocated;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: AppTheme.primaryGreen, size: 18),
                  SizedBox(width: 8),
                  Text('AI BUDGET OPTIMIZATION', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.8)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('0/1 KNAPSACK', style: TextStyle(color: AppTheme.primaryGreen, fontSize: 9.5, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Selects the optimal combination of reduction actions within your sustainability budget using deterministic 0/1 knapsack optimization.',
            style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6)),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SUSTAINABILITY BUDGET', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.5))),
              Text('₹${(_sustainabilityBudget / 100000).toStringAsFixed(1)} Lakhs', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.primaryGreen)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.primaryGreen,
              inactiveTrackColor: Colors.white12,
              thumbColor: AppTheme.primaryGreen,
              overlayColor: AppTheme.primaryGreen.withOpacity(0.2),
            ),
            child: Slider(
              value: _sustainabilityBudget,
              min: 500000,
              max: 10000000,
              divisions: 19,
              onChanged: (val) => setState(() => _sustainabilityBudget = val),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOptStat('INVESTMENT', '₹${(allocated / 100000).toStringAsFixed(1)}L', AppTheme.primaryGreen),
                _buildOptStat('ANNUAL CO₂ SAVED', '${totalReduction.toStringAsFixed(1)} t/yr', AppTheme.primaryCyan),
                _buildOptStat('REMAINING', '₹${(remaining / 100000).toStringAsFixed(1)}L', Colors.white60),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text('OPTIMALLY SELECTED ACTIONS:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
          const SizedBox(height: 8),
          ...selectedActions.map((act) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.check_circle_outline, color: AppTheme.primaryGreen, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(act['name'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                          const SizedBox(height: 2),
                          Text(act['reason'] as String, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.5))),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('₹${((act['cost'] as double) / 100000).toStringAsFixed(1)}L', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text('↓ ${act['reduction']} t CO₂', style: const TextStyle(fontSize: 10, color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildOptStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 8.5, color: Colors.white38)),
      ],
    );
  }

  Widget _buildRoadmapSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ACTION PLAN ROADMAP', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 14),
          _buildRoadmapStep(
            period: 'NOW (1–2 WEEKS)',
            title: 'Operational Adjustments & Load Shifting',
            items: [
              'Shift 30kW Air Compressor runtime to 02:00–04:00 clean grid window',
              'Calibrate Production Line A motor idle threshold',
              'Raise HVAC thermostat to 24°C with nighttime precooling',
            ],
            color: AppTheme.primaryGreen,
          ),
          const SizedBox(height: 12),
          _buildRoadmapStep(
            period: 'NEAR TERM (1–3 MONTHS)',
            title: 'Equipment Efficiency Retrofits & VFDs',
            items: [
              'Install Variable Frequency Drives (VFD) on industrial slurry pumps',
              'Complete factory-wide LED lighting retrofit with presence sensors',
              'Automate furnace batch heating synchronization with rooftop solar',
            ],
            color: AppTheme.primaryCyan,
          ),
          const SizedBox(height: 12),
          _buildRoadmapStep(
            period: 'LONG TERM (6+ MONTHS)',
            title: 'Capital Infrastructure & Renewable Transition',
            items: [
              'Commission 500kW Rooftop Solar on central warehouse roof',
              'Phase out diesel logistics shuttles in favor of electric forklifts',
              'Negotiate 24/7 Corporate Green Power Purchase Agreement (PPA)',
            ],
            color: AppTheme.primaryYellow,
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapStep({required String period, required String title, required List<String> items, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                child: Text(period, style: TextStyle(color: color, fontSize: 9.5, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white))),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map((it) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                    Expanded(child: Text(it, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.7)))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _showEmissionFactorsModal() {
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
            const Text('CENTRALIZED EMISSION FACTORS', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 6),
            Text('CO₂ = Activity × Emission Factor (GHG Protocol Corporate Standard / IPCC)', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6))),
            const SizedBox(height: 14),
            _buildFactorRow('Electricity (India Grid Average)', '0.82 kg CO₂ / kWh'),
            _buildFactorRow('Diesel / Heavy Oil', '2.68 kg CO₂ / Litre'),
            _buildFactorRow('Natural Gas Combustion', '2.02 kg CO₂ / m³'),
            _buildFactorRow('Heavy Freight Logistics', '0.12 kg CO₂ / tonne-km'),
            _buildFactorRow('Industrial Landfill Waste', '0.45 kg CO₂ / kg waste'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFactorRow(String label, String factor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11.5, color: Colors.white70)),
          Text(factor, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
        ],
      ),
    );
  }

  void _showGlobalSearchDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final devices = context.read<DeviceProvider>().devices;
            final sensors = context.read<SensorProvider>().sensors;

            final matchedDevices = query.isEmpty ? <dynamic>[] : devices.where((d) => d.name.toLowerCase().contains(query) || d.id.toLowerCase().contains(query)).toList();
            final matchedSensors = query.isEmpty ? <dynamic>[] : sensors.where((s) => s.parameter.toLowerCase().contains(query) || s.id.toLowerCase().contains(query) || s.location.toLowerCase().contains(query)).toList();
            final matchedActions = query.isEmpty ? <dynamic>[] : _allActions.where((a) => (a['name'] as String).toLowerCase().contains(query)).toList();

            return Padding(
              padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
              child: SizedBox(
                height: 480,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.search, color: AppTheme.primaryGreen),
                        const SizedBox(width: 8),
                        const Text('GLOBAL INDUSTRIAL SEARCH', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                        const Spacer(),
                        IconButton(icon: const Icon(Icons.close, color: Colors.white54), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      autofocus: true,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search "Furnace", "PM2.5", "Solar", "Report"...',
                        hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                        filled: true,
                        fillColor: AppTheme.cardDark,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onChanged: (val) => setModalState(() => query = val.trim().toLowerCase()),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: query.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search, size: 48, color: Colors.white.withOpacity(0.2)),
                                  const SizedBox(height: 8),
                                  const Text('Search across 12 Machines, 12 Sensors, Actions & Reports', style: TextStyle(color: Colors.white38, fontSize: 11)),
                                ],
                              ),
                            )
                          : ListView(
                              children: [
                                if (matchedDevices.isNotEmpty) ...[
                                  const Text('MACHINES', style: TextStyle(color: AppTheme.primaryGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ...matchedDevices.map((d) => ListTile(
                                        dense: true,
                                        leading: const Icon(Icons.precision_manufacturing, color: AppTheme.primaryGreen, size: 20),
                                        title: Text(d.name, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold)),
                                        subtitle: Text('${d.id} • ${d.liveKw.toStringAsFixed(1)} kW • ${d.risk} Risk', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                                        onTap: () {
                                          Navigator.pop(ctx);
                                          context.go('/appliances');
                                        },
                                      )),
                                ],
                                if (matchedSensors.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  const Text('SENSORS', style: TextStyle(color: AppTheme.primaryCyan, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ...matchedSensors.map((s) => ListTile(
                                        dense: true,
                                        leading: const Icon(Icons.sensors, color: AppTheme.primaryCyan, size: 20),
                                        title: Text('${s.id}: ${s.parameter}', style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold)),
                                        subtitle: Text('${s.value} ${s.unit} • ${s.location} • ${s.status}', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                                        onTap: () {
                                          Navigator.pop(ctx);
                                          context.go('/appliances');
                                        },
                                      )),
                                ],
                                if (matchedActions.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  const Text('REDUCTION ACTIONS', style: TextStyle(color: AppTheme.primaryYellow, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ...matchedActions.map((a) => ListTile(
                                        dense: true,
                                        leading: const Icon(Icons.bolt, color: AppTheme.primaryYellow, size: 20),
                                        title: Text(a['name'], style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold)),
                                        subtitle: Text('Save ${a['reduction']} t CO₂ • Payback: ${a['payback']}', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                                        onTap: () {
                                          Navigator.pop(ctx);
                                          context.go('/prediction');
                                        },
                                      )),
                                ],
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
