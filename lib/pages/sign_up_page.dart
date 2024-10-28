// lib/pages/sign_up_page.dart

import 'package:flutter/material.dart';
import '../service/auth_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Services and Controllers
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // State variables
  bool _isLoading = false;
  String _errorMessage = '';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Validation methods
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  // Sign up handler
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await _authService.registerWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  // UI Components
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.blue[800],
      title: const Text('Create Account'),
    );
  }

  Widget _buildBody() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 40),
              _buildEmailField(),
              const SizedBox(height: 20),
              _buildPasswordField(),
              const SizedBox(height: 20),
              _buildConfirmPasswordField(),
              const SizedBox(height: 30),
              _buildSignUpButton(),
              const SizedBox(height: 16),
              _buildSignInLink(),
              if (_errorMessage.isNotEmpty) ...[
                const SizedBox(height: 20),
                _buildErrorMessage(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Text(
      'Join Us!',
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Colors.blue[800],
            fontWeight: FontWeight.bold,
          ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration:
          _buildInputDecoration('Email', Icons.email, 'Enter your email'),
      keyboardType: TextInputType.emailAddress,
      validator: _validateEmail,
      enabled: !_isLoading,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: _buildPasswordDecoration(
        'Password',
        Icons.lock,
        'Enter your password',
        _obscurePassword,
        () => setState(() => _obscurePassword = !_obscurePassword),
      ),
      obscureText: _obscurePassword,
      validator: _validatePassword,
      enabled: !_isLoading,
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      decoration: _buildPasswordDecoration(
        'Confirm Password',
        Icons.lock_outline,
        'Confirm your password',
        _obscureConfirmPassword,
        () =>
            setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
      ),
      obscureText: _obscureConfirmPassword,
      validator: _validateConfirmPassword,
      enabled: !_isLoading,
    );
  }

  Widget _buildSignUpButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _signUp,
      style: _buildButtonStyle(),
      child: _isLoading
          ? _buildLoadingIndicator()
          : _buildButtonText('Create Account'),
    );
  }

  Widget _buildSignInLink() {
    return TextButton(
      onPressed: _isLoading ? null : () => Navigator.pop(context),
      child: Text(
        'Already have an account? Sign In',
        style: TextStyle(color: Colors.blue[800]),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _errorMessage,
        style: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Helper methods
  InputDecoration _buildInputDecoration(
      String label, IconData icon, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.blue[800]),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: _buildInputBorder(1),
      focusedBorder: _buildInputBorder(2),
    );
  }

  InputDecoration _buildPasswordDecoration(
    String label,
    IconData icon,
    String hint,
    bool obscureText,
    VoidCallback onPressed,
  ) {
    return _buildInputDecoration(label, icon, hint).copyWith(
      suffixIcon: IconButton(
        icon: Icon(
          obscureText ? Icons.visibility_off : Icons.visibility,
          color: Colors.blue[800],
        ),
        onPressed: onPressed,
      ),
    );
  }

  OutlineInputBorder _buildInputBorder(double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.blue[800]!, width: width),
    );
  }

  ButtonStyle _buildButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.blue[800],
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      disabledBackgroundColor: Colors.blue[200],
    );
  }

  Widget _buildLoadingIndicator() {
    return const SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        strokeWidth: 2,
      ),
    );
  }

  Widget _buildButtonText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}
