import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quickcore/features/auth/data/user_model.dart';

class ExploreRepository {
  final _client = Supabase.instance.client;

  Future<List<String>> getCategories() async {
    try {
      final res = await _client.rpc('get_distinct_categories');
      return (res as List).map((e) => e['category'] as String).toList();
    } catch (e) {
      // Fallback to mock data if RPC fails
      return [
        'Technology',
        'Design',
        'Business',
        'Marketing',
        'Photography',
        'Music',
        'Fitness',
        'Cooking',
        'Education',
        'Art',
      ];
    }
  }

  Future<List<UserModel>> getTopCreators() async {
    try {
      final res = await _client.rpc('get_top_creators');
      return (res as List).map((e) => UserModel.fromJson(e)).toList();
    } catch (e) {
      // Fallback to regular query if RPC fails
      final res = await _client
          .from('profiles')
          .select()
          // .in_('role', ['creator', 'tutor'])
          /* TODO: Fix this method
           * The correct method is .in('role', ['creator', 'tutor']) without the underscore
           * This needs to be updated based on the version of the postgrest package
           */
          .order('created_at', ascending: false)
          .limit(20);
      return (res as List).map((e) => UserModel.fromJson(e)).toList();
    }
  }

  Future<List<Map<String, dynamic>>> getTrendingSkills() async {
    try {
      // Try to get trending skills based on views/likes
      final res = await _client
          .from('skills')
          .select()
          .order('view_count', ascending: false)
          .order('total_likes', ascending: false)
          .limit(10);
      return (res as List).map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      // Fallback to recent skills
      return getRecentSkills();
    }
  }

  Future<List<Map<String, dynamic>>> getFeaturedContent() async {
    try {
      // Get featured content (you might have a featured flag in your skills table)
      final res = await _client
          .from('skills')
          .select()
          .eq('is_featured', true)
          .order('created_at', ascending: false)
          .limit(5);

      if ((res as List).isEmpty) {
        // Fallback to popular content
        return getPopularSkills();
      }

      return (res as List).map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      // Fallback to popular content
      return getPopularSkills();
    }
  }

  Future<List<Map<String, dynamic>>> getRecentlyViewed() async {
    try {
      // This would typically come from user's viewing history
      // For now, return empty list or recent skills
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final res = await _client
          .from('user_skill_views')
          .select('skill_id, skills(*)')
          .eq('user_id', userId)
          .order('viewed_at', ascending: false)
          .limit(10);

      return (res as List)
          .map((e) => e['skills'] as Map<String, dynamic>)
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPopularSkills() async {
    try {
      final res = await _client
          .from('skills')
          .select()
          .order('total_likes', ascending: false)
          .order('view_count', ascending: false)
          .limit(20);
      return (res as List).map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      return getRecentSkills();
    }
  }

  Future<List<Map<String, dynamic>>> getRecentSkills() async {
    final res = await _client
        .from('skills')
        .select()
        .order('created_at', ascending: false)
        .limit(20);
    return (res as List).map((e) => e as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> getBookmarkedSkills() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final res = await _client
          .from('favorites')
          .select('skill_id, skills(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (res as List)
          .map((e) => e['skills'] as Map<String, dynamic>)
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchSkills(String query) async {
    final res = await _client
        .from('skills')
        .select()
        .textSearch('title', query, config: 'english')
        .order('created_at', ascending: false);
    return (res as List).map((e) => e as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> getSkillsByCategory(
    String category,
  ) async {
    final res = await _client
        .from('skills')
        .select()
        .eq('category', category)
        .order('created_at', ascending: false);
    return (res as List).map((e) => e as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> searchWithFilters({
    String? query,
    String? category,
    String? difficulty,
    String? duration,
    String? sortBy,
  }) async {
    var queryBuilder = _client.from('skills').select();

    // Apply filters
    if (query != null && query.isNotEmpty) {
      queryBuilder = queryBuilder.textSearch('title', query, config: 'english');
    }

    if (category != null && category.isNotEmpty) {
      queryBuilder = queryBuilder.eq('category', category);
    }

    if (difficulty != null && difficulty.isNotEmpty) {
      queryBuilder = queryBuilder.eq('difficulty', difficulty);
    }

    if (duration != null && duration.isNotEmpty) {
      // Assuming you have a duration field or can calculate it
      queryBuilder = queryBuilder.eq('duration_category', duration);
    }

    // Apply sorting and execute query
    final dynamic res;
    switch (sortBy) {
      case 'popular':
        res = await queryBuilder.order('total_likes', ascending: false);
        break;
      case 'recent':
        res = await queryBuilder.order('created_at', ascending: false);
        break;
      case 'views':
        res = await queryBuilder.order('view_count', ascending: false);
        break;
      default:
        res = await queryBuilder.order('created_at', ascending: false);
    }
    return (res as List).map((e) => e as Map<String, dynamic>).toList();
  }

  Future<void> bookmarkSkill(String skillId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _client.from('favorites').insert({
      'user_id': userId,
      'skill_id': skillId,
    });
  }

  Future<void> unbookmarkSkill(String skillId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    await _client
        .from('favorites')
        .delete()
        .eq('user_id', userId)
        .eq('skill_id', skillId);
  }

  Future<bool> isSkillBookmarked(String skillId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      final res = await _client
          .from('favorites')
          .select('id')
          .eq('user_id', userId)
          .eq('skill_id', skillId)
          .limit(1);

      return (res as List).isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> recordSkillView(String skillId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return;

      await _client.from('user_skill_views').insert({
        'user_id': userId,
        'skill_id': skillId,
        'viewed_at': DateTime.now().toIso8601String(),
      });

      // Also increment the view count on the skill
      await _client.rpc('increment_view_count', params: {'skill_id': skillId});
    } catch (e) {
      // Silently handle errors for analytics
    }
  }
}
