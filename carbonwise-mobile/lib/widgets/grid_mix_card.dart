import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class GridMixCard extends StatelessWidget {
  final double solarWindPercent;
  final double hydroPercent;
  final double gasPercent;
  final double coalPercent;

  const GridMixCard({
    super.key,
    required this.solarWindPercent,
    required this.hydroPercent,
    required this.gasPercent,
    required this.coalPercent,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Grid Power Generation Mix',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            _buildMixBar('Solar & Wind', solarWindPercent, AppTheme.primaryGreen),
            const SizedBox(height: 8),
            _buildMixBar('Hydroelectric', hydroPercent, AppTheme.primaryCyan),
            const SizedBox(height: 8),
            _buildMixBar('Natural Gas', gasPercent, AppTheme.primaryYellow),
            const SizedBox(height: 8),
            _buildMixBar('Coal Power', coalPercent, AppTheme.primaryRed),
          ],
        ),
      ),
    );
  }

  Widget _buildMixBar(String label, double percent, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent / 100,
              backgroundColor: Colors.white.withOpacity(0.05),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            '${percent.toStringAsFixed(0)}%',
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
