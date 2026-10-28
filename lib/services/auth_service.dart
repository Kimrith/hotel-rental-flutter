import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../theme/app_theme.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _keyIsLoggedIn = 'auth_is_logged_in';
  static const String _keyUserId = 'auth_user_id';
  static const String _keyUserName = 'auth_user_name';
  static const String _keyUserEmail = 'auth_user_email';
  static const String _keyUserPhone = 'auth_user_phone';
  static const String _keyUserMembership = 'auth_user_membership';
  static const String _keyUserAvatar = 'auth_user_avatar';
  static const String _keySavedAccounts = 'auth_saved_accounts';

  static const String defaultAvatar =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200';

  bool _isLoggedIn = false;
  int _userId = 1;
  String _userName = 'Guest User';
  String _userEmail = '';
  String _userPhone = '';
  String _membership = 'Gold Member';
  String _avatarUrl = defaultAvatar;

  final ValueNotifier<bool> authStateNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<int> profileUpdateNotifier = ValueNotifier<int>(0);

  bool get isLoggedIn => _isLoggedIn;
  int get userId => _userId;
  String get userName => _userName;
  String get userEmail => _userEmail;
  String get userPhone => _userPhone;
  String get membership => _membership;
  String get avatarUrl => _avatarUrl;

  /// Initialize auth state from SharedPreferences
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
      _userId = prefs.getInt(_keyUserId) ?? 1;
      _userName = prefs.getString(_keyUserName) ?? (_isLoggedIn ? 'Sophia Anders' : 'Guest User');
      _userEmail = prefs.getString(_keyUserEmail) ?? (_isLoggedIn ? 'sophia.anders@example.com' : '');
      _userPhone = prefs.getString(_keyUserPhone) ?? (_isLoggedIn ? '+1 (555) 019-2834' : '');
      _membership = prefs.getString(_keyUserMembership) ?? 'Gold Member';
      _avatarUrl = prefs.getString(_keyUserAvatar) ?? defaultAvatar;
      authStateNotifier.value = _isLoggedIn;
    } catch (_) {
      _isLoggedIn = false;
    }
  }

  /// Perform login and persist state
  Future<void> login({
    required String email,
    String? password,
    String? name,
    String? phone,
    int? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check saved accounts for stored details of this user
    Map<String, dynamic> savedAccounts = {};
    try {
      final rawAccounts = prefs.getString(_keySavedAccounts);
      if (rawAccounts != null && rawAccounts.isNotEmpty) {
        savedAccounts = jsonDecode(rawAccounts) as Map<String, dynamic>;
      }
    } catch (_) {}

    final userKey = email.trim().toLowerCase();
    Map<String, dynamic>? savedProfile;
    if (savedAccounts.containsKey(userKey)) {
      savedProfile = Map<String, dynamic>.from(savedAccounts[userKey] as Map);
    }

    _isLoggedIn = true;
    _userId = userId ?? (savedProfile != null ? (savedProfile['id'] as num?)?.toInt() ?? 1 : 1);
    _userEmail = email.trim();

    // Determine user name
    if (name != null && name.trim().isNotEmpty) {
      _userName = name.trim();
    } else if (savedProfile != null && savedProfile['name'] != null && savedProfile['name'].toString().isNotEmpty) {
      _userName = savedProfile['name'].toString();
    } else {
      _userName = email.contains('@') ? email.split('@').first : 'User';
    }

    // Determine phone number
    if (phone != null && phone.trim().isNotEmpty) {
      _userPhone = phone.trim();
    } else if (savedProfile != null && savedProfile['phone'] != null && savedProfile['phone'].toString().isNotEmpty) {
      _userPhone = savedProfile['phone'].toString();
    } else {
      _userPhone = '+1 (555) 019-2834';
    }

    // Determine membership and avatar
    _membership = (savedProfile != null && savedProfile['membership'] != null)
        ? savedProfile['membership'].toString()
        : 'Gold Member';

    _avatarUrl = (savedProfile != null && savedProfile['avatarUrl'] != null && savedProfile['avatarUrl'].toString().isNotEmpty)
        ? savedProfile['avatarUrl'].toString()
        : defaultAvatar;

    // Attempt backend login if online
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.userLogin),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': email.trim(),
          'password': password ?? 'Password@123',
        }),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['user'] != null) {
          final u = data['user'];
          if (u['id'] != null) _userId = (u['id'] as num).toInt();
          if (u['username'] != null && u['username'].toString().isNotEmpty) {
            _userName = u['username'].toString();
          }
          if (u['phoneNumber'] != null && u['phoneNumber'].toString().isNotEmpty) {
            _userPhone = u['phoneNumber'].toString();
          }
        }
      }
    } catch (_) {
      // Continue gracefully with local state
    }

    // Save in SharedPreferences
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setInt(_keyUserId, _userId);
    await prefs.setString(_keyUserName, _userName);
    await prefs.setString(_keyUserEmail, _userEmail);
    await prefs.setString(_keyUserPhone, _userPhone);
    await prefs.setString(_keyUserMembership, _membership);
    await prefs.setString(_keyUserAvatar, _avatarUrl);

    // Save/Update in savedAccounts table
    savedAccounts[userKey] = {
      'id': _userId,
      'name': _userName,
      'email': _userEmail,
      'phone': _userPhone,
      'membership': _membership,
      'avatarUrl': _avatarUrl,
    };
    await prefs.setString(_keySavedAccounts, jsonEncode(savedAccounts));

    authStateNotifier.value = true;
    profileUpdateNotifier.value++;
  }

  /// Perform registration and persist state
  Future<void> register({
    required String name,
    required String email,
    String? phone,
    String? password,
    int? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final userKey = email.trim().toLowerCase();
    final cleanPhone = (phone != null && phone.trim().isNotEmpty) ? phone.trim() : '+1 (555) 019-2834';

    // Attempt backend register if online
    int assignedId = userId ?? 1;
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.userRegister),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': name.trim(),
          'email': email.trim(),
          'password': password ?? 'Password@123',
          'role': 'CUSTOMER',
          'phoneNumber': cleanPhone,
        }),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data['user'] != null && data['user']['id'] != null) {
          assignedId = (data['user']['id'] as num).toInt();
        }
      }
    } catch (_) {
      // Offline fallback
    }

    // Pre-record account details
    Map<String, dynamic> savedAccounts = {};
    try {
      final rawAccounts = prefs.getString(_keySavedAccounts);
      if (rawAccounts != null && rawAccounts.isNotEmpty) {
        savedAccounts = jsonDecode(rawAccounts) as Map<String, dynamic>;
      }
    } catch (_) {}

    savedAccounts[userKey] = {
      'id': assignedId,
      'name': name.trim(),
      'email': email.trim(),
      'phone': cleanPhone,
      'membership': 'Gold Member',
      'avatarUrl': defaultAvatar,
    };
    await prefs.setString(_keySavedAccounts, jsonEncode(savedAccounts));

    await login(
      email: email,
      name: name,
      phone: cleanPhone,
      userId: assignedId,
    );
  }

  /// Update personal details and persist state across app
  Future<void> updatePersonalDetails({
    required String name,
    required String email,
    required String phone,
    String? avatarUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    _userName = name.trim();
    _userEmail = email.trim();
    _userPhone = phone.trim();
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      _avatarUrl = avatarUrl;
    }

    await prefs.setString(_keyUserName, _userName);
    await prefs.setString(_keyUserEmail, _userEmail);
    await prefs.setString(_keyUserPhone, _userPhone);
    await prefs.setString(_keyUserAvatar, _avatarUrl);

    // Also update saved accounts map
    try {
      final rawAccounts = prefs.getString(_keySavedAccounts);
      Map<String, dynamic> savedAccounts = {};
      if (rawAccounts != null && rawAccounts.isNotEmpty) {
        savedAccounts = jsonDecode(rawAccounts) as Map<String, dynamic>;
      }
      final userKey = _userEmail.toLowerCase();
      savedAccounts[userKey] = {
        'id': _userId,
        'name': _userName,
        'email': _userEmail,
        'phone': _userPhone,
        'membership': _membership,
        'avatarUrl': _avatarUrl,
      };
      await prefs.setString(_keySavedAccounts, jsonEncode(savedAccounts));
    } catch (_) {}

    profileUpdateNotifier.value++;
  }

  /// Log out and clear persisted credentials
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = false;
    _userId = 1;
    _userName = 'Guest User';
    _userEmail = '';
    _userPhone = '';
    _membership = 'Guest Account';
    _avatarUrl = defaultAvatar;

    await prefs.setBool(_keyIsLoggedIn, false);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserPhone);
    await prefs.remove(_keyUserMembership);
    await prefs.remove(_keyUserAvatar);

    authStateNotifier.value = false;
    profileUpdateNotifier.value++;
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
