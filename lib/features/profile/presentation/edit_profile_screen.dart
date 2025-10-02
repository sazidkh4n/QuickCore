import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickcore/features/auth/data/user_model.dart';
import 'package:quickcore/features/auth/providers/auth_provider.dart';
import 'package:quickcore/features/profile/providers/profile_providers.dart';
import 'dart:developer' as dev;

class EditProfileScreen extends ConsumerStatefulWidget {
  final UserModel? user;
  
  const EditProfileScreen({super.key, this.user});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    final user = widget.user ?? ref.read(authProvider).value;
    dev.log('Initializing edit profile with user: ${user?.name ?? 'No name'}, id: ${user?.id}');
    _nameController = TextEditingController(text: user?.name ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }
  
  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final user = ref.read(authProvider).value;
    if (user == null) {
      setState(() {
        _errorMessage = 'User not found';
        _isLoading = false;
      });
      return;
    }
    
    final name = _nameController.text.trim();
    final bio = _bioController.text.trim();
    
    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Name cannot be empty';
        _isLoading = false;
      });
      return;
    }
    
    try {
      dev.log('Saving profile changes: name=$name, bio=$bio');
      
      await ref.read(profileNotifierProvider.notifier).updateProfile(
        userId: user.id,
        name: name,
        bio: bio,
      );
      
      // Force reload user data to ensure changes are reflected
      await ref.read(authProvider.notifier).reloadUser();
      
      dev.log('Profile updated successfully');
      setState(() {
        _successMessage = 'Profile updated successfully';
        _isLoading = false;
      });
      
      // Navigate back after a short delay to show success message
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.of(context).pop();
        }
      });
    } catch (e) {
      dev.log('Error updating profile: $e');
      setState(() {
        _errorMessage = 'Failed to update profile: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;
    if (user == null) return const Scaffold(body: Center(child: Text('User not found')));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          _isLoading 
            ? const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  height: 24, 
                  width: 24, 
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.check),
                onPressed: _saveProfile,
              ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Placeholder for avatar selection
            CircleAvatar(
              radius: 60,
              backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
              child: user.avatarUrl == null ? const Icon(Icons.person, size: 60) : null,
            ),
            TextButton(onPressed: () {}, child: const Text('Change Photo')),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (_successMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _successMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                helperText: 'Your display name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _bioController,
              decoration: const InputDecoration(
                labelText: 'Bio',
                border: OutlineInputBorder(),
                helperText: 'Tell others about yourself',
              ),
              maxLines: 3,
            ),
            const Divider(height: 48),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log Out'),
              onTap: () {
                ref.read(authProvider.notifier).signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
} 