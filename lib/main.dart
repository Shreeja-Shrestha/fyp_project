import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_links/app_links.dart';

import 'package:fyp_project/login.dart';
import 'package:fyp_project/booking_success_page.dart';

/// 🔥 GLOBAL THEME CONTROLLER
ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

/// 🔥 GLOBAL NAVIGATOR KEY (IMPORTANT FOR DEEP LINK)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  bool isDark = prefs.getBool("dark_mode") ?? false;

  /// LOAD SAVED THEME
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  runApp(const MyApp());
}

/// ✅ CONVERTED TO STATEFUL (for deep link handling)
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

    /// 🔥 HANDLE APP OPEN FROM CLOSED (IMPORTANT)
    _appLinks.getInitialLink().then((uri) {
      if (uri != null &&
          uri.scheme == 'fypapp' &&
          uri.host == 'booking-success') {
        final bookingId = uri.queryParameters['booking_id'];

        print("INITIAL DEEP LINK: $bookingId");

        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => BookingSuccessPage(bookingId: bookingId ?? "0"),
          ),
        );
      }
    });

    /// 🔥 HANDLE WHEN APP IS ALREADY OPEN
    _sub = _appLinks.uriLinkStream.listen((uri) {
      if (uri.scheme == 'fypapp' && uri.host == 'booking-success') {
        final bookingId = uri.queryParameters['booking_id'];

        print("STREAM DEEP LINK: $bookingId");

        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => BookingSuccessPage(bookingId: bookingId ?? "0"),
          ),
        );
      }
    });
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
          navigatorKey: navigatorKey, // 🔥 REQUIRED
          debugShowCheckedModeBanner: false,
          title: 'Travel App',

          /// LIGHT THEME
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: Colors.white,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xff1a73e8),
            ),
          ),

          /// DARK THEME
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: Colors.black,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xff1a73e8),
              brightness: Brightness.dark,
            ),
          ),

          /// APPLY THEME
          themeMode: currentMode,

          /// START SCREEN
          home: LoginPage(),
        );
      },
    );
  }
}
