import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/prediction_provider.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  int _selectedHours = 24; // 6, 12, 24

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PredictionProvider>().fetchAllPredictions();
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
            Text('CARBON PREDICTION & FORECAST', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: Colors.white)),
            Text('Machine Learning Grid Forecast', style: TextStyle(fontSize: 10, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () => context.read<PredictionProvider>().fetchAllPredictions(),
            tooltip: 'Refresh Forecast',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHorizonSelector(),
            const SizedBox(height: 16),
            _buildMetricsOverview(),
            const SizedBox(height: 20),
            _buildForecastChart(),
            const SizedBox(height: 20),
            _buildBestWindowsSection(),
            const SizedBox(height: 20),
            _buildRecommendationCard(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizonSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          _buildHorizonTab('6 HOURS', 6),
          _buildHorizonTab('12 HOURS', 12),
          _buildHorizonTab('24 HOURS', 24),
        ],
      ),
    );
  }

  Widget _buildHorizonTab(String label, int hours) {
    final isSelected = _selectedHours == hours;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedHours = hours),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: isSelected ? AppTheme.backgroundDark : Colors.white60,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsOverview() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CURRENT INTENSITY', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9.5, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text('412 g', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 2),
                Text('CO₂ / kWh', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.4))),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                  child: const Text('Peak Grid Draw', style: TextStyle(color: Colors.redAccent, fontSize: 9.5, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('PREDICTED LOW', style: TextStyle(color: AppTheme.primaryGreen, fontSize: 9.5, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text('286 g', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.primaryGreen)),
                const SizedBox(height: 2),
                Text('CO₂ / kWh at 15:00', style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.4))),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppTheme.primaryGreen.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                  child: const Text('↓ 30.5% Drop', style: TextStyle(color: AppTheme.primaryGreen, fontSize: 9.5, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForecastChart() {
    // Generate simulated forecast data points for the chosen hours
    final points = _selectedHours == 6
        ? [
            {'time': '12:00', 'val': 412, 'type': 'high'},
            {'time': '13:00', 'val': 370, 'type': 'med'},
            {'time': '14:00', 'val': 310, 'type': 'clean'},
            {'time': '15:00', 'val': 286, 'type': 'clean'},
            {'time': '16:00', 'val': 305, 'type': 'clean'},
            {'time': '17:00', 'val': 365, 'type': 'med'},
          ]
        : _selectedHours == 12
            ? [
                {'time': '12:00', 'val': 412, 'type': 'high'},
                {'time': '14:00', 'val': 310, 'type': 'clean'},
                {'time': '16:00', 'val': 305, 'type': 'clean'},
                {'time': '18:00', 'val': 430, 'type': 'high'},
                {'time': '20:00', 'val': 455, 'type': 'high'},
                {'time': '22:00', 'val': 380, 'type': 'med'},
              ]
            : [
                {'time': '12:00', 'val': 412, 'type': 'high'},
                {'time': '15:00', 'val': 286, 'type': 'clean'},
                {'time': '18:00', 'val': 440, 'type': 'high'},
                {'time': '21:00', 'val': 465, 'type': 'high'},
                {'time': '00:00', 'val': 340, 'type': 'med'},
                {'time': '03:00', 'val': 320, 'type': 'med'},
                {'time': '06:00', 'val': 390, 'type': 'med'},
                {'time': '09:00', 'val': 330, 'type': 'clean'},
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
              const Text('FORECAST CURVE (gCO₂/kWh)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
              Row(
                children: [
                  _buildLegendItem('Clean', AppTheme.primaryGreen),
                  const SizedBox(width: 8),
                  _buildLegendItem('Normal', AppTheme.primaryYellow),
                  const SizedBox(width: 8),
                  _buildLegendItem('High Carbon', Colors.redAccent),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: points.map((p) {
                final val = p['val'] as int;
                final type = p['type'] as String;
                final color = type == 'clean'
                    ? AppTheme.primaryGreen
                    : type == 'med'
                        ? AppTheme.primaryYellow
                        : Colors.redAccent;

                // Height scaled from 200 to 500
                final height = ((val - 200) / 300.0) * 100 + 20;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('$val', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color)),
                    const SizedBox(height: 4),
                    Container(
                      width: 22,
                      height: height,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(color: color.withOpacity(0.3), blurRadius: 4, spreadRadius: 0),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(p['time'] as String, style: const TextStyle(fontSize: 9, color: Colors.white54)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 9.5)),
      ],
    );
  }

  Widget _buildBestWindowsSection() {
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
          const Text('OPTIMAL OPERATING WINDOWS', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 12),
          _buildWindowCard(
            title: 'BEST CLEAN ENERGY WINDOW',
            time: '14:00 – 17:00 Today',
            saving: '18.4 kg CO₂ per cycle',
            detail: 'Solar penetration peaks at 68% on the grid. Recommended for industrial compressors & battery charging.',
            color: AppTheme.primaryGreen,
            icon: Icons.eco,
          ),
          const SizedBox(height: 10),
          _buildWindowCard(
            title: 'SECONDARY OVERNIGHT WINDOW',
            time: '02:00 – 05:00 Tomorrow',
            saving: '12.1 kg CO₂ per cycle',
            detail: 'Off-peak thermal baseload with favorable grid tariff. Recommended for continuous smelting.',
            color: AppTheme.primaryCyan,
            icon: Icons.nightlight_round,
          ),
        ],
      ),
    );
  }

  Widget _buildWindowCard({
    required String title,
    required String time,
    required String saving,
    required String detail,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.6)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(time, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('Save $saving', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
          const SizedBox(height: 4),
          Text(detail, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.6), height: 1.3)),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard() {
    return Consumer<PredictionProvider>(
      builder: (context, provider, _) {
        final rec = provider.prediction24h?.recommendation ??
            'AI Engine Recommendation: Shift heavy batch loads from 18:00 (coal peak 440 gCO₂/kWh) to 14:30 (solar high 286 gCO₂/kWh) to reduce daily Scope 2 emissions by 14.8%.';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.smart_toy, color: AppTheme.primaryGreen, size: 18),
                  SizedBox(width: 8),
                  Text('AI LOAD-SHIFTING DISPATCH', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white)),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                rec,
                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8), height: 1.4),
              ),
            ],
          ),
        );
      },
    );
  }
}
