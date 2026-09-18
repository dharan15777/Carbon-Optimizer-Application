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
  int _selectedTab = 0;

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
      appBar: AppBar(title: const Text('Carbon Prediction')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              _buildTimeTab('6 Hours', 0),
              const SizedBox(width: 8),
              _buildTimeTab('12 Hours', 1),
              const SizedBox(width: 8),
              _buildTimeTab('24 Hours', 2),
            ]),
          ),
          Expanded(
            child: Consumer<PredictionProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading) return const Center(child: CircularProgressIndicator());
                final prediction = _selectedTab == 0 ? provider.prediction6h : _selectedTab == 1 ? provider.prediction12h : provider.prediction24h;
                if (prediction == null) return const Center(child: Text('No prediction data available'));
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBestTimeCard('Best EV Charging Time', prediction.bestChargingTime, Icons.ev_station, AppTheme.primaryGreen),
                      const SizedBox(height: 12),
                      _buildBestTimeCard('Best Appliance Time', prediction.bestApplianceTime, Icons.schedule, AppTheme.primaryCyan),
                      const SizedBox(height: 24),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [Icon(Icons.smart_toy, color: AppTheme.primaryGreen), const SizedBox(width: 8), const Text('AI Recommendation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600))]),
                              const SizedBox(height: 12),
                              Text(prediction.recommendation, style: const TextStyle(fontSize: 14, color: Colors.white70)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryGreen.withOpacity(0.15) : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(color: AppTheme.primaryGreen) : Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isSelected ? AppTheme.primaryGreen : Colors.white54)),
        ),
      ),
    );
  }

  Widget _buildBestTimeCard(String title, String time, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 14, color: Colors.white54)), const SizedBox(height: 4), Text(time, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700))])),
          ],
        ),
      ),
    );
  }
}
