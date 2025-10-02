import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickcore/features/auth/providers/auth_provider.dart';
import 'dart:developer' as dev;

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    // Schedule this for after the first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForErrors();
    });
  }

  void _checkForErrors() {
    final authState = ref.read(authProvider);
    if (authState is AsyncError) {
      setState(() {
        _error = _getReadableErrorMessage(authState.error.toString());
      });
      // Reset the error state in the provider
      ref.read(authProvider.notifier).resetError();
    }
  }
  
  String _getReadableErrorMessage(String errorMessage) {
    dev.log('Auth error: $errorMessage');
    if (errorMessage.contains('Invalid login credentials') || 
        errorMessage.contains('Invalid_credentials') ||
        errorMessage.contains('invalid credentials')) {
      return 'Invalid email or password. Please check your credentials and try again.';
    } else if (errorMessage.contains('email')) {
      return 'Please enter a valid email address.';
    } else if (errorMessage.contains('password')) {
      return 'Please check your password and try again.';
    } else if (errorMessage.contains('network')) {
      return 'Network error. Please check your connection and try again.';
    } else {
      return 'An error occurred. Please try again later.';
    }
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _error = null;
      _isLoading = true;
    });
    
    try {
      await ref.read(authProvider.notifier).signIn(
            _emailController.text.trim(),
            _passwordController.text,
          );
      if (mounted) {
        final authState = ref.read(authProvider);
        if (authState is AsyncData && authState.value != null) {
          context.go('/feed');
        } else if (authState is AsyncError) {
          setState(() {
            _error = _getReadableErrorMessage(authState.error.toString());
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = _getReadableErrorMessage(e.toString());
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    
    // Handle auth state changes
    if (authState is AsyncError && _error == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _error = _getReadableErrorMessage(authState.error.toString());
          _isLoading = false;
        });
      });
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 50),
                // Enhanced Illustration
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_open_rounded,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Sign In',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Enter valid user name & password to continue',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    errorText: _error != null && _error!.contains('email') ? _error : null,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    errorText: _error != null && _error!.contains('password') ? _error : null,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      context.push('/forgot-password');
                    },
                    child: const Text('Forget password'),
                  ),
                ),
                const SizedBox(height: 20),
                if (_error != null && !_error!.contains('email') && !_error!.contains('password'))
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _error!,
                      style: TextStyle(color: Colors.red.shade800),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _isLoading ? null : _signIn,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Login', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 30),
                // "Or Continue with" divider
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('Or Continue with'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 30),
                // Social Login Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _socialButton(label: 'Google', isGoogle: true),
                    const SizedBox(width: 20),
                    _socialButton(label: 'Facebook', isGoogle: false),
                  ],
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Haven't any account?"),
                    TextButton(
                      onPressed: () {
                        context.push('/signUp');
                      },
                      child: const Text('Sign up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton({required String label, required bool isGoogle}) {
    // TODO: Replace with actual asset icons
    return OutlinedButton.icon(
      icon: Icon(isGoogle ? Icons.g_translate : Icons.facebook),
      onPressed: () {
        // TODO: Implement social login
      },
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
} 