import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as dev;

class ProfileRepository {
  final _client = Supabase.instance.client;

  Future<void> updateUserRole(String userId, String role) async {
    dev.log('Updating user role: $userId to $role');
    await _client
        .from('profiles')
        .update({'role': role})
        .eq('id', userId);
    dev.log('User role updated successfully');
  }

  Future<void> updateProfile({
    required String userId,
    required String name,
    required String bio,
  }) async {
    dev.log('Updating profile for user $userId: name=$name, bio=$bio');
    try {
      final data = {
        'name': name,
        'bio': bio,
      };
      
      final response = await _client
          .from('profiles')
          .update(data)
          .eq('id', userId)
          .select();
          
      dev.log('Profile updated successfully: $response');
    } catch (e) {
      dev.log('Error updating profile: $e');
      rethrow;
    }
  }
} 