import 'dart:io';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:quickcore/features/auth/providers/auth_provider.dart';

class CreateProfileScreen extends ConsumerStatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  ConsumerState<CreateProfileScreen> createState() =>
      _CreateProfileScreenState();
}

class _CreateProfileScreenState extends ConsumerState<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  File? _image;
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorText = null;
      });

      final user = ref.read(authProvider).value;
      if (user == null) {
        setState(() {
          _errorText = 'You must be logged in to create a profile.';
          _isLoading = false;
        });
        return;
      }

      final repo = ref.read(userRepositoryProvider);
      final username = _usernameController.text.trim();
      final name = _nameController.text.trim();

      try {
        dev.log('Starting profile creation for user: ${user.id}');
        
        // Check if username is unique
        dev.log('Checking if username is unique: $username');
        final isUnique = await repo.isUsernameUnique(username);
        
        if (!isUnique) {
          dev.log('Username already taken: $username');
          setState(() {
            _errorText = 'Username is already taken.';
            _isLoading = false;
          });
          return;
        }
        
        dev.log('Username is unique, proceeding with profile update');

        // Upload avatar if selected
        String? avatarUrl;
        if (_image != null) {
          try {
            dev.log('Uploading avatar image');
            avatarUrl = await repo.uploadAvatar(user.id, _image!);
            dev.log('Avatar uploaded successfully: $avatarUrl');
          } catch (e) {
            dev.log('Error uploading avatar: $e');
            // Continue even if avatar upload fails
          }
        }
        
        // Update user profile
        final updateData = {
          'username': username,
          'name': name,
          if (avatarUrl != null) 'avatar_url': avatarUrl,
        };
        
        dev.log('Updating user profile with data: $updateData');
        await repo.updateUser(user.id, updateData);
        
        dev.log('User profile updated successfully, reloading user data');
        // Reload user data after successful update
        await ref.read(authProvider.notifier).reloadUser();
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile created successfully!')),
          );
        }

      } catch (e) {
        dev.log('Error creating profile: $e');
        setState(() {
          _errorText = 'Error: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Your Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? const Icon(Icons.add_a_photo, size: 50)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  border: OutlineInputBorder(),
                  helperText: 'Your name as it will appear to others',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a display name.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: const OutlineInputBorder(),
                  errorText: _errorText,
                  helperText: 'Choose a unique username with at least 3 characters',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username.';
                  }
                  if (value.length < 3) {
                    return 'Username must be at least 3 characters.';
                  }
                  // Check if username contains only allowed characters
                  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                    return 'Username can only contain letters, numbers, and underscores.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                      child: const Text('Save Profile'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
} 