import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickcore/features/feed/data/skill_model.dart';
import '../data/learning_stats_repository.dart';
import '../data/learning_stats_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final learningStatsRepositoryProvider = Provider((ref) => LearningStatsRepository());

// Provider for user's learning stats
final learningStatsProvider = FutureProvider.family<LearningStats, String>((ref, userId) async {
  final repo = ref.read(learningStatsRepositoryProvider);
  return repo.getLearningStats(userId);
});

// Provider for user's view history
final viewHistoryProvider = FutureProvider.family<List<SkillModel>, String>((ref, userId) async {
  final repo = ref.read(learningStatsRepositoryProvider);
  final history = await repo.getViewHistory(userId);
  
  return history
      .map((item) => SkillModel.fromJson(item['skills'] as Map<String, dynamic>))
      .toList();
});

// Provider for user's liked skills
final likedSkillsProvider = FutureProvider.family<List<SkillModel>, String>((ref, userId) async {
  final repo = ref.read(learningStatsRepositoryProvider);
  final liked = await repo.getLikedSkills(userId);
  
  return liked
      .map((item) => SkillModel.fromJson(item['skills'] as Map<String, dynamic>))
      .toList();
});

// Provider for user's interests
final userInterestsProvider = FutureProvider.family<List<String>, String>((ref, userId) async {
  final stats = await ref.watch(learningStatsProvider(userId).future);
  return stats.interests;
});

// Provider for user's achievements
final userAchievementsProvider = FutureProvider.family<Map<String, bool>, String>((ref, userId) async {
  final stats = await ref.watch(learningStatsProvider(userId).future);
  return stats.achievements;
});

// Add these new providers for the learner profile screen
final skillInterestsProvider = FutureProvider.family<List<dynamic>, String>((ref, userId) async {
  final client = Supabase.instance.client;
  final res = await client
      .from('user_interests')
      .select('*, skills(*)')
      .eq('user_id', userId)
      .limit(10);
  
  return res;
});

final watchHistoryProvider = FutureProvider.family<List<dynamic>, String>((ref, userId) async {
  final client = Supabase.instance.client;
  final res = await client
      .from('watch_history')
      .select('*, skills(*)')
      .eq('user_id', userId)
      .order('watched_at', ascending: false)
      .limit(10);
  
  return res;
});

final bookmarkedVideosProvider = FutureProvider.family<List<dynamic>, String>((ref, userId) async {
  final client = Supabase.instance.client;
  final res = await client
      .from('bookmarks')
      .select('*, skills(*)')
      .eq('user_id', userId)
      .order('bookmarked_at', ascending: false)
      .limit(10);
  
  return res;
});

// Notifier for updating interests
class InterestsNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  
  InterestsNotifier(this._ref) : super(const AsyncValue.data(null));
  
  Future<void> updateInterests(String userId, List<String> interests) async {
    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(learningStatsRepositoryProvider);
      await repo.updateInterests(userId, interests);
      _ref.invalidate(userInterestsProvider(userId));
      _ref.invalidate(learningStatsProvider(userId));
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final interestsNotifierProvider = StateNotifierProvider<InterestsNotifier, AsyncValue<void>>((ref) {
  return InterestsNotifier(ref);
}); 