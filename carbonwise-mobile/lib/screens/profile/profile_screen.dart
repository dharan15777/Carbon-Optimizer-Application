import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _orgController;
  late TextEditingController _roleController;
  late TextEditingController _locationController;
  late TextEditingController _industryController;
  late TextEditingController _orgSizeController;
  late TextEditingController _targetController;
  late TextEditingController _budgetController;

  bool _alertOnPeakGrid = true;
  bool _alertOnDeviceFault = true;
  bool _weeklyEmailReport = true;
  final String _selectedLanguage = 'English (Global)';

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameController = TextEditingController(text: auth.user?.name ?? 'Dr. Aris Thorne');
    _emailController = TextEditingController(text: auth.user?.email ?? 'sustainability@alphamega.in');
    _phoneController = TextEditingController(text: '+91 98401 23456');
    _orgController = TextEditingController(text: 'Alpha MegaFactory Industrial Corp');
    _roleController = TextEditingController(text: auth.user?.role ?? 'Chief Sustainability Officer (CSO)');
    _locationController = TextEditingController(text: 'SIPCOT Industrial Park, Chennai');
    _industryController = TextEditingController(text: 'Automotive & Heavy Metallurgy');
    _orgSizeController = TextEditingController(text: '2,400 Employees • 4 Manufacturing Plants');
    _targetController = TextEditingController(text: '25% Net Scope 1 & 2 Reduction by FY27');
    _budgetController = TextEditingController(text: '₹10,00,000 / month');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _orgController.dispose();
    _roleController.dispose();
    _locationController.dispose();
    _industryController.dispose();
    _orgSizeController.dispose();
    _targetController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceDark,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ENTERPRISE PROFILE', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: Colors.white)),
            Text('Industrial Organization & Audit Settings', style: TextStyle(fontSize: 10, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit_outlined, color: AppTheme.primaryGreen),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
            tooltip: _isEditing ? 'Save Changes' : 'Edit Profile',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAvatarHeader(auth),
            const SizedBox(height: 20),
            _buildOrganizationCard(),
            const SizedBox(height: 16),
            _buildSustainabilityTargetsCard(),
            const SizedBox(height: 16),
            _buildNotificationPrefsCard(),
            const SizedBox(height: 16),
            _buildSecurityAndAuditCard(auth),
            const SizedBox(height: 24),
            _buildActionButtons(auth),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarHeader(AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: AppTheme.primaryGreen.withOpacity(0.15),
                child: const Text('CSO', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.primaryGreen)),
              ),
              if (_isEditing)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppTheme.primaryGreen, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, size: 16, color: AppTheme.backgroundDark),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isEditing)
            TextField(
              controller: _nameController,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              decoration: const InputDecoration(border: UnderlineInputBorder(), hintText: 'Full Name'),
            )
          else
            Text(_nameController.text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text(_emailController.text, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5))),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_roleController.text, style: const TextStyle(color: AppTheme.primaryGreen, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              if (auth.isGuestMode) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryYellow.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('DEMO MODE', style: TextStyle(color: AppTheme.primaryYellow, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrganizationCard() {
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
          const Row(
            children: [
              Icon(Icons.business, color: AppTheme.primaryCyan, size: 18),
              SizedBox(width: 8),
              Text('ENTERPRISE & FACILITY DETAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.6)),
            ],
          ),
          const SizedBox(height: 14),
          _buildFieldRow('Enterprise Name', _orgController),
          _buildFieldRow('Industrial Sector', _industryController),
          _buildFieldRow('Organization Size', _orgSizeController),
          _buildFieldRow('Facility Location', _locationController),
          _buildFieldRow('Official Phone', _phoneController),
        ],
      ),
    );
  }

  Widget _buildSustainabilityTargetsCard() {
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
          const Row(
            children: [
              Icon(Icons.track_changes, color: AppTheme.primaryGreen, size: 18),
              SizedBox(width: 8),
              Text('SUSTAINABILITY COMMITMENTS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.6)),
            ],
          ),
          const SizedBox(height: 14),
          _buildFieldRow('Decarbonization Target', _targetController),
          _buildFieldRow('Monthly Sustainability Budget', _budgetController),
          _buildStaticRow('Preferred Renewable Mix', 'Rooftop Solar 500kW + Green PPA'),
          _buildStaticRow('ESG Reporting Standard', 'BRSR Core • GHG Protocol Corporate Standard'),
        ],
      ),
    );
  }

  Widget _buildFieldRow(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          if (_isEditing)
            TextField(
              controller: controller,
              style: const TextStyle(fontSize: 13, color: Colors.white),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 6),
                isDense: true,
              ),
            )
          else
            Text(controller.text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildStaticRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildNotificationPrefsCard() {
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
          const Row(
            children: [
              Icon(Icons.notifications_active_outlined, color: AppTheme.primaryYellow, size: 18),
              SizedBox(width: 8),
              Text('INTELLIGENT ALERT PREFERENCES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.6)),
            ],
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Peak Grid Intensity Alerts (>450 gCO₂/kWh)', style: TextStyle(fontSize: 12, color: Colors.white70)),
            value: _alertOnPeakGrid,
            activeColor: AppTheme.primaryGreen,
            onChanged: (val) => setState(() => _alertOnPeakGrid = val),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Asset Energy Spike / Anomaly Detection', style: TextStyle(fontSize: 12, color: Colors.white70)),
            value: _alertOnDeviceFault,
            activeColor: AppTheme.primaryGreen,
            onChanged: (val) => setState(() => _alertOnDeviceFault = val),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Weekly ESG Executive Summary Email', style: TextStyle(fontSize: 12, color: Colors.white70)),
            value: _weeklyEmailReport,
            activeColor: AppTheme.primaryGreen,
            onChanged: (val) => setState(() => _weeklyEmailReport = val),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityAndAuditCard(AuthProvider auth) {
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
          const Row(
            children: [
              Icon(Icons.shield_outlined, color: AppTheme.primaryGreen, size: 18),
              SizedBox(width: 8),
              Text('SECURITY & AUDIT TRAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.6)),
            ],
          ),
          const SizedBox(height: 12),
          _buildStaticRow('Interface Language', _selectedLanguage),
          _buildStaticRow('Cryptographic Protocol', 'TLS 1.3 • AES-256 Encrypted Telemetry'),
          _buildStaticRow('Active Session Key', 'JWT HMAC-SHA256 • Verified by Backend'),
          _buildStaticRow('Auditor Role', 'Level-3 Carbon Auditor Clearance Granted'),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AuthProvider auth) {
    return Column(
      children: [
        if (_isEditing)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _isEditing = false),
                  child: const Text('CANCEL'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGreen),
                  onPressed: _saveProfile,
                  child: const Text('SAVE CHANGES', style: TextStyle(color: AppTheme.backgroundDark, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        else ...[
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.edit, color: AppTheme.backgroundDark, size: 18),
              label: const Text('EDIT ENTERPRISE PROFILE', style: TextStyle(color: AppTheme.backgroundDark, fontWeight: FontWeight.bold, letterSpacing: 0.6)),
              onPressed: () => setState(() => _isEditing = true),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.redAccent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.logout, color: Colors.redAccent, size: 18),
              label: const Text('LOGOUT OF INDUSTRIAL OS', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
              onPressed: () {
                auth.logout();
                context.go('/login');
              },
            ),
          ),
        ],
      ],
    );
  }

  void _saveProfile() {
    setState(() => _isEditing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Enterprise Profile updated successfully!'),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
