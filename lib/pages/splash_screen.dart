// lib/pages/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Constants
  static const double _logoSize = 100.0;
  static const double _titleSize = 48.0;
  static const double _spacing = 24.0;
  static const Duration _splashDuration = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _checkUserAndNavigate();
  }

  // Check user authentication status and navigate accordingly
  Future<void> _checkUserAndNavigate() async {
    await Future.delayed(_splashDuration);

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    _navigateToNextScreen(user != null);
  }

  // Navigation helper
  void _navigateToNextScreen(bool isAuthenticated) {
    Navigator.of(context).pushReplacementNamed(
      isAuthenticated ? '/home' : '/login',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[800],
      body: _buildSplashContent(),
    );
  }

  // Main splash screen content
  Widget _buildSplashContent() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LogoSection(),
          SizedBox(height: _spacing),
          _TitleSection(),
          SizedBox(height: _spacing),
          _LoadingIndicator(),
        ],
      ),
    );
  }
}

// Logo section widget
class _LogoSection extends StatelessWidget {
  const _LogoSection();

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.fitness_center,
      size: _SplashScreenState._logoSize,
      color: Colors.white,
    );
  }
}

// Title section widget
class _TitleSection extends StatelessWidget {
  const _TitleSection();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'SLINK',
      style: TextStyle(
        fontSize: _SplashScreenState._titleSize,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 4,
      ),
    );
  }
}

// Loading indicator widget
class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
    );
  }
}
