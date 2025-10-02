import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickcore/features/auth/data/user_model.dart';
import 'package:quickcore/features/feed/data/skill_model.dart';
import 'package:quickcore/features/profile/presentation/user_profile_screen.dart';
import 'package:quickcore/features/video/providers/video_controller_provider.dart';
import 'package:quickcore/shared/widgets/skeleton_loader.dart';
import 'package:quickcore/shared/widgets/cached_network_image.dart';
import '../providers/explore_provider.dart';
import 'widgets/advanced_search_widget.dart';
import 'widgets/modern_skill_card.dart';
import 'widgets/explore_fab.dart';
import 'widgets/analytics_dashboard.dart';
import 'widgets/trending_topics_widget.dart';
import 'widgets/ai_recommendations_widget.dart';
import 'widgets/learning_paths_widget.dart';
import 'dart:ui';
import 'dart:math' as math;

class ExploreScreen extends ConsumerStatefulWidget {
  final String? category;
  const ExploreScreen({this.category, super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  late AnimationController _headerAnimationController;
  late AnimationController _searchAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _searchAnimation;

  bool _searchFocused = false;
  bool _isSearchExpanded = false;
  String _selectedFilter = 'All';
  List<String> _recentSearches = [];
  List<String> _searchSuggestions = [];

  final List<String> _filters = [
    'All',
    'Trending',
    'Recent',
    'Popular',
    'Bookmarked',
  ];

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    );

    _searchAnimation = CurvedAnimation(
      parent: _searchAnimationController,
      curve: Curves.easeInOut,
    );

    // Set screen context and pause any playing videos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(videoControllerNotifierProvider).setCurrentScreen('explore');
      ref.read(videoControllerNotifierProvider).pauseAllVideosManually();

      // Start header animation
      _headerAnimationController.forward();

      // If a category is passed, trigger a search for it immediately.
      if (widget.category != null) {
        ref.read(exploreProvider.notifier).searchByCategory(widget.category!);
      }
    });

    // Listen to search focus changes
    _searchFocusNode.addListener(() {
      setState(() {
        _searchFocused = _searchFocusNode.hasFocus;
      });

      if (_searchFocusNode.hasFocus) {
        _searchAnimationController.forward();
      } else {
        _searchAnimationController.reverse();
      }
    });

    // Listen to search text changes
    _searchController.addListener(() {
      setState(() {});
      _updateSearchSuggestions(_searchController.text);
    });
  }

  void _updateSearchSuggestions(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchSuggestions = [];
      });
      return;
    }

    // Mock search suggestions - in real app, fetch from API
    final suggestions =
        [
              'Flutter Development',
              'UI/UX Design',
              'Machine Learning',
              'Web Development',
              'Mobile App Development',
              'Data Science',
              'Digital Marketing',
              'Photography',
            ]
            .where(
              (suggestion) =>
                  suggestion.toLowerCase().contains(query.toLowerCase()),
            )
            .take(5)
            .toList();

    setState(() {
      _searchSuggestions = suggestions;
    });
  }

  void _performSearch(String query) {
    if (query.trim().isEmpty) return;

    // Add to recent searches
    setState(() {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.take(10).toList();
      }
    });

    // Perform search
    ref.read(exploreProvider.notifier).search(query);
    _searchFocusNode.unfocus();

    // Haptic feedback
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    _headerAnimationController.dispose();
    _searchAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(exploreProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.lightImpact();
          await ref.read(exploreProvider.notifier).refresh();
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Modern App Bar with Glass Morphism
            _buildModernAppBar(context, colorScheme),

            // Advanced Search Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: AdvancedSearchWidget(
                  onSearch: (filters) {
                    ref
                        .read(exploreProvider.notifier)
                        .searchWithFilters(
                          query: filters['query'],
                          category: filters['category'],
                          difficulty: filters['difficulty'],
                          duration: filters['duration'],
                          sortBy: filters['sortBy'],
                        );
                  },
                  onVoiceSearch: () {
                    HapticFeedback.mediumImpact();
                    // Implement voice search functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Voice search coming soon!'),
                        backgroundColor: colorScheme.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Quick access filters
            _buildQuickAccessFilters(context, colorScheme),

            // Main Content
            state.searchResults.when(
              data: (skills) {
                if (skills.isEmpty &&
                    _searchController.text.isEmpty &&
                    widget.category == null) {
                  return _buildInitialExploreView(context, colorScheme);
                }
                return RepaintBoundary(child: _buildSearchResultsView(skills, context, colorScheme));
              },
              loading: () => _buildLoadingView(context),
              error: (e, st) => _buildErrorView(e.toString(), context),
            ),
          ],
        ),
      ),
      floatingActionButton: const ExploreFAB(),
    );
  }

  Widget _buildModernAppBar(BuildContext context, ColorScheme colorScheme) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: AnimatedBuilder(
        animation: _headerAnimation,
        builder: (context, child) {
          return FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.primary.withOpacity(0.1),
                    colorScheme.secondary.withOpacity(0.05),
                    colorScheme.surface,
                  ],
                ),
              ),
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withOpacity(0.8),
                      border: Border(
                        bottom: BorderSide(
                          color: colorScheme.outline.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Transform.translate(
                              offset: Offset(
                                0,
                                20 * (1 - _headerAnimation.value),
                              ),
                              child: Opacity(
                                opacity: _headerAnimation.value,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Explore',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: colorScheme.onSurface,
                                                  letterSpacing: -0.5,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Discover amazing content',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: colorScheme.onSurface
                                                      .withOpacity(0.7),
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    _buildNotificationButton(colorScheme),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationButton(ColorScheme colorScheme) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
      ),
      child: IconButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          context.push('/notifications');
        },
        icon: Stack(
          children: [
            Icon(Icons.notifications_outlined, color: colorScheme.onSurface),
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: colorScheme.error,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context, ColorScheme colorScheme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Enhanced Search Bar
            AnimatedBuilder(
              animation: _searchAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface.withOpacity(0.9),
                          border: Border.all(
                            color: _searchFocused
                                ? colorScheme.primary.withOpacity(0.3)
                                : colorScheme.outline.withOpacity(0.1),
                            width: _searchFocused ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Search skills, creators, topics...',
                            hintStyle: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                            prefixIcon: AnimatedRotation(
                              turns: _searchAnimation.value * 0.5,
                              duration: const Duration(milliseconds: 300),
                              child: Icon(
                                Icons.search_rounded,
                                color: _searchFocused
                                    ? colorScheme.primary
                                    : colorScheme.onSurface.withOpacity(0.6),
                                size: 24,
                              ),
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.mic_rounded,
                                          color: colorScheme.primary,
                                        ),
                                        onPressed: () {
                                          HapticFeedback.lightImpact();
                                          // Voice search functionality
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.clear_rounded,
                                          color: colorScheme.onSurface
                                              .withOpacity(0.6),
                                        ),
                                        onPressed: () {
                                          _searchController.clear();
                                          ref
                                              .read(exploreProvider.notifier)
                                              .clearSearch();
                                          HapticFeedback.lightImpact();
                                        },
                                      ),
                                    ],
                                  )
                                : IconButton(
                                    icon: Icon(
                                      Icons.mic_rounded,
                                      color: colorScheme.onSurface.withOpacity(
                                        0.6,
                                      ),
                                    ),
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      // Voice search functionality
                                    },
                                  ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 0,
                            ),
                          ),
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 16,
                          ),
                          onChanged: (value) {
                            if (value.length > 2) {
                              ref.read(exploreProvider.notifier).search(value);
                            } else if (value.isEmpty) {
                              ref.read(exploreProvider.notifier).clearSearch();
                            }
                          },
                          onSubmitted: _performSearch,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // Search Suggestions
            if (_searchFocused && _searchSuggestions.isNotEmpty)
              _buildSearchSuggestions(context, colorScheme),

            // Recent Searches
            if (_searchFocused &&
                _recentSearches.isNotEmpty &&
                _searchController.text.isEmpty)
              _buildRecentSearches(context, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: _searchSuggestions.map((suggestion) {
          return ListTile(
            leading: Icon(
              Icons.search_rounded,
              color: colorScheme.onSurface.withOpacity(0.6),
              size: 20,
            ),
            title: Text(
              suggestion,
              style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
            ),
            onTap: () {
              _searchController.text = suggestion;
              _performSearch(suggestion);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecentSearches(BuildContext context, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Recent Searches',
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.7),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ..._recentSearches.take(5).map((search) {
            return ListTile(
              leading: Icon(
                Icons.history_rounded,
                color: colorScheme.onSurface.withOpacity(0.6),
                size: 20,
              ),
              title: Text(
                search,
                style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  color: colorScheme.onSurface.withOpacity(0.4),
                  size: 18,
                ),
                onPressed: () {
                  setState(() {
                    _recentSearches.remove(search);
                  });
                },
              ),
              onTap: () {
                _searchController.text = search;
                _performSearch(search);
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildQuickAccessFilters(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    final filters = ['All', 'Trending', 'Recent', 'Popular', 'Bookmarked'];

    return SliverToBoxAdapter(
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: filters.length,
          itemBuilder: (context, index) {
            final filter = filters[index];
            final isSelected = _selectedFilter == filter;

            return Container(
              margin: const EdgeInsets.only(right: 12),
              child: FilterChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                  HapticFeedback.lightImpact();
                  ref.read(exploreProvider.notifier).applyFilter(filter);
                },
                backgroundColor: colorScheme.surface,
                selectedColor: colorScheme.primary,
                checkmarkColor: colorScheme.onPrimary,
                labelStyle: TextStyle(
                  color: isSelected
                      ? colorScheme.onPrimary
                      : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Replace _buildLoadingView with a luxury skeleton loader:
  Widget _buildLoadingView(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SliverList(
      delegate: SliverChildListDelegate([
        // Skeleton for search bar
        Padding(
          padding: const EdgeInsets.all(20),
          child: SkeletonLoader(
            type: SkeletonType.card,
            width: double.infinity,
            height: 48,
          ),
        ),
        // Skeleton for filters
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: List.generate(4, (i) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: SkeletonLoader(
                type: SkeletonType.card,
                width: 70,
                height: 32,
              ),
            )),
          ),
        ),
        // Skeleton for grid/list
        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: 600,
            child: SkeletonLoader(
              type: SkeletonType.explore,
              itemCount: 6,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildErrorView(String error, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(exploreProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialExploreView(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    final state = ref.watch(exploreProvider);

    return SliverList(
      delegate: SliverChildListDelegate([
        // Featured Content Section
        _buildFeaturedSection(context, colorScheme),

        // Analytics Dashboard
        const AnalyticsDashboard(),

        // Trending Topics Widget
        TrendingTopicsWidget(
          onTopicTap: (topic) {
            ref.read(exploreProvider.notifier).search(topic);
          },
        ),

        const SizedBox(height: 20),

        // AI Recommendations Widget
        AIRecommendationsWidget(
          onSkillTap: (skill) {
            context.go('/video/${skill.id}?source=explore');
          },
        ),

        const SizedBox(height: 20),

        // Learning Paths Widget
        LearningPathsWidget(
          onPathTap: (path) {
            // Navigate to learning path details
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Opening ${path.title} learning path'),
                backgroundColor: path.color,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        // Top Creators Section
        _buildSectionHeader(
          'Top Creators',
          'Meet our amazing creators',
          context,
        ),
        state.topCreators.when(
          data: (creators) =>
              _buildCreatorsList(creators, context, colorScheme),
          loading: () => _buildCreatorsLoading(context),
          error: (e, st) => _buildSectionError(e.toString(), context),
        ),

        // Popular Categories Section
        _buildSectionHeader('Popular Categories', 'Explore by topic', context),
        state.categories.when(
          data: (categories) =>
              _buildCategoryGrid(categories, context, colorScheme),
          loading: () => _buildCategoriesLoading(context),
          error: (e, st) => _buildSectionError(e.toString(), context),
        ),

        // Featured Skills Grid
        _buildSectionHeader('Featured Skills', 'Hand-picked for you', context),
        state.featuredContent.when(
          data: (skills) =>
              _buildFeaturedSkillsGrid(skills, context, colorScheme),
          loading: () => _buildSkillsGridLoading(context),
          error: (e, st) => _buildSectionError(e.toString(), context),
        ),

        // Recently Viewed Section (if user has history)
        state.recentlyViewed.when(
          data: (skills) {
            if (skills.isNotEmpty) {
              return Column(
                children: [
                  _buildSectionHeader(
                    'Continue Learning',
                    'Pick up where you left off',
                    context,
                  ),
                  _buildRecentlyViewedList(skills, context, colorScheme),
                ],
              );
            }
            return const SizedBox.shrink();
          },
          loading: () => const SizedBox.shrink(),
          error: (e, st) => const SizedBox.shrink(),
        ),

        // Bottom spacing for FAB
        const SizedBox(height: 120),
      ]),
    );
  }

  Widget _buildSearchResultsView(
    List<SkillModel> skills,
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final skill = skills[index];
          return ModernSkillCard(
            skill: skill,
            showBookmark: true,
            isBookmarked: false, // TODO: Check if bookmarked
          );
        }, childCount: skills.length),
      ),
    );
  }

  Widget _buildFeaturedSection(BuildContext context, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.secondary],
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: CustomPaint(
                painter: _PatternPainter(
                  colorScheme.onPrimary.withOpacity(0.1),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '🚀 Featured Content',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Discover trending skills and connect with amazing creators',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onPrimary.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/discover'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.surface,
                      foregroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('Explore Now'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String subtitle,
    BuildContext context,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreatorsList(
    List<UserModel> creators,
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    final topCreators = creators
        .where((user) => user.role == 'creator' || user.role == 'tutor')
        .toList();

    return Container(
      height: 140,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: topCreators.length,
        itemBuilder: (context, index) {
          final creator = topCreators[index];
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.push('/profile/${creator.id}');
            },
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: colorScheme.primaryContainer,
                      backgroundImage: creator.avatarUrl != null
                          ? NetworkImage(creator.avatarUrl!)
                          : null,
                      child: creator.avatarUrl == null
                          ? Icon(
                              Icons.person_rounded,
                              size: 40,
                              color: colorScheme.onPrimaryContainer,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    creator.name ?? 'No Name',
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      creator.role?.toUpperCase() ?? 'USER',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCreatorsLoading(BuildContext context) {
    return Container(
      height: 140,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 100,
            margin: const EdgeInsets.only(right: 16),
            child: const Column(
              children: [
                SkeletonLoader(
                  type: SkeletonType.profile,
                  height: 80,
                  width: 80,
                ),
                SizedBox(height: 12),
                SkeletonLoader(type: SkeletonType.list, height: 12, width: 80),
                SizedBox(height: 4),
                SkeletonLoader(type: SkeletonType.list, height: 16, width: 60),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryGrid(
    List<String> categories,
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final colors = _getCategoryColors(index, colorScheme);

          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              ref.read(exploreProvider.notifier).searchByCategory(category);
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: colors,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colors.first.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _PatternPainter(Colors.white.withOpacity(0.1)),
                      ),
                    ),
                    // Content
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getCategoryIcon(category),
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              category,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesLoading(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return const SkeletonLoader(type: SkeletonType.card, height: 80);
        },
      ),
    );
  }

  Widget _buildTrendingSkills(BuildContext context, ColorScheme colorScheme) {
    // Mock trending skills data
    final trendingSkills = [
      {
        'title': 'Flutter Development',
        'trend': '+25%',
        'icon': Icons.phone_android,
      },
      {'title': 'UI/UX Design', 'trend': '+18%', 'icon': Icons.design_services},
      {'title': 'Machine Learning', 'trend': '+32%', 'icon': Icons.psychology},
      {'title': 'Digital Marketing', 'trend': '+15%', 'icon': Icons.campaign},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: trendingSkills.map((skill) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  skill['icon'] as IconData,
                  color: colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              title: Text(
                skill['title'] as String,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                'Trending ${skill['trend']}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Icon(
                Icons.trending_up_rounded,
                color: colorScheme.primary,
              ),
              onTap: () {
                HapticFeedback.lightImpact();
                ref
                    .read(exploreProvider.notifier)
                    .search(skill['title'] as String);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSkillCard(
    SkillModel skill,
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.go('/video/${skill.id}?source=explore');
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Thumbnail
              if (skill.thumbnailUrl != null)
                Positioned.fill(
                  child: SafeNetworkImage(
                    imageUrl: skill.thumbnailUrl!,
                    fit: BoxFit.cover,
                  ),
                ),

              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        skill.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (skill.category != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            skill.category!,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Bookmark button
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.bookmark_border_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      // Bookmark functionality
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionError(String error, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.error.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded, color: colorScheme.error, size: 32),
          const SizedBox(height: 8),
          Text(
            'Failed to load content',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            error,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  List<Color> _getCategoryColors(int index, ColorScheme colorScheme) {
    final colorSets = [
      [colorScheme.primary, colorScheme.secondary],
      [colorScheme.secondary, colorScheme.tertiary],
      [colorScheme.tertiary, colorScheme.primary],
      [Colors.purple, Colors.deepPurple],
      [Colors.orange, Colors.deepOrange],
      [Colors.teal, Colors.cyan],
    ];
    return colorSets[index % colorSets.length];
  }

  IconData _getCategoryIcon(String category) {
    final iconMap = {
      'Technology': Icons.computer_rounded,
      'Design': Icons.design_services_rounded,
      'Business': Icons.business_rounded,
      'Marketing': Icons.campaign_rounded,
      'Photography': Icons.camera_alt_rounded,
      'Music': Icons.music_note_rounded,
      'Fitness': Icons.fitness_center_rounded,
      'Cooking': Icons.restaurant_rounded,
      'Education': Icons.school_rounded,
      'Art': Icons.palette_rounded,
    };
    return iconMap[category] ?? Icons.category_rounded;
  }
}

// Custom painter for background patterns
class _PatternPainter extends CustomPainter {
  final Color color;

  _PatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw dots pattern
    const spacing = 20.0;
    const radius = 1.5;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Additional helper methods for the new sections
extension ExploreScreenHelpers on _ExploreScreenState {
  Widget _buildFeaturedSkillsGrid(
    List<SkillModel> skills,
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    if (skills.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 280,
      margin: const EdgeInsets.only(bottom: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: skills.length,
        itemBuilder: (context, index) {
          final skill = skills[index];
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 16),
            child: ModernSkillCard(
              skill: skill,
              showBookmark: true,
              isBookmarked: false, // TODO: Check if bookmarked
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkillsGridLoading(BuildContext context) {
    return Container(
      height: 280,
      margin: const EdgeInsets.only(bottom: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            width: 200,
            margin: const EdgeInsets.only(right: 16),
            child: const SkeletonLoader(type: SkeletonType.card, height: 280),
          );
        },
      ),
    );
  }

  Widget _buildRecentlyViewedList(
    List<SkillModel> skills,
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return Container(
      height: 160,
      margin: const EdgeInsets.only(bottom: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: skills.length,
        itemBuilder: (context, index) {
          final skill = skills[index];
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              context.go('/video/${skill.id}?source=explore');
            },
            child: Container(
              width: 140,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // Thumbnail
                    Positioned.fill(
                      child: skill.thumbnailUrl != null
                          ? SafeNetworkImage(
                              imageUrl: skill.thumbnailUrl!,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: colorScheme.primaryContainer,
                              child: Icon(
                                Icons.play_circle_outline_rounded,
                                size: 32,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                    ),

                    // Gradient overlay
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Content
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              skill.title,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Continue',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Play icon
                    const Positioned.fill(
                      child: Center(
                        child: Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
