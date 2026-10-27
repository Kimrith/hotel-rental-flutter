import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';
import 'routes/app.route.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await AppTheme.init();
  await AuthService().init();
  runApp(const HotelRentalApp());
}

class HotelRentalApp extends StatelessWidget {
  const HotelRentalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeModeNotifier,
      builder: (context, currentThemeMode, child) {
        return MaterialApp(
          title: 'Obsidian Hotel Rentals',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentThemeMode,
          routes: routes,
          initialRoute: '/splash',
        );
      },
    );
  }
}
