import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/carbon_provider.dart';
import '../../widgets/carbon_gauge.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedOrg = 'Alpha MegaFactory (HQ)';
  double _sustainabilityBudget = 11000000; // ₹1,10,00,000

  final List<Map<String, dynamic>> _allActions = [
    {
      'name': 'Rooftop Solar 500kW',
      'cost': 5000000.0,
      'reduction': 50.0,
      'category': 'Renewable',
      'reason': 'High daylight generation potential in factory yard',
      'roi': '3.2 yrs',
    },
    {
      'name': 'Factory-wide LED Retrofit',
      'cost': 800000.0,
      'reduction': 8.5,
      'category': 'Lighting',
      'reason': 'Fast payback and immediate grid load reduction',
      'roi': '0.9 yrs',
    },
    {
      'name': 'IE4 Super Premium Motor Upgrade',
      'cost': 1500000.0,
      'reduction': 14.0,
      'category': 'Motors',
      'reason': 'Cuts continuous inductive load on Production Line B',
      'roi': '2.1 yrs',
    },
    {
      'name': 'Electric Forklift & Shuttle Transition',
      'cost': 2100000.0,
      'reduction': 9.9,
      'category': 'Logistics',
      'reason': 'Eliminates indoor diesel fumes and saves on fuel tariffs',
      'roi': '2.8 yrs',
    },
    {
      'name': 'Variable Frequency Drives (VFD) on Pumps',
      'cost': 1200000.0,
      'reduction': 11.2,
      'category': 'HVAC',
      'reason': 'Modulates cooling water circulation according to thermal load',
      'roi': '1.5 yrs',
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CarbonProvider>().fetchLiveIntensity();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        color: AppTheme.primaryGreen,
        onRefresh: () async => context.read<CarbonProvider>().fetchLiveIntensity(),
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
                'AI Reduction Engine',
                style: TextStyle(fontSize: 10, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
      actions: [
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
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppTheme.primaryGreen, blurRadius: 6, spreadRadius: 1),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'TELEMETRY ONLINE',
                    style: TextStyle(color: AppTheme.primaryGreen, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('24 SENSORS ACTIVE', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
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
                DropdownMenuItem(value: 'Alpha MegaFactory (HQ)', child: Text('🏢 Alpha MegaFactory (HQ) • Chennai', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white))),
                DropdownMenuItem(value: 'Beta Chemical Plant', child: Text('🏭 Beta Chemical Plant • Gujarat', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white))),
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
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                title: 'TOTAL FOOTPRINT',
                value: '1,284 t',
                sub: 'CO₂e this month',
                trend: '↓ 8.4%',
                trendColor: AppTheme.primaryGreen,
                icon: Icons.cloud_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKPICard(
                title: 'CARBON REDUCTION',
                value: '18.6%',
                sub: 'vs baseline target',
                trend: 'Target: 25%',
                trendColor: AppTheme.primaryCyan,
                icon: Icons.trending_down,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildKPICard(
                title: 'GRID INTENSITY',
                value: '412 g',
                sub: 'CO₂ / kWh',
                trend: 'Clean window in 2h',
                trendColor: AppTheme.primaryYellow,
                icon: Icons.bolt_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildKPICard(
                title: 'SUSTAINABILITY BUDGET',
                value: '₹1.10 Cr',
                sub: '₹94.4L invested',
                trend: 'ROI 2.3y',
                trendColor: AppTheme.primaryGreen,
                icon: Icons.account_balance_wallet_outlined,
              ),
            ),
          ],
        ),
      ],
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: 0.6)),
              Icon(icon, size: 16, color: Colors.white38),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
          const SizedBox(height: 2),
          Text(sub, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.4))),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: trendColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(trend, style: TextStyle(color: trendColor, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveGaugeSection() {
    return Consumer<CarbonProvider>(
      builder: (context, provider, _) {
        final val = provider.liveIntensity?.intensity ?? 412.0;
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
                      Text('National / Regional Grid Mix Integration', style: TextStyle(fontSize: 10, color: Colors.white38)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('LIVE gCO₂/kWh', style: TextStyle(color: AppTheme.primaryGreen, fontSize: 10, fontWeight: FontWeight.bold)),
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
      {'name': 'Purchased Electricity', 'percent': 52, 'emissions': '667 t CO₂', 'color': AppTheme.primaryGreen},
      {'name': 'Direct Fuel & Boilers', 'percent': 21, 'emissions': '269 t CO₂', 'color': AppTheme.primaryCyan},
      {'name': 'Production / Kilns', 'percent': 15, 'emissions': '192 t CO₂', 'color': AppTheme.primaryYellow},
      {'name': 'Heavy Logistics & Fleet', 'percent': 8, 'emissions': '103 t CO₂', 'color': Colors.purpleAccent},
      {'name': 'Industrial Waste', 'percent': 4, 'emissions': '53 t CO₂', 'color': Colors.redAccent},
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
              const Text('CARBON SOURCES BREAKDOWN', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
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
          ...sources.map((s) => _buildSourceRow(
                name: s['name'] as String,
                percent: s['percent'] as int,
                emissions: s['emissions'] as String,
                color: s['color'] as Color,
              )),
        ],
      ),
    );
  }

  Widget _buildSourceRow({required String name, required int percent, required String emissions, required Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 12, color: Colors.white70))),
          Text('$percent%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(width: 12),
          Text(emissions, style: const TextStyle(fontSize: 11, color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _buildCarbonHotspotsSection() {
    final hotspots = [
      {
        'name': 'Production Line A',
        'emission': '324 t CO₂',
        'trend': '+4.2%',
        'severity': 'HIGH RISK',
        'color': Colors.redAccent,
        'action': 'Optimize motor drive frequency to eliminate idle loss',
      },
      {
        'name': 'Industrial Smelting Furnace #3',
        'emission': '216 t CO₂',
        'trend': '-1.5%',
        'severity': 'HIGH RISK',
        'color': Colors.redAccent,
        'action': 'Pre-heat combustion air with exhaust heat recuperator',
      },
      {
        'name': 'Facility Central HVAC Chillers',
        'emission': '143 t CO₂',
        'trend': '+0.8%',
        'severity': 'MEDIUM',
        'color': AppTheme.primaryYellow,
        'action': 'Raise setpoint to 24°C and enable nighttime precooling',
      },
      {
        'name': 'Auxiliary Diesel Generator',
        'emission': '97 t CO₂',
        'trend': '-12.0%',
        'severity': 'MEDIUM',
        'color': AppTheme.primaryYellow,
        'action': 'Replace runtime with battery storage during peak tariff',
      },
      {
        'name': 'Logistics & Heavy Haul Fleet',
        'emission': '76 t CO₂',
        'trend': '-3.4%',
        'severity': 'CONTROLLED',
        'color': AppTheme.primaryGreen,
        'action': 'Automated load dispatch and telematics route scheduling',
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
              const Text('CARBON HOTSPOTS & CRITICAL UNITS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                child: const Text('5 UNITS MONITORED', style: TextStyle(color: Colors.redAccent, fontSize: 9.5, fontWeight: FontWeight.bold)),
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
              Text(h['name'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
              Row(
                children: [
                  Text(h['emission'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                    child: Text(h['severity'] as String, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.bolt, size: 13, color: AppTheme.primaryGreen),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  h['action'] as String,
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    final actions = [
      {
        'title': 'Shift EV Fleet Charging to 14:00',
        'desc': 'Grid carbon intensity drops to 286 gCO₂/kWh. Potential saving: 18.4 kg CO₂ per charge cycle.',
        'btn': 'Schedule Shift',
        'route': '/scheduler',
        'icon': Icons.ev_station,
        'color': AppTheme.primaryGreen,
      },
      {
        'title': 'Rooftop Solar Peak Available (68%)',
        'desc': 'Excess on-site solar generation. Ramp up heavy furnace batch heating now to avoid grid power.',
        'btn': 'Optimize Loads',
        'route': '/appliances',
        'icon': Icons.solar_power,
        'color': AppTheme.primaryCyan,
      },
      {
        'title': 'Production Line A Spike Detected',
        'desc': 'Anomalous surge of +14% energy draw detected. Recommended calibration inspection.',
        'btn': 'Inspect Device',
        'route': '/appliances',
        'icon': Icons.warning_amber,
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
              padding: const EdgeInsets.all(14),
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
                        const SizedBox(height: 4),
                        Text(a['desc'] as String, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6), height: 1.3)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: () => context.go(a['route'] as String),
                          child: Text(
                            '${a['btn']} ›',
                            style: TextStyle(color: a['color'] as Color, fontSize: 12, fontWeight: FontWeight.bold),
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
    // Knapsack / budget optimizer
    double allocated = 0;
    double totalReduction = 0;
    List<Map<String, dynamic>> selectedActions = [];

    // Sort by reduction per rupee
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
                  Text('AI OPTIMIZATION ENGINE', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.8)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('KNAPSACK ALLOCATOR', style: TextStyle(color: AppTheme.primaryGreen, fontSize: 9.5, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Dynamically optimizes multi-source carbon reduction based on available enterprise budget.',
            style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6)),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ENTERPRISE BUDGET', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.5))),
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
              min: 2000000,
              max: 20000000,
              divisions: 18,
              onChanged: (val) => setState(() => _sustainabilityBudget = val),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildOptStat('RECOMMENDED', '₹${(allocated / 100000).toStringAsFixed(1)}L', AppTheme.primaryGreen),
                _buildOptStat('EXPECTED REDUCTION', '${totalReduction.toStringAsFixed(1)} t/yr', AppTheme.primaryCyan),
                _buildOptStat('REMAINING', '₹${(remaining / 100000).toStringAsFixed(1)}L', Colors.white60),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text('RECOMMENDED ACTION PORTFOLIO:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70)),
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
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.white38)),
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
          const Text('ACTION PLAN & DECARBONIZATION ROADMAP', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 14),
          _buildRoadmapStep(
            period: 'NOW (1–2 WEEKS)',
            title: 'Operational Adjustments & Telemetry Calibration',
            items: ['Calibrate Production Line A motor idle settings', 'Shift HVAC thermostat setpoint to 24°C', 'Enforce daytime EV fleet charging policy'],
            color: AppTheme.primaryGreen,
          ),
          const SizedBox(height: 12),
          _buildRoadmapStep(
            period: 'NEAR TERM (1–3 MONTHS)',
            title: 'Equipment Efficiency & Grid-Aware Schedules',
            items: ['Install VFDs across auxiliary chiller pumps', 'Automate high-load batch shifting to solar windows', 'Factory-wide LED light sensor upgrades'],
            color: AppTheme.primaryCyan,
          ),
          const SizedBox(height: 12),
          _buildRoadmapStep(
            period: 'LONG TERM (6+ MONTHS)',
            title: 'Infrastructure & Clean Energy Transition',
            items: ['500kW Rooftop Solar deployment on storage bay', 'EV shuttle replacement for material transport', 'Long-term green power purchase agreement (PPA)'],
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
            const Text('CENTRALIZED EMISSION FACTORS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text('Calculation: CO₂ = Activity × Emission Factor (IPCC / CEA 2024)', style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6))),
            const SizedBox(height: 16),
            _buildFactorRow('Electricity (India Grid Average)', '0.82 kg CO₂ / kWh'),
            _buildFactorRow('Diesel / Heavy Oil', '2.68 kg CO₂ / Litre'),
            _buildFactorRow('Natural Gas', '2.02 kg CO₂ / m³'),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
          Text(factor, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGreen)),
        ],
      ),
    );
  }
}
