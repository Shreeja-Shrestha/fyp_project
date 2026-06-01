import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fyp_project/splash.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_links/app_links.dart';

import 'package:fyp_project/admin_dashboard.dart';
import 'package:fyp_project/login.dart';
import 'package:fyp_project/home.dart';
import 'package:fyp_project/booking_success_page.dart';

ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final bool isDark = prefs.getBool("dark_mode") ?? false;

  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  @override
  void initState() {
    super.initState();
    _handleDeepLinks();
  }

  void _handleDeepLinks() {
    _appLinks.getInitialLink().then((uri) {
      if (uri != null) {
        _openDeepLink(uri);
      }
    });

    _sub = _appLinks.uriLinkStream.listen((uri) {
      _openDeepLink(uri);
    });
  }

  void _openDeepLink(Uri uri) {
    if (uri.scheme == 'fypapp' && uri.host == 'booking-success') {
      final bookingId = uri.queryParameters['booking_id'] ?? "0";

      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (_) => BookingSuccessPage(bookingId: bookingId),
        ),
      );
    }
  }

  Future<Widget> _getStartScreen() async {
    final prefs = await SharedPreferences.getInstance();

    final bool rememberMe = prefs.getBool("remember_me") ?? false;
    final String? token = prefs.getString("token");
    final String role = prefs.getString("user_role") ?? "user";

    await Future.delayed(const Duration(seconds: 2));

    if (rememberMe && token != null && token.isNotEmpty) {
      if (role == "admin") {
        return const AdminDashboardPage();
      } else {
        return const HomePage();
      }
    }

    return const LoginPage();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: themeNotifier,
      builder: (context, ThemeMode currentMode, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Travel App',

          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xff1a73e8),
            ),
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.black,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xff1a73e8),
              brightness: Brightness.dark,
            ),
          ),

          themeMode: currentMode,

          home: FutureBuilder<Widget>(
            future: _getStartScreen(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              }

              if (snapshot.hasData) {
                return snapshot.data!;
              }

              return const LoginPage();
            },
          ),

          routes: {
            '/login': (context) => const LoginPage(),
            '/home': (context) => const HomePage(),
            '/admin-dashboard': (context) => const AdminDashboardPage(),
          },
        );
      },
    );
  }
}
