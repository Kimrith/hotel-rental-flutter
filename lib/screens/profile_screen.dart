import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

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
        child: ValueListenableBuilder<bool>(
          valueListenable: AuthService().authStateNotifier,
          builder: (context, isLoggedIn, _) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Profile Header Card
                  _buildProfileHeader(isLoggedIn),
                  const SizedBox(height: 28),
                  // Stats Block
                  _buildStatsBlock(),
                  const SizedBox(height: 28),
                  // Settings Groups
                  _buildSettingsList(isLoggedIn),
                  const SizedBox(height: 100), // padding for bottom bar
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isLoggedIn) {
    final name = isLoggedIn ? AuthService().userName : 'Guest User';
    final email = isLoggedIn ? AuthService().userEmail : 'Sign in to access all features';

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
                color: isLoggedIn ? null : AppTheme.primaryLight,
                image: isLoggedIn
                    ? const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200'),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: isLoggedIn
                  ? null
                  : Icon(Icons.person_outline_rounded, size: 50, color: AppTheme.primary),
            ),
            if (isLoggedIn)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 4),
        if (email.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              email,
              style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isLoggedIn ? const Color(0xFFFEF3C7) : AppTheme.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: isLoggedIn ? null : Border.all(color: AppTheme.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLoggedIn ? Icons.stars_rounded : Icons.info_outline_rounded,
                color: isLoggedIn ? AppTheme.accent : AppTheme.textMuted,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                isLoggedIn ? 'Verified Member' : 'Guest Account',
                style: TextStyle(
                  color: isLoggedIn ? const Color(0xFF92400E) : AppTheme.textMuted,
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
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF334155)
                : const Color(0xFFE2E8F0),
          ),
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

  Widget _buildSettingsList(bool isLoggedIn) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF334155)
              : const Color(0xFFE2E8F0),
        ),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Text(
              'Account & App Info',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppTheme.textMuted,
              ),
            ),
          ),
          if (isLoggedIn) ...[
            _buildSettingTile(Icons.person_outline_rounded, 'Personal Details', null),
            _buildSettingTile(Icons.payment_rounded, 'Payments & Payouts', null),
            Divider(color: AppTheme.border, indent: 20, endIndent: 20),
          ],
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
                  AppTheme.updateThemeMode(val);
                });
              },
            ),
          ),
          Divider(color: AppTheme.border, indent: 20, endIndent: 20),
          _buildSettingTile(Icons.help_outline_rounded, 'Help Center', null),
          _buildSettingTile(Icons.info_outline_rounded, 'Privacy Policy', null),
          if (isLoggedIn)
            _buildSettingTile(
              Icons.logout_rounded,
              'Log out',
              null,
              color: Colors.red.shade600,
            )
          else
            _buildSettingTile(Icons.login_outlined, 'Log in / Register', null),
        ],
      ),
    );
  }

  Widget _buildSettingTile(
    IconData icon,
    String title,
    Widget? trailing, {
    Color? color,
  }) {
    final effectiveColor = color ?? AppTheme.textDark;
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color != null ? color.withOpacity(0.12) : AppTheme.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color ?? AppTheme.primary, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: effectiveColor,
        ),
      ),
      trailing: trailing ??
          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted),
      onTap: trailing == null
          ? () async {
              if (title == 'Log in / Register') {
                await Navigator.pushNamed(context, '/login');
              } else if (title == 'Log out') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Log out'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Log out'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await AuthService().logout();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Logged out successfully.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              } else if (title == 'Personal Details') {
                Navigator.pushNamed(context, '/personal-details');
              } else if (title == 'Payments & Payouts') {
                Navigator.pushNamed(context, '/payments');
              } else if (title == "Help Center") {
                Navigator.pushNamed(context, '/help-center');
              } else if (title == "Privacy Policy") {
                Navigator.pushNamed(context, '/privacy-policy');
              }
            }
          : null,
    );
  }
}