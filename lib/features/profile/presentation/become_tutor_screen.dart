import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickcore/features/auth/data/user_model.dart';
import 'package:quickcore/features/profile/providers/profile_providers.dart';

class BecomeTutorScreen extends ConsumerStatefulWidget {
  final UserModel user;
  
  static const String route = '/become-tutor';
  
  const BecomeTutorScreen({super.key, required this.user});

  @override
  ConsumerState<BecomeTutorScreen> createState() => _BecomeTutorScreenState();
}

class _BecomeTutorScreenState extends ConsumerState<BecomeTutorScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _specializationController = TextEditingController();
  final _qualificationsController = TextEditingController();
  String? _selectedEducationLevel;
  bool _agreedToTerms = false;
  bool _isSubmitting = false;
  
  final List<String> _educationLevels = [
    'High School',
    'Associate Degree',
    'Bachelor\'s Degree',
    'Master\'s Degree',
    'PhD',
    'Self-taught Professional',
  ];

  @override
  void dispose() {
    _specializationController.dispose();
    _qualificationsController.dispose();
    super.dispose();
  }

  void _submitApplication() async {
    if (!_formKey.currentState!.validate() || !_agreedToTerms) {
      if (!_agreedToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please agree to the terms and conditions')),
        );
      }
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      // Update user role to 'tutor'
      await ref.read(profileNotifierProvider.notifier).updateUserRole(
        widget.user.id,
        'tutor',
      );
      
      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Congratulations! You are now a tutor.'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Navigate back to the profile page
        context.pop();
      }
    } catch (e) {
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Become a Tutor'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Icon(
                  Icons.school,
                  size: 64,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Share Your Knowledge',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'As a tutor, you\'ll be able to create and share educational content with learners worldwide.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Education Level
              const Text(
                'Education Level',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedEducationLevel,
                decoration: const InputDecoration(
                  hintText: 'Select your highest education level',
                  border: OutlineInputBorder(),
                ),
                items: _educationLevels.map((level) {
                  return DropdownMenuItem<String>(
                    value: level,
                    child: Text(level),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedEducationLevel = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your education level';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Specialization
              const Text(
                'Area of Expertise',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _specializationController,
                decoration: const InputDecoration(
                  hintText: 'E.g., Mathematics, Programming, Languages',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your area of expertise';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Qualifications
              const Text(
                'Relevant Qualifications',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _qualificationsController,
                decoration: const InputDecoration(
                  hintText: 'Describe your experience and qualifications',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your qualifications';
                  }
                  if (value.length < 20) {
                    return 'Please provide more details about your qualifications';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              
              // Terms and Conditions
              Row(
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    onChanged: (value) {
                      setState(() {
                        _agreedToTerms = value ?? false;
                      });
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _agreedToTerms = !_agreedToTerms;
                        });
                      },
                      child: const Text(
                        'I agree to follow QuickCore\'s content guidelines and terms of service for tutors',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitApplication,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'BECOME A TUTOR',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 