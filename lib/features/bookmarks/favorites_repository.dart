import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritesRepository {
  final _client = Supabase.instance.client;

  Future<bool> isFavorited(String userId, String skillId) async {
    final res = await _client
        .from('favorites')
        .select()
        .eq('user_id', userId)
        .eq('skill_id', skillId)
        .maybeSingle();
    return res != null;
  }

  Future<void> addFavorite(String userId, String skillId) async {
    await _client.from('favorites').insert({
      'user_id': userId,
      'skill_id': skillId,
      'saved_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> removeFavorite(String userId, String skillId) async {
    await _client
        .from('favorites')
        .delete()
        .eq('user_id', userId)
        .eq('skill_id', skillId);
  }

  Future<List<Map<String, dynamic>>> getFavorites(String userId) async {
    final res = await _client
        .from('favorites')
        .select('skill_id, skills(*)')
        .eq('user_id', userId)
        .order('saved_at', ascending: false);
    return List<Map<String, dynamic>>.from(res);
  }
} 