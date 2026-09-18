import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/carbon_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/carbon_gauge.dart';
import '../../widgets/grid_mix_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
      appBar: AppBar(
        title: const Text('CarbonWise'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.go('/notifications'),
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => context.read<CarbonProvider>().fetchLiveIntensity(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<AuthProvider>(
                builder: (context, auth, _) => Text(
                  'Hello, ${auth.user?.name ?? 'User'} 👋',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Monitor your carbon footprint in real-time',
                style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14),
              ),
              const SizedBox(height: 24),
              Consumer<CarbonProvider>(
                builder: (context, provider, _) {
                  final intensity = provider.liveIntensity;
                  final val = intensity?.intensity ?? 118.0;
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Live Carbon Intensity',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.circle, color: AppTheme.primaryGreen, size: 8),
                                    SizedBox(width: 4),
                                    Text('LIVE', style: TextStyle(color: AppTheme.primaryGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          CarbonGauge(intensity: val),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Consumer<CarbonProvider>(
                builder: (context, provider, _) {
                  final intensity = provider.liveIntensity;
                  return GridMixCard(
                    solarWindPercent: intensity?.solarWindPercent ?? 64.0,
                    hydroPercent: intensity?.hydroPercent ?? 12.0,
                    gasPercent: intensity?.gasPercent ?? 14.0,
                    coalPercent: intensity?.coalPercent ?? 10.0,
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildQuickAction(
                    Icons.ev_station,
                    'Best Charging',
                    AppTheme.primaryGreen,
                    () => context.go('/prediction'),
                  ),
                  const SizedBox(width: 12),
                  _buildQuickAction(
                    Icons.schedule,
                    'Schedule',
                    AppTheme.primaryCyan,
                    () => context.go('/scheduler'),
                  ),
                  const SizedBox(width: 12),
                  _buildQuickAction(
                    Icons.tips_and_updates,
                    'Carbon Tips',
                    AppTheme.primaryYellow,
                    () => _showTipsModal(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTipsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTipsModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.cardDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: AppTheme.primaryYellow, size: 28),
                const SizedBox(width: 12),
                const Text('AI Carbon Tips', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            _buildTipItem('Charge EV between 11:00 AM – 2:00 PM for maximum solar power.'),
            _buildTipItem('Pre-cool rooms 1 hour before 6:00 PM grid peak.'),
            _buildTipItem('Run dishwasher and washing machine in eco-solar mode.'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Got it!'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.lightbulb, color: AppTheme.primaryYellow),
              const SizedBox(width: 8),
              const Text('Carbon Saving Insights', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ]),
            const SizedBox(height: 12),
            _buildTipItem('Charge your EV during peak solar hours (10AM–2PM)'),
            _buildTipItem('Run washing machines during low-carbon windows'),
            _buildTipItem('Pre-heat water during renewable energy peaks'),
            _buildTipItem('Schedule AC pre-cooling before grid peak hours'),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: AppTheme.primaryGreen, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(tip, style: const TextStyle(fontSize: 13, color: Colors.white70))),
        ],
      ),
    );
  }
}
