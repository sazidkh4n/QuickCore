// Deprecated: Use favorites_repository.dart instead for all favorites/bookmarks logic.

import 'package:supabase_flutter/supabase_flutter.dart';
import '../feed/data/skill_model.dart';

class BookmarksRepository {
  final _client = Supabase.instance.client;
  SupabaseClient get client => _client;

  Future<List<SkillModel>> getBookmarks(String userId) async {
    final res = await _client
        .from('favorites')
        .select('skill_id, skills(*)')
        .eq('user_id', userId)
        .order('saved_at', ascending: false);
    
    List<SkillModel> bookmarks = [];
    for (final item in res) {
      if (item['skills'] != null) {
        bookmarks.add(SkillModel.fromJson(item['skills']));
      }
    }
    return bookmarks;
  }

  Future<void> toggleBookmark(String userId, String skillId) async {
    final isCurrentlyBookmarked = await isBookmarked(userId, skillId);
    
    if (isCurrentlyBookmarked) {
      await removeBookmark(userId, skillId);
    } else {
      await addBookmark(userId, skillId);
    }
  }

  Future<bool> isBookmarked(String userId, String skillId) async {
    final res = await _client
        .from('favorites')
        .select()
        .eq('user_id', userId)
        .eq('skill_id', skillId)
        .maybeSingle();
    return res != null;
  }

  Future<void> addBookmark(String userId, String skillId) async {
    await _client.from('favorites').insert({
      'user_id': userId,
      'skill_id': skillId,
      'saved_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> removeBookmark(String userId, String skillId) async {
    await _client
        .from('favorites')
        .delete()
        .eq('user_id', userId)
        .eq('skill_id', skillId);
  }
} 