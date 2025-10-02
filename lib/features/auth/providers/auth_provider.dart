import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/user_model.dart';
import '../data/user_repository.dart';
import 'dart:developer' as dev;

final userRepositoryProvider = Provider((ref) => UserRepository());

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final Ref ref;
  AuthNotifier(this.ref) : super(const AsyncValue.loading()) {
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final repo = ref.read(userRepositoryProvider);
    state = const AsyncValue.loading();
    try {
      final user = await repo.currentUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      dev.log('Error loading current user: $e');
      state = AsyncValue.error(e, st);
    }
  }

  // Reset error state to prevent error screens
  void resetError() {
    if (state is AsyncError) {
      dev.log('Resetting auth error state');
      state = const AsyncValue.data(null);
    }
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      dev.log('Attempting sign in for email: $email');
      final res = await Supabase.instance.client.auth.signInWithPassword(email: email, password: password);
      
      if (res.user == null) {
        dev.log('Sign in failed: No user returned');
        throw Exception('Invalid login credentials');
      }
      
      // Ensure user row exists in users table
      final repo = ref.read(userRepositoryProvider);
      final userId = res.user!.id;
      dev.log('User signed in successfully. User ID: $userId');
      
      final userRow = await repo.getUserById(userId);
      if (userRow == null) {
        dev.log('Creating new user profile for first-time sign-in');
        await repo.createUser(UserModel(
          id: userId,
          name: res.user!.userMetadata?['name'] ?? res.user!.email?.split('@').first ?? 'User',
          role: 'learner',
          createdAt: DateTime.now(),
        ));
      } else {
        dev.log('User profile exists: ${userRow.name}');
      }
      
      await _loadCurrentUser();
    } catch (e, st) {
      dev.log('Sign in error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signUp(String email, String password, String name) async {
    state = const AsyncValue.loading();
    try {
      dev.log('Attempting sign up for email: $email');
      
      // Configure email confirmation
      final res = await Supabase.instance.client.auth.signUp(
        email: email, 
        password: password, 
        data: {'name': name},
        emailRedirectTo: 'https://quickcore.app/auth/callback', // Replace with your actual redirect URL
      );
      
      if (res.user == null) {
        dev.log('Sign up failed: No user returned');
        throw Exception('Failed to create account');
      }
      
      dev.log('Sign up successful. Email verification sent to: $email');
      
      // For a proper sign-up flow, we don't load the current user yet
      // The user needs to verify their email first
      state = const AsyncValue.data(null);
      
      // Return without error to indicate successful signup
      // The UI will show a message about email verification
    } catch (e, st) {
      dev.log('Sign up error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    try {
      dev.log('Signing out user');
      await Supabase.instance.client.auth.signOut();
      state = const AsyncValue.data(null);
    } catch (e) {
      dev.log('Error signing out: $e');
      // Still set state to null even if there's an error
      state = const AsyncValue.data(null);
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final repo = ref.read(userRepositoryProvider);
    final user = state.value;
    if (user == null) {
      dev.log('Cannot update profile: No user logged in');
      return;
    }
    
    try {
      dev.log('Updating profile for user ${user.id}: $data');
      final updated = await repo.updateUser(user.id, data);
      state = AsyncValue.data(updated);
      dev.log('Profile updated successfully');
    } catch (e, st) {
      dev.log('Error updating profile: $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> reloadUser() async {
    dev.log('Reloading user data');
    await _loadCurrentUser();
  }
} 