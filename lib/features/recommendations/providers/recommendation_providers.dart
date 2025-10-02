import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickcore/features/feed/data/skill_model.dart';
import 'package:quickcore/features/auth/data/user_model.dart';
import 'package:quickcore/features/auth/providers/auth_provider.dart';
import '../data/recommendation_repository.dart';
import 'dart:developer' as dev;

// Provider for the recommendation repository
final recommendationRepositoryProvider = Provider<RecommendationRepository>((ref) {
  return RecommendationRepository();
});

// Provider for personalized recommendations
final personalizedRecommendationsProvider = FutureProvider<List<SkillModel>>((ref) async {
  final user = ref.watch(authProvider).value;
  if (user == null) {
    dev.log('No user logged in, cannot fetch personalized recommendations');
    return [];
  }
  
  final repo = ref.read(recommendationRepositoryProvider);
  return repo.getPersonalizedRecommendations(user.id);
});

// Provider for trending content
final trendingContentProvider = FutureProvider<List<SkillModel>>((ref) async {
  final repo = ref.read(recommendationRepositoryProvider);
  return repo.getTrendingContent();
});

// Provider for content by topic
final contentByTopicProvider = FutureProvider.family<List<SkillModel>, String>((ref, topic) async {
  final repo = ref.read(recommendationRepositoryProvider);
  return repo.getContentByTopic(topic);
});

// Provider for popular topics
final popularTopicsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.read(recommendationRepositoryProvider);
  return repo.getPopularTopics();
});

// Provider for recommended creators
final recommendedCreatorsProvider = FutureProvider<List<UserModel>>((ref) async {
  final user = ref.watch(authProvider).value;
  if (user == null) {
    dev.log('No user logged in, cannot fetch recommended creators');
    return [];
  }
  
  final repo = ref.read(recommendationRepositoryProvider);
  return repo.getRecommendedCreators(user.id);
});

// State for the discovery screen
class DiscoveryState {
  final AsyncValue<List<SkillModel>> personalizedRecommendations;
  final AsyncValue<List<SkillModel>> trendingContent;
  final AsyncValue<List<Map<String, dynamic>>> popularTopics;
  final AsyncValue<List<UserModel>> recommendedCreators;
  final String? selectedTopic;
  final AsyncValue<List<SkillModel>> topicContent;

  DiscoveryState({
    this.personalizedRecommendations = const AsyncValue.loading(),
    this.trendingContent = const AsyncValue.loading(),
    this.popularTopics = const AsyncValue.loading(),
    this.recommendedCreators = const AsyncValue.loading(),
    this.selectedTopic,
    this.topicContent = const AsyncValue.loading(),
  });

  DiscoveryState copyWith({
    AsyncValue<List<SkillModel>>? personalizedRecommendations,
    AsyncValue<List<SkillModel>>? trendingContent,
    AsyncValue<List<Map<String, dynamic>>>? popularTopics,
    AsyncValue<List<UserModel>>? recommendedCreators,
    String? selectedTopic,
    AsyncValue<List<SkillModel>>? topicContent,
  }) {
    return DiscoveryState(
      personalizedRecommendations: personalizedRecommendations ?? this.personalizedRecommendations,
      trendingContent: trendingContent ?? this.trendingContent,
      popularTopics: popularTopics ?? this.popularTopics,
      recommendedCreators: recommendedCreators ?? this.recommendedCreators,
      selectedTopic: selectedTopic ?? this.selectedTopic,
      topicContent: topicContent ?? this.topicContent,
    );
  }
}

// Notifier for the discovery screen
class DiscoveryNotifier extends StateNotifier<DiscoveryState> {
  final Ref ref;
  
  DiscoveryNotifier(this.ref) : super(DiscoveryState()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final user = ref.read(authProvider).value;
    final repo = ref.read(recommendationRepositoryProvider);
    
    // Load trending content
    try {
      final trending = await repo.getTrendingContent();
      state = state.copyWith(trendingContent: AsyncValue.data(trending));
    } catch (e, st) {
      state = state.copyWith(trendingContent: AsyncValue.error(e, st));
    }
    
    // Load popular topics
    try {
      final topics = await repo.getPopularTopics();
      state = state.copyWith(popularTopics: AsyncValue.data(topics));
    } catch (e, st) {
      state = state.copyWith(popularTopics: AsyncValue.error(e, st));
    }
    
    // Load personalized recommendations if user is logged in
    if (user != null) {
      try {
        final recommendations = await repo.getPersonalizedRecommendations(user.id);
        state = state.copyWith(personalizedRecommendations: AsyncValue.data(recommendations));
      } catch (e, st) {
        state = state.copyWith(personalizedRecommendations: AsyncValue.error(e, st));
      }
      
      // Load recommended creators
      try {
        final creators = await repo.getRecommendedCreators(user.id);
        state = state.copyWith(recommendedCreators: AsyncValue.data(creators));
      } catch (e, st) {
        state = state.copyWith(recommendedCreators: AsyncValue.error(e, st));
      }
    }
  }
  
  Future<void> selectTopic(String topic) async {
    state = state.copyWith(selectedTopic: topic, topicContent: const AsyncValue.loading());
    
    try {
      final repo = ref.read(recommendationRepositoryProvider);
      final content = await repo.getContentByTopic(topic);
      state = state.copyWith(topicContent: AsyncValue.data(content));
    } catch (e, st) {
      state = state.copyWith(topicContent: AsyncValue.error(e, st));
    }
  }
  
  void clearSelectedTopic() {
    state = state.copyWith(selectedTopic: null, topicContent: const AsyncValue.loading());
  }
  
  Future<void> refresh() async {
    state = DiscoveryState();
    await _loadInitialData();
  }
}

// Provider for the discovery notifier
final discoveryProvider = StateNotifierProvider<DiscoveryNotifier, DiscoveryState>((ref) {
  return DiscoveryNotifier(ref);
}); 