import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/helpers.dart';

class CarbonGauge extends StatelessWidget {
  final double intensity;
  final double maxValue;

  const CarbonGauge({
    super.key,
    required this.intensity,
    this.maxValue = 600,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(Helpers.getCarbonColor(intensity));
    final progress = (intensity / maxValue).clamp(0.0, 1.0);

    return Column(
      children: [
        const SizedBox(height: 20),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 180,
              height: 180,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 12,
                backgroundColor: Colors.white.withOpacity(0.05),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Column(
              children: [
                Text(
                  intensity.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                const Text(
                  'gCO₂/kWh',
                  style: TextStyle(fontSize: 12, color: Colors.white54),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            Helpers.getCarbonStatus(intensity),
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
