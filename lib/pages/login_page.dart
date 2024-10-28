// lib/pages/login_page.dart

import 'package:flutter/material.dart';
import 'sign_in_page.dart';
import 'sign_up_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _buildMainContent(context),
        ),
      ),
    );
  }

  // Main content column
  Widget _buildMainContent(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // App title and welcome message
        _buildHeader(context),
        const SizedBox(height: 60),

        // Authentication buttons
        _buildAuthButtons(context),
        const SizedBox(height: 40),

        // Terms and conditions
        _buildTermsText(context),
      ],
    );
  }

  // Header section with app title and welcome message
  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // App title
        Text(
          'SLINK',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: Colors.blue[800],
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),

        // Welcome message
        Text(
          'Welcome to SLINK',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.grey[700],
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Authentication buttons section
  Widget _buildAuthButtons(BuildContext context) {
    return Column(
      children: [
        // Sign In button
        ElevatedButton(
          onPressed: () => _navigateToSignIn(context),
          style: _buildPrimaryButtonStyle(context),
          child: const Text(
            'Sign In',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Create Account button
        OutlinedButton(
          onPressed: () => _navigateToSignUp(context),
          style: _buildSecondaryButtonStyle(context),
          child: const Text(
            'Create Account',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // Terms and conditions text
  Widget _buildTermsText(BuildContext context) {
    return Text(
      'By continuing, you agree to our Terms of Service and Privacy Policy',
      style: TextStyle(
        color: Colors.grey[600],
        fontSize: 12,
      ),
      textAlign: TextAlign.center,
    );
  }

  // Primary button style (Filled button)
  ButtonStyle _buildPrimaryButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.blue[800],
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // Secondary button style (Outlined button)
  ButtonStyle _buildSecondaryButtonStyle(BuildContext context) {
    return OutlinedButton.styleFrom(
      side: BorderSide(color: Colors.blue[800]!),
      foregroundColor: Colors.blue[800],
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // Navigation methods
  void _navigateToSignIn(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
  }

  void _navigateToSignUp(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SignUpPage()),
    );
  }
}
