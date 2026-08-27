import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../auth/login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _darkModeEnabled = AppTheme.themeModeNotifier.value == ThemeMode.dark;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Profile Header Card
              _buildProfileHeader(),
              const SizedBox(height: 28),
              // Stats Block
              _buildStatsBlock(),
              const SizedBox(height: 28),
              // Settings Groups
              _buildSettingsList(),
              const SizedBox(height: 100), // padding for bottom bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        // Avatar stack with edit pen
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 4),
                boxShadow: AppTheme.softShadow,
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.edit_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Sophia Anders',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7), // Amber 100
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.stars_rounded, color: AppTheme.accent, size: 14),
              SizedBox(width: 4),
              Text(
                'Gold Member',
                style: TextStyle(
                  color: Color(0xFF92400E), // Amber 800
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsBlock() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatCard('18', 'Trips'),
          _buildStatCard('5', 'Reviews'),
          _buildStatCard('3 yrs', 'Member'),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsList() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              'Account & App Info',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.textMuted,
              ),
            ),
          ),
          _buildSettingTile(Icons.person_outline_rounded, 'Personal Details', null),
          _buildSettingTile(Icons.payment_rounded, 'Payments & Payouts', null),
          Divider(color: AppTheme.border, indent: 20, endIndent: 20),
          _buildSettingTile(
            Icons.notifications_none_rounded,
            'Push Notifications',
            Switch(
              value: _notificationsEnabled,
              activeColor: AppTheme.primary,
              onChanged: (val) {
                setState(() {
                  _notificationsEnabled = val;
                });
              },
            ),
          ),
          _buildSettingTile(
            Icons.dark_mode_outlined,
            'Dark Mode',
            Switch(
              value: _darkModeEnabled,
              activeColor: AppTheme.primary,
              onChanged: (val) {
                setState(() {
                  _darkModeEnabled = val;
                  AppTheme.themeModeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
                });
              },
            ),
          ),
          Divider(color: AppTheme.border, indent: 20, endIndent: 20),
          _buildSettingTile(Icons.help_outline_rounded, 'Help Center', null),
          _buildSettingTile(Icons.info_outline_rounded, 'Privacy Policy', null),
          _buildSettingTile(Icons.login_outlined, 'Log in', null),
        ],
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, Widget? trailing) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: AppTheme.textDark,
        ),
      ),
      trailing: trailing ?? Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted),
      onTap: trailing == null
          ? () {
              if (title == 'Log in') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Clicked: $title'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            }
          : null,
    );
  }
}
