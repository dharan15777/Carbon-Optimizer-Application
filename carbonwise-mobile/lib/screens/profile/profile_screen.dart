import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppTheme.primaryGreen.withOpacity(0.15),
            child: Icon(Icons.person, size: 40, color: AppTheme.primaryGreen),
          ),
          const SizedBox(height: 16),
          Text(auth.user?.name ?? 'User', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(auth.user?.email ?? '', style: const TextStyle(fontSize: 14, color: Colors.white54)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryCyan.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  auth.user?.role ?? 'Consumer',
                  style: const TextStyle(color: AppTheme.primaryCyan, fontWeight: FontWeight.w600),
                ),
              ),
              if (auth.isGuestMode) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryYellow.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primaryYellow.withOpacity(0.5)),
                  ),
                  child: const Text(
                    'Guest Mode',
                    style: TextStyle(color: AppTheme.primaryYellow, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 32),
          Row(children: [
            _buildStatCard('Carbon Saved', '86.1 kg', AppTheme.primaryGreen),
            const SizedBox(width: 12),
            _buildStatCard('Devices', '4', AppTheme.primaryCyan),
            const SizedBox(width: 12),
            _buildStatCard('Eco Points', '340', AppTheme.primaryYellow),
          ]),
          const SizedBox(height: 24),
          _buildMenuTile(Icons.person_outline, 'Edit Profile'),
          _buildMenuTile(Icons.settings_outlined, 'App Settings'),
          _buildMenuTile(Icons.notifications_outlined, 'Notification Preferences'),
          _buildMenuTile(Icons.help_outline, 'Help & Support'),
          _buildMenuTile(Icons.info_outline, 'About CarbonWise'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryRed,
                side: const BorderSide(color: AppTheme.primaryRed),
              ),
              child: Text(auth.isGuestMode ? 'Exit Guest Mode' : 'Logout'),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) => Expanded(
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.white54)),
          ],
        ),
      ),
    ),
  );

  Widget _buildMenuTile(IconData icon, String label) => ListTile(
    leading: Icon(icon, color: Colors.white54),
    title: Text(label),
    trailing: const Icon(Icons.chevron_right, color: Colors.white54),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    onTap: () {},
  );
}

