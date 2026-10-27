import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _keyIsLoggedIn = 'auth_is_logged_in';
  static const String _keyUserId = 'auth_user_id';
  static const String _keyUserName = 'auth_user_name';
  static const String _keyUserEmail = 'auth_user_email';

  bool _isLoggedIn = false;
  int _userId = 1;
  String _userName = 'Guest User';
  String _userEmail = '';

  final ValueNotifier<bool> authStateNotifier = ValueNotifier<bool>(false);

  bool get isLoggedIn => _isLoggedIn;
  int get userId => _userId;
  String get userName => _userName;
  String get userEmail => _userEmail;

  /// Initialize auth state from SharedPreferences
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
      _userId = prefs.getInt(_keyUserId) ?? 1;
      _userName = prefs.getString(_keyUserName) ?? (_isLoggedIn ? 'Sophia Anders' : 'Guest User');
      _userEmail = prefs.getString(_keyUserEmail) ?? (_isLoggedIn ? 'sophia@example.com' : '');
      authStateNotifier.value = _isLoggedIn;
    } catch (_) {
      _isLoggedIn = false;
    }
  }

  /// Perform login and persist state
  Future<void> login({
    required String email,
    String? name,
    int? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = true;
    _userId = userId ?? 1;
    _userEmail = email;
    _userName = (name != null && name.isNotEmpty)
        ? name
        : (email.contains('@') ? email.split('@').first : 'User');

    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setInt(_keyUserId, _userId);
    await prefs.setString(_keyUserName, _userName);
    await prefs.setString(_keyUserEmail, _userEmail);

    authStateNotifier.value = true;
  }

  /// Perform registration and persist state
  Future<void> register({
    required String name,
    required String email,
    int? userId,
  }) async {
    await login(email: email, name: name, userId: userId);
  }

  /// Log out and clear persisted credentials
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = false;
    _userId = 1;
    _userName = 'Guest User';
    _userEmail = '';

    await prefs.setBool(_keyIsLoggedIn, false);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);

    authStateNotifier.value = false;
  }

  /// Checks if user is authenticated. If not, shows an elegant modal requiring login/register.
  /// Returns `true` if the user is already authenticated or just logged in, `false` otherwise.
  Future<bool> requireAuth(
    BuildContext context, {
    String action = 'continue',
  }) async {
    if (_isLoggedIn) {
      return true;
    }

    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(sheetContext).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            boxShadow: AppTheme.cardShadow,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                // Icon badge
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_person_rounded,
                    size: 32,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  'Account Required',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),

                // Message
                Text(
                  'Please sign in or create an account to $action.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textMuted,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Log In Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(sheetContext);
                      final loggedIn = await Navigator.pushNamed(context, '/login');
                      if (loggedIn == true && _isLoggedIn && context.mounted) {
                        FocusScope.of(context).unfocus();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Log In',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () async {
                      Navigator.pop(sheetContext);
                      await Navigator.pushNamed(context, '/register');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: BorderSide(color: AppTheme.primary, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Create New Account',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Dismiss Button
                TextButton(
                  onPressed: () => Navigator.pop(sheetContext, false),
                  child: Text(
                    'Maybe Later',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.textMuted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    return _isLoggedIn;
  }
}
