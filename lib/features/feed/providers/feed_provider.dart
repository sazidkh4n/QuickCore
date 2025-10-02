import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/feed_repository.dart';
import '../data/skill_model.dart';
import '../data/skill_repository.dart';
import '../../auth/providers/auth_provider.dart';
import 'dart:developer' as dev;

final feedRepositoryProvider = Provider((ref) => FeedRepository());
final skillRepositoryProvider = Provider((ref) => SkillRepository());

// Provider to fetch a single skill by ID
final singleSkillProvider = FutureProvider.family<SkillModel?, String>((ref, skillId) async {
  try {
    dev.log('Fetching single skill with ID: $skillId');
    final repo = ref.read(skillRepositoryProvider);
    return await repo.getSkillById(skillId);
  } catch (e) {
    dev.log('Error fetching skill: $e');
    return null;
  }
});

final feedProvider = StateNotifierProvider<FeedNotifier, AsyncValue<List<SkillModel>>>((ref) {
  return FeedNotifier(ref);
});

class FeedNotifier extends StateNotifier<AsyncValue<List<SkillModel>>> {
  final Ref ref;
  
  FeedNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadRandomFeed();
  }

  Future<void> loadFeed() async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(feedRepositoryProvider);
      final feed = await repo.fetchFeed();
      state = AsyncValue.data(feed);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> loadRandomFeed() async {
    state = const AsyncValue.loading();
    try {
      final repo = ref.read(feedRepositoryProvider);
      final feed = await repo.fetchRandomFeed();
      state = AsyncValue.data(feed);
    } catch (e, st) {
      dev.log('Error loading random feed: $e');
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> refreshFeed() async {
    try {
      final repo = ref.read(feedRepositoryProvider);
      final feed = await repo.fetchRandomFeed();
      state = AsyncValue.data(feed);
    } catch (e, st) {
      dev.log('Error refreshing feed: $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> incrementView(String skillId) async {
    try {
      final repo = ref.read(feedRepositoryProvider);
      await repo.incrementViewCount(skillId);
      
      // Manually update the view count in the local state
      final currentFeed = state.value ?? [];
      final updatedFeed = currentFeed.map((skill) {
        if (skill.id == skillId) {
          return skill.copyWith(viewCount: (skill.viewCount ?? 0) + 1);
        }
        return skill;
      }).toList();
      state = AsyncValue.data(updatedFeed);

    } catch (e) {
      // Silently handle error for view increment
      dev.log('Error incrementing view: $e');
    }
  }

  Future<void> addSkill(SkillModel skill) async {
    final current = state.value ?? [];
    state = AsyncValue.data([skill, ...current]);
  }
}

// Updated to use random following feed
final followingFeedProvider = StateNotifierProvider<FollowingFeedNotifier, AsyncValue<List<SkillModel>>>((ref) {
  return FollowingFeedNotifier(ref);
});

class FollowingFeedNotifier extends StateNotifier<AsyncValue<List<SkillModel>>> {
  final Ref ref;
  
  FollowingFeedNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadRandomFollowingFeed();
  }
  
  Future<void> loadFollowingFeed() async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(authProvider).value;
      if (user == null) {
        state = const AsyncValue.data([]);
        return;
      }
      
      final repo = ref.read(feedRepositoryProvider);
      final feed = await repo.fetchFollowingFeed(user.id);
      state = AsyncValue.data(feed);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> loadRandomFollowingFeed() async {
    state = const AsyncValue.loading();
    try {
      final user = ref.read(authProvider).value;
      if (user == null) {
        state = const AsyncValue.data([]);
        return;
      }
      
      final repo = ref.read(feedRepositoryProvider);
      final feed = await repo.fetchRandomFollowingFeed(user.id);
      state = AsyncValue.data(feed);
    } catch (e, st) {
      dev.log('Error loading random following feed: $e');
      state = AsyncValue.error(e, st);
    }
  }
  
  Future<void> refreshFeed() async {
    try {
      final user = ref.read(authProvider).value;
      if (user == null) {
        state = const AsyncValue.data([]);
        return;
      }
      
      final repo = ref.read(feedRepositoryProvider);
      final feed = await repo.fetchRandomFollowingFeed(user.id);
      state = AsyncValue.data(feed);
    } catch (e, st) {
      dev.log('Error refreshing following feed: $e');
      state = AsyncValue.error(e, st);
    }
  }
}

final feedNotifierProvider = Provider<FeedRepository>(
  (ref) => FeedRepository(),
);
