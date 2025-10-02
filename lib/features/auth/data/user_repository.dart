import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_model.dart';
import 'dart:io';
import 'dart:developer' as dev;

class UserRepository {
  final _client = Supabase.instance.client;
  
  // The table name should be consistent across all methods
  final _tableName = 'profiles';

  Future<UserModel?> getUserById(String userId) async {
    dev.log('Fetching user with ID: $userId from $_tableName');
    final res = await _client
        .from(_tableName)
        .select()
        .eq('id', userId)
        .maybeSingle();
    
    if (res == null) {
      dev.log('No user found with ID: $userId');
      return null;
    }
    
    final user = UserModel.fromJson(res);
    dev.log('User found: ${user.name}, role: ${user.role}');
    return user;
  }

  Future<UserModel?> currentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    return getUserById(user.id);
  }

  Future<UserModel> createUser(UserModel user) async {
    dev.log('Creating user in $_tableName: ${user.id}, role: ${user.role}');
    final res = await _client
        .from(_tableName)
        .insert(user.toJson())
        .select()
        .single();
    return UserModel.fromJson(res);
  }

  Future<UserModel> updateUser(String id, Map<String, dynamic> data) async {
    dev.log('Updating user in $_tableName: $id, data: $data');
    final res = await _client
        .from(_tableName)
        .update(data)
        .eq('id', id)
        .select()
        .single();
    final user = UserModel.fromJson(res);
    dev.log('User updated: ${user.name}, role: ${user.role}');
    return user;
  }

  Future<bool> isUsernameUnique(String username) async {
    try {
      dev.log('Checking if username is unique: $username');
      // Instead of using RPC, directly query the database
      final result = await _client
          .from(_tableName)
          .select('username')
          .eq('username', username)
          .maybeSingle();
      
      // If no result found, the username is unique
      final isUnique = result == null;
      dev.log('Username $username is ${isUnique ? "unique" : "already taken"}');
      return isUnique;
    } catch (e) {
      dev.log('Error checking username uniqueness: $e');
      // Default to allowing the username if there's an error
      return true;
    }
  }

  Future<String> uploadAvatar(String userId, File file) async {
    final path = '/$userId/avatar';
    await _client.storage.from('avatars').upload(path, file);
    return _client.storage.from('avatars').getPublicUrl(path);
  }
} 