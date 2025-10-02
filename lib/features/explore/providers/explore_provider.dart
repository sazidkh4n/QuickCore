import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickcore/features/auth/data/user_model.dart';
import 'package:quickcore/features/feed/data/skill_model.dart';
import '../data/explore_repository.dart';

// Provider for the repository
final exploreRepositoryProvider = Provider((ref) => ExploreRepository());

// State for the Explore Page
class ExploreState {
  final AsyncValue<List<String>> categories;
  final AsyncValue<List<UserModel>> topCreators;
  final AsyncValue<List<SkillModel>> searchResults;
  final AsyncValue<List<SkillModel>> trendingSkills;
  final AsyncValue<List<SkillModel>> featuredContent;
  final AsyncValue<List<SkillModel>> recentlyViewed;
  final String currentFilter;
  final bool isRefreshing;

  ExploreState({
    this.categories = const AsyncValue.loading(),
    this.topCreators = const AsyncValue.loading(),
    this.searchResults = const AsyncValue.data([]),
    this.trendingSkills = const AsyncValue.loading(),
    this.featuredContent = const AsyncValue.loading(),
    this.recentlyViewed = const AsyncValue.data([]),
    this.currentFilter = 'All',
    this.isRefreshing = false,
  });

  ExploreState copyWith({
    AsyncValue<List<String>>? categories,
    AsyncValue<List<UserModel>>? topCreators,
    AsyncValue<List<SkillModel>>? searchResults,
    AsyncValue<List<SkillModel>>? trendingSkills,
    AsyncValue<List<SkillModel>>? featuredContent,
    AsyncValue<List<SkillModel>>? recentlyViewed,
    String? currentFilter,
    bool? isRefreshing,
  }) {
    return ExploreState(
      categories: categories ?? this.categories,
      topCreators: topCreators ?? this.topCreators,
      searchResults: searchResults ?? this.searchResults,
      trendingSkills: trendingSkills ?? this.trendingSkills,
      featuredContent: featuredContent ?? this.featuredContent,
      recentlyViewed: recentlyViewed ?? this.recentlyViewed,
      currentFilter: currentFilter ?? this.currentFilter,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

// Notifier for the Explore Page
class ExploreNotifier extends StateNotifier<ExploreState> {
  final Ref ref;

  ExploreNotifier(this.ref) : super(ExploreState()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final repo = ref.read(exploreRepositoryProvider);

      // Load all data concurrently for better performance
      await Future.wait([
        _loadCategories(),
        _loadTopCreators(),
        _loadTrendingSkills(),
        _loadFeaturedContent(),
        _loadRecentlyViewed(),
      ]);
    } catch (e, st) {
      // General error if something else goes wrong
      state = state.copyWith(
        categories: AsyncValue.error(e, st),
        topCreators: AsyncValue.error(e, st),
        trendingSkills: AsyncValue.error(e, st),
        featuredContent: AsyncValue.error(e, st),
      );
    }
  }

  Future<void> _loadCategories() async {
    try {
      final repo = ref.read(exploreRepositoryProvider);
      final categories = await repo.getCategories();
      state = state.copyWith(categories: AsyncValue.data(categories));
    } catch (e, st) {
      state = state.copyWith(categories: AsyncValue.error(e, st));
    }
  }

  Future<void> _loadTopCreators() async {
    try {
      final repo = ref.read(exploreRepositoryProvider);
      final topCreators = await repo.getTopCreators();
      // Filter to only get users with the 'creator' or 'tutor' role
      final filteredCreators = topCreators
          .where((user) => user.role == 'creator' || user.role == 'tutor')
          .toList();
      state = state.copyWith(topCreators: AsyncValue.data(filteredCreators));
    } catch (e, st) {
      state = state.copyWith(topCreators: AsyncValue.error(e, st));
    }
  }

  Future<void> _loadTrendingSkills() async {
    try {
      final repo = ref.read(exploreRepositoryProvider);
      final trendingData = await repo.getTrendingSkills();
      final trending = trendingData.map((e) => SkillModel.fromJson(e)).toList();
      state = state.copyWith(trendingSkills: AsyncValue.data(trending));
    } catch (e, st) {
      state = state.copyWith(trendingSkills: AsyncValue.error(e, st));
    }
  }

  Future<void> _loadFeaturedContent() async {
    try {
      final repo = ref.read(exploreRepositoryProvider);
      final featuredData = await repo.getFeaturedContent();
      final featured = featuredData.map((e) => SkillModel.fromJson(e)).toList();
      state = state.copyWith(featuredContent: AsyncValue.data(featured));
    } catch (e, st) {
      state = state.copyWith(featuredContent: AsyncValue.error(e, st));
    }
  }

  Future<void> _loadRecentlyViewed() async {
    try {
      final repo = ref.read(exploreRepositoryProvider);
      final recentData = await repo.getRecentlyViewed();
      final recent = recentData.map((e) => SkillModel.fromJson(e)).toList();
      state = state.copyWith(recentlyViewed: AsyncValue.data(recent));
    } catch (e, st) {
      state = state.copyWith(recentlyViewed: AsyncValue.data([]));
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true);
    await _loadInitialData();
    state = state.copyWith(isRefreshing: false);
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = state.copyWith(searchResults: const AsyncValue.data([]));
      return;
    }

    state = state.copyWith(searchResults: const AsyncValue.loading());
    try {
      final repo = ref.read(exploreRepositoryProvider);
      final skillsData = await repo.searchSkills(query);
      final skills = skillsData.map((e) => SkillModel.fromJson(e)).toList();
      state = state.copyWith(searchResults: AsyncValue.data(skills));
    } catch (e, st) {
      state = state.copyWith(searchResults: AsyncValue.error(e, st));
    }
  }

  Future<void> searchByCategory(String category) async {
    state = state.copyWith(searchResults: const AsyncValue.loading());
    try {
      final repo = ref.read(exploreRepositoryProvider);
      final skillsData = await repo.getSkillsByCategory(category);
      final skills = skillsData.map((e) => SkillModel.fromJson(e)).toList();
      state = state.copyWith(searchResults: AsyncValue.data(skills));
    } catch (e, st) {
      state = state.copyWith(searchResults: AsyncValue.error(e, st));
    }
  }

  Future<void> searchWithFilters({
    String? query,
    String? category,
    String? difficulty,
    String? duration,
    String? sortBy,
  }) async {
    state = state.copyWith(searchResults: const AsyncValue.loading());
    try {
      final repo = ref.read(exploreRepositoryProvider);
      final skillsData = await repo.searchWithFilters(
        query: query,
        category: category,
        difficulty: difficulty,
        duration: duration,
        sortBy: sortBy,
      );
      final skills = skillsData.map((e) => SkillModel.fromJson(e)).toList();
      state = state.copyWith(searchResults: AsyncValue.data(skills));
    } catch (e, st) {
      state = state.copyWith(searchResults: AsyncValue.error(e, st));
    }
  }

  void applyFilter(String filter) {
    state = state.copyWith(currentFilter: filter);

    // Apply filter logic based on the selected filter
    switch (filter) {
      case 'Trending':
        _loadTrendingAsResults();
        break;
      case 'Recent':
        _loadRecentAsResults();
        break;
      case 'Popular':
        _loadPopularAsResults();
        break;
      case 'Bookmarked':
        _loadBookmarkedAsResults();
        break;
      default:
        clearSearch();
    }
  }

  Future<void> _loadTrendingAsResults() async {
    state.trendingSkills.when(
      data: (skills) =>
          state = state.copyWith(searchResults: AsyncValue.data(skills)),
      loading: () =>
          state = state.copyWith(searchResults: const AsyncValue.loading()),
      error: (e, st) =>
          state = state.copyWith(searchResults: AsyncValue.error(e, st)),
    );
  }

  Future<void> _loadRecentAsResults() async {
    state.recentlyViewed.when(
      data: (skills) =>
          state = state.copyWith(searchResults: AsyncValue.data(skills)),
      loading: () =>
          state = state.copyWith(searchResults: const AsyncValue.loading()),
      error: (e, st) =>
          state = state.copyWith(searchResults: AsyncValue.error(e, st)),
    );
  }

  Future<void> _loadPopularAsResults() async {
    try {
      final repo = ref.read(exploreRepositoryProvider);
      final skillsData = await repo.getPopularSkills();
      final skills = skillsData.map((e) => SkillModel.fromJson(e)).toList();
      state = state.copyWith(searchResults: AsyncValue.data(skills));
    } catch (e, st) {
      state = state.copyWith(searchResults: AsyncValue.error(e, st));
    }
  }

  Future<void> _loadBookmarkedAsResults() async {
    try {
      final repo = ref.read(exploreRepositoryProvider);
      final skillsData = await repo.getBookmarkedSkills();
      final skills = skillsData.map((e) => SkillModel.fromJson(e)).toList();
      state = state.copyWith(searchResults: AsyncValue.data(skills));
    } catch (e, st) {
      state = state.copyWith(searchResults: AsyncValue.error(e, st));
    }
  }

  Future<void> bookmarkSkill(String skillId) async {
    try {
      final repo = ref.read(exploreRepositoryProvider);
      await repo.bookmarkSkill(skillId);
      // Refresh bookmarked content if currently viewing bookmarks
      if (state.currentFilter == 'Bookmarked') {
        _loadBookmarkedAsResults();
      }
    } catch (e) {
      // Handle error silently or show a snackbar
    }
  }

  Future<void> unbookmarkSkill(String skillId) async {
    try {
      final repo = ref.read(exploreRepositoryProvider);
      await repo.unbookmarkSkill(skillId);
      // Refresh bookmarked content if currently viewing bookmarks
      if (state.currentFilter == 'Bookmarked') {
        _loadBookmarkedAsResults();
      }
    } catch (e) {
      // Handle error silently or show a snackbar
    }
  }

  // Clear search results
  void clearSearch() {
    state = state.copyWith(searchResults: const AsyncValue.data([]));
  }
}

// Provider for the Notifier
final exploreProvider =
    StateNotifierProvider.autoDispose<ExploreNotifier, ExploreState>((ref) {
      return ExploreNotifier(ref);
    });
