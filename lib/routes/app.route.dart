import 'package:flutter/material.dart';
import 'package:hotel_rental/auth/login.dart';
import 'package:hotel_rental/auth/register.dart';
import 'package:hotel_rental/screens/help_center_screen.dart';
import 'package:hotel_rental/screens/main_screen.dart';
import 'package:hotel_rental/screens/payments_screen.dart';
import 'package:hotel_rental/screens/personal_details_screen.dart';
import 'package:hotel_rental/screens/privacy_policy_screen.dart';
import 'package:hotel_rental/screens/profile_screen.dart';
import 'package:hotel_rental/screens/splash_screen.dart';

Map<String, WidgetBuilder> routes = {
  '/splash': (context) => const SplashScreen(),
  '/': (context) => const MainScreen(),
  '/login': (context) => const LoginScreen(),
  '/register': (context) => const RegisterScreen(),
  '/personal-details': (context) => const PersonalDetailsScreen(),
  '/payments': (context) => const PaymentsScreen(),
  '/help-center': (context) => const HelpCenterScreen(),
  '/privacy-policy': (context) => const PrivacyPolicyScreen(),
  '/profile': (context) => const ProfileScreen(),
};