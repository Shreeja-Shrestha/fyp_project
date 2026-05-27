import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fyp_project/login.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _floatingController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _mainController, curve: Curves.elasticOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.35), end: Offset.zero).animate(
          CurvedAnimation(parent: _mainController, curve: Curves.easeOutCubic),
        );

    _floatingAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    _mainController.forward();

    Timer(const Duration(seconds: 4), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF8FF),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFEAF8FF),
                  Color(0xFFFFFFFF),
                  Color(0xFFDFF7FF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Decorative circle top
          Positioned(
            top: -80,
            right: -70,
            child: Container(
              height: 220,
              width: 220,
              decoration: BoxDecoration(
                color: const Color(0xFF00B4D8).withOpacity(0.15),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Decorative circle bottom
          Positioned(
            bottom: -100,
            left: -90,
            child: Container(
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                color: const Color(0xFF90E0EF).withOpacity(0.22),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Small floating dots
          Positioned(
            top: 160,
            left: 40,
            child: _smallCircle(14, const Color(0xFF00B4D8).withOpacity(0.25)),
          ),
          Positioned(
            top: 260,
            right: 52,
            child: _smallCircle(10, const Color(0xFF0077B6).withOpacity(0.25)),
          ),
          Positioned(
            bottom: 190,
            right: 80,
            child: _smallCircle(18, const Color(0xFF90E0EF).withOpacity(0.5)),
          ),

          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _floatingAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _floatingAnimation.value),
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: child,
                            ),
                          );
                        },
                        child: _logoCard(),
                      ),

                      const SizedBox(height: 30),

                      const Text(
                        "Sanskriti Yatra",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF111827),
                          letterSpacing: 0.3,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        "Discover culture, nature, and journeys",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 38),

                      _loadingIndicator(),

                      const SizedBox(height: 18),

                      const Text(
                        "Preparing your travel experience...",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 28,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Column(
                children: const [
                  Text(
                    "Explore Nepal with ease",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _logoCard() {
    return Container(
      height: 145,
      width: 145,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00B4D8).withOpacity(0.25),
            blurRadius: 30,
            spreadRadius: 4,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.9), width: 2),
      ),
      child: Image.asset("assets/logo.png", fit: BoxFit.contain),
    );
  }

  Widget _loadingIndicator() {
    return SizedBox(
      width: 150,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: const LinearProgressIndicator(
          minHeight: 6,
          backgroundColor: Color(0xFFE0F7FA),
          color: Color(0xFF00B4D8),
        ),
      ),
    );
  }

  Widget _smallCircle(double size, Color color) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
