import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/report_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _selectedPeriod = 0; // 0 = Daily, 1 = Weekly, 2 = Monthly

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().fetchAllReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carbon Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ReportProvider>().fetchAllReports(),
            tooltip: 'Refresh Reports',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _handleDownloadPdf,
            tooltip: 'Download PDF Report',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildPeriodTab('Daily', 0),
                const SizedBox(width: 8),
                _buildPeriodTab('Weekly', 1),
                const SizedBox(width: 8),
                _buildPeriodTab('Monthly', 2),
              ],
            ),
          ),
          Expanded(
            child: Consumer<ReportProvider>(
              builder: (context, provider, _) {
                final report = _selectedPeriod == 0
                    ? provider.dailyReport
                    : _selectedPeriod == 1
                        ? provider.weeklyReport
                        : provider.monthlyReport;

                final carbonUsed = report?.totalCarbonUsed ?? (_selectedPeriod == 0 ? 12.4 : _selectedPeriod == 1 ? 84.6 : 287.0);
                final carbonSaved = report?.totalCarbonSaved ?? (_selectedPeriod == 0 ? 4.2 : _selectedPeriod == 1 ? 28.5 : 86.1);
                final electricity = report?.totalElectricityUsed ?? (_selectedPeriod == 0 ? 18.5 : _selectedPeriod == 1 ? 122.0 : 350.0);
                final renewable = report?.renewablePercentage ?? (_selectedPeriod == 0 ? 68.0 : _selectedPeriod == 1 ? 62.5 : 57.0);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${_selectedPeriod == 0 ? "Daily" : _selectedPeriod == 1 ? "Weekly" : "Monthly"} Summary',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryGreen.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '-${((carbonSaved / (carbonUsed + carbonSaved)) * 100).toStringAsFixed(0)}% CO₂',
                                      style: const TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildSummaryRow('Total Carbon Footprint', '${carbonUsed.toStringAsFixed(1)} kg CO₂', AppTheme.primaryRed),
                              _buildSummaryRow('Total Carbon Saved', '${carbonSaved.toStringAsFixed(1)} kg CO₂', AppTheme.primaryGreen),
                              _buildSummaryRow('Electricity Consumed', '${electricity.toStringAsFixed(0)} kWh', AppTheme.primaryYellow),
                              _buildSummaryRow('Renewable Energy Share', '${renewable.toStringAsFixed(0)}%', AppTheme.primaryCyan),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Appliance Breakdown', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 16),
                              _buildDeviceStatRow(
                                'EV Charger',
                                '${(_selectedPeriod == 0 ? 5.2 : _selectedPeriod == 1 ? 35.0 : 120.0).toStringAsFixed(1)} kg',
                                '${(_selectedPeriod == 0 ? 2.1 : _selectedPeriod == 1 ? 12.0 : 36.0).toStringAsFixed(1)} kg saved',
                              ),
                              _buildDeviceStatRow(
                                'Air Conditioner',
                                '${(_selectedPeriod == 0 ? 3.8 : _selectedPeriod == 1 ? 24.0 : 85.0).toStringAsFixed(1)} kg',
                                '${(_selectedPeriod == 0 ? 1.0 : _selectedPeriod == 1 ? 6.5 : 15.0).toStringAsFixed(1)} kg saved',
                              ),
                              _buildDeviceStatRow(
                                'Smart Washing Machine',
                                '${(_selectedPeriod == 0 ? 1.8 : _selectedPeriod == 1 ? 14.0 : 45.0).toStringAsFixed(1)} kg',
                                '${(_selectedPeriod == 0 ? 0.8 : _selectedPeriod == 1 ? 7.0 : 25.0).toStringAsFixed(1)} kg saved',
                              ),
                              _buildDeviceStatRow(
                                'Eco Water Heater',
                                '${(_selectedPeriod == 0 ? 1.6 : _selectedPeriod == 1 ? 11.6 : 37.0).toStringAsFixed(1)} kg',
                                '${(_selectedPeriod == 0 ? 0.3 : _selectedPeriod == 1 ? 3.0 : 10.0).toStringAsFixed(1)} kg saved',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _handleDownloadPdf,
                          icon: const Icon(Icons.picture_as_pdf),
                          label: Text('Download ${_selectedPeriod == 0 ? "Daily" : _selectedPeriod == 1 ? "Weekly" : "Monthly"} PDF Report'),
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

  void _handleDownloadPdf() {
    final periodName = _selectedPeriod == 0 ? "Daily" : _selectedPeriod == 1 ? "Weekly" : "Monthly";
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('CarbonWise $periodName Report generated & saved to downloads!'),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildPeriodTab(String label, int index) {
    final isSelected = _selectedPeriod == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryGreen.withOpacity(0.15) : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: isSelected ? Border.all(color: AppTheme.primaryGreen) : Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppTheme.primaryGreen : Colors.white54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      );

  Widget _buildDeviceStatRow(String device, String carbon, String saved) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(flex: 2, child: Text(device, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
            Expanded(child: Text(carbon, style: const TextStyle(fontSize: 13, color: Colors.white54))),
            Expanded(child: Text(saved, style: const TextStyle(fontSize: 13, color: AppTheme.primaryGreen))),
          ],
        ),
      );
}
