import 'package:supabase_flutter/supabase_flutter.dart';
import 'learning_stats_model.dart';

class LearningStatsRepository {
  final _client = Supabase.instance.client;

  Future<LearningStats> getLearningStats(String userId) async {
    try {
      // Get skills viewed count
      final viewedResult = await _client
          .from('skill_views')
          .select('skill_id')
          .eq('user_id', userId);
      
      final uniqueSkillIds = (viewedResult as List).map((item) => item['skill_id']).toSet();
      final skillsViewed = uniqueSkillIds.length;
      
      // Get total minutes watched
      final minutesResult = await _client
          .from('skill_views')
          .select('duration')
          .eq('user_id', userId);
          
      int totalSeconds = 0;
      for (final view in minutesResult as List) {
        totalSeconds += (view['duration'] as int? ?? 0);
      }
      final minutesLearned = totalSeconds ~/ 60;
      
      // Get learning streak
      final streakResult = await _client
          .from('user_stats')
          .select('streak')
          .eq('user_id', userId)
          .single();
      
      final learningStreak = streakResult['streak'] as int? ?? 0;
      
      // Get interests based on most viewed categories
      final interestsResult = await _client
          .from('skill_views')
          .select('skills(category)')
          .eq('user_id', userId);
      
      final categoryCounts = <String, int>{};
      for (final view in interestsResult as List) {
        final category = view['skills']?['category'] as String?;
        if (category != null) {
          categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
        }
      }
      
      final sortedCategories = categoryCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      final interests = sortedCategories.take(5).map((e) => e.key).toList();
      
      // Get achievements
      final achievements = <String, bool>{
        'curious_learner': skillsViewed >= 10,
        'week_warrior': learningStreak >= 7,
        'design_novice': false, // Would need category-specific counts
        'specialist': false, // Would need category-specific counts
        'first_bookmark': false, // Would need to check bookmarks
      };
      
      // Check for bookmarks to update first_bookmark achievement
      final bookmarksResult = await _client
          .from('favorites')
          .select()
          .eq('user_id', userId)
          .limit(1);
      
      achievements['first_bookmark'] = (bookmarksResult as List).isNotEmpty;
      
      return LearningStats(
        skillsViewed: skillsViewed,
        minutesLearned: minutesLearned,
        learningStreak: learningStreak,
        interests: interests,
        achievements: achievements,
      );
    } catch (e) {
      // Return default stats if there's an error
      return const LearningStats();
    }
  }
  
  Future<List<Map<String, dynamic>>> getViewHistory(String userId, {int limit = 50}) async {
    try {
      final result = await _client
          .from('skill_views')
          .select('*, skills(*)')
          .eq('user_id', userId)
          .order('viewed_at', ascending: false)
          .limit(limit);
      
      return List<Map<String, dynamic>>.from(result ?? []);
    } catch (e) {
      return [];
    }
  }
  
  Future<List<Map<String, dynamic>>> getLikedSkills(String userId) async {
    try {
      final result = await _client
          .from('likes')
          .select('*, skills(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(result ?? []);
    } catch (e) {
      return [];
    }
  }
  
  Future<void> updateInterests(String userId, List<String> interests) async {
    await _client
        .from('user_interests')
        .delete()
        .eq('user_id', userId);
    
    for (final interest in interests) {
      await _client
          .from('user_interests')
          .insert({
            'user_id': userId,
            'category': interest,
          });
    }
  }
} 