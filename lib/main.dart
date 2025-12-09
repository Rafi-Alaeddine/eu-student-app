// lib/main.dart
import 'package:dentistify/core/theme/app_theme.dart';
import 'package:dentistify/pages/menu/contact_us_page.dart';
import 'package:dentistify/pages/menu/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'core/constants/app_colors.dart';
import 'pages/auth/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  MapboxOptions.setAccessToken(dotenv.env['MAPBOX_ACCESS_TOKEN']!);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeNotifier.isDarkMode,
      builder: (context, isDark, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'EU Student Connect',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: const LoginPage(),
          routes: {
            '/profile': (context) => const ProfileSection(),
            '/settings': (context) => const Placeholder(),
            '/darkMode': (context) => const Placeholder(),
            '/contactUs': (context) => const ContactUsPage(),
          },
        );
      },
    );
  }
}

class ThemeNotifier {
  static final ValueNotifier<bool> isDarkMode = ValueNotifier<bool>(false);

  static void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
  }
}
