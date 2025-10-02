import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickcore/features/auth/data/user_model.dart';
import 'package:quickcore/features/profile/providers/profile_providers.dart';
import 'package:quickcore/features/profile/providers/learning_stats_providers.dart';
import 'package:quickcore/features/bookmarks/providers/bookmarks_provider.dart';
import 'package:quickcore/features/profile/presentation/widgets/user_profile_header.dart';
import 'package:quickcore/shared/widgets/cached_network_image.dart';
import 'dart:ui';
import 'dart:developer' as dev;

class LearnerProfilePage extends ConsumerStatefulWidget {
  final UserModel user;
  final bool isCurrentUser;

  const LearnerProfilePage({
    required this.user,
    required this.isCurrentUser,
    super.key,
  });

  @override
  ConsumerState<LearnerProfilePage> createState() => _LearnerProfilePageState();
}

class _LearnerProfilePageState extends ConsumerState<LearnerProfilePage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _contentController;
  late Animation<double> _contentAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _contentAnimation = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    );

    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _contentController.forward();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 0,
              floating: true,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                if (widget.isCurrentUser)
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.settings, color: Colors.white),
                    ),
                    onPressed: () => context.push('/settings'),
                  ),
              ],
            ),
            SliverToBoxAdapter(
              child: UserProfileHeader(
                user: widget.user,
                isCurrentUser: widget.isCurrentUser,
              ),
            ),
            SliverToBoxAdapter(
              child: AnimatedBuilder(
                animation: _contentAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, (1 - _contentAnimation.value) * 30),
                    child: Opacity(
                      opacity: _contentAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    _buildLearningStats(theme),
                    _buildInterestsSection(theme),
                    _buildAchievementsSection(theme),
                    if (widget.isCurrentUser) _buildBecomeTutorCard(theme),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: theme.colorScheme.primary,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(icon: Icon(Icons.history), text: 'Activity'),
                    Tab(icon: Icon(Icons.bookmark), text: 'Bookmarks'),
                    Tab(icon: Icon(Icons.trending_up), text: 'Progress'),
                    Tab(icon: Icon(Icons.emoji_events), text: 'Badges'),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildActivityTab(),
            _buildBookmarksTab(),
            _buildProgressTab(),
            _buildBadgesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningStats(ThemeData theme) {
    final statsAsync = ref.watch(learningStatsProvider(widget.user.id));

    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.colorScheme.secondary.withOpacity(0.8),
                  theme.colorScheme.primary.withOpacity(0.6),
                  theme.colorScheme.tertiary.withOpacity(0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: statsAsync.when(
              data: (stats) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.analytics,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Learning Journey',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildLearningStatCard(
                          'Skills Viewed',
                          stats.skillsViewed.toString(),
                          Icons.visibility,
                          Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildLearningStatCard(
                          'Minutes Learned',
                          stats.minutesLearned.toString(),
                          Icons.access_time,
                          Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildLearningStatCard(
                          'Learning Streak',
                          '${stats.learningStreak} days',
                          Icons.local_fire_department,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildLearningStatCard(
                          'Certificates',
                          '3', // Mock data
                          Icons.workspace_premium,
                          Colors.yellow,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              loading: () => const SizedBox(
                height: 150,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
              error: (error, stack) => Container(
                height: 150,
                child: Center(
                  child: Text(
                    'Error loading stats',
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLearningStatCard(
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const Spacer(),
              TweenAnimationBuilder<int>(
                tween: IntTween(
                  begin: 0,
                  end:
                      int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ??
                      0,
                ),
                duration: const Duration(milliseconds: 1500),
                builder: (context, animatedValue, child) {
                  return Text(
                    value.contains('days') ? value : animatedValue.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsSection(ThemeData theme) {
    final interestsAsync = ref.watch(userInterestsProvider(widget.user.id));

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.interests, color: theme.colorScheme.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Learning Interests',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (widget.isCurrentUser)
                TextButton.icon(
                  onPressed: () => context.push('/interests'),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          interestsAsync.when(
            data: (interests) {
              if (interests.isEmpty) {
                return Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.interests,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.isCurrentUser
                            ? 'Add your learning interests'
                            : 'No interests added yet',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: interests.asMap().entries.map((entry) {
                  final index = entry.key;
                  final interest = entry.value;
                  return TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: Duration(milliseconds: 400 + (index * 100)),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(
                              interest,
                            ).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getCategoryColor(
                                interest,
                              ).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getCategoryIcon(interest),
                                size: 16,
                                color: _getCategoryColor(interest),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                interest,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: _getCategoryColor(interest),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Text('Error loading interests: $error'),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(ThemeData theme) {
    final achievementsAsync = ref.watch(
      userAchievementsProvider(widget.user.id),
    );

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Recent Achievements',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          achievementsAsync.when(
            data: (achievements) {
              final unlockedAchievements = achievements.entries
                  .where((entry) => entry.value)
                  .take(3)
                  .toList();

              if (unlockedAchievements.isEmpty) {
                return Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No achievements unlocked yet',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: unlockedAchievements.length,
                  itemBuilder: (context, index) {
                    final achievement = unlockedAchievements[index];
                    return _buildAchievementBadge(
                      achievement.key,
                      _getAchievementInfo(achievement.key),
                      theme,
                      index,
                    );
                  },
                ),
              );
            },
            loading: () => const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => Text('Error loading achievements: $error'),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(
    String achievementKey,
    Map<String, dynamic> info,
    ThemeData theme,
    int index,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (index * 200)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 80,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    info['icon'] as IconData,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  info['title'] as String,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBecomeTutorCard(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.purple.withOpacity(0.8),
                  Colors.deepPurple.withOpacity(0.6),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.school, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'Ready to Teach?',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Share your knowledge and start earning by becoming a tutor. Create educational content and help others learn.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _handleBecomeTutor(),
                    icon: const Icon(Icons.star),
                    label: const Text('Become a Tutor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.purple,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityTab() {
    final historyAsync = ref.watch(viewHistoryProvider(widget.user.id));

    return historyAsync.when(
      data: (skills) {
        if (skills.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                Text(
                  widget.isCurrentUser
                      ? 'No learning activity yet'
                      : 'No activity to show',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                if (widget.isCurrentUser) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Start watching videos to see your activity here!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: skills.length,
          itemBuilder: (context, index) {
            final skill = skills[index];
            return _buildActivityCard(skill, index);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Error loading activity: $error')),
    );
  }

  Widget _buildActivityCard(dynamic skill, int index) {
    final theme = Theme.of(context);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 20),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          onTap: () => context.push('/video/${skill.id}?source=profile'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 80,
                    height: 60,
                    child: SafeNetworkImage(
                      imageUrl: skill.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorWidget: Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.video_library),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        skill.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'by ${skill.creatorName ?? 'Unknown'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Recently watched',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookmarksTab() {
    final bookmarksAsync = ref.watch(userBookmarksProvider(widget.user.id));

    return bookmarksAsync.when(
      data: (skills) {
        if (skills.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark_border,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.isCurrentUser
                      ? 'No bookmarks yet'
                      : 'No bookmarks to show',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                if (widget.isCurrentUser) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Bookmark videos to save them for later!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: skills.length,
          itemBuilder: (context, index) {
            final skill = skills[index];
            return _buildBookmarkCard(skill, index);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Error loading bookmarks: $error')),
    );
  }

  Widget _buildBookmarkCard(dynamic skill, int index) {
    final theme = Theme.of(context);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 20),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: InkWell(
          onTap: () => context.push('/skill/${skill.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    SafeNetworkImage(
                      imageUrl: skill.thumbnailUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorWidget: Container(
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(Icons.video_library, size: 40),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bookmark,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        skill.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Text(
                        'by ${skill.creatorName ?? 'Unknown'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
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
  }

  Widget _buildProgressTab() {
    // Mock progress data
    final progressData = [
      {'category': 'Flutter', 'progress': 0.8, 'hours': 24},
      {'category': 'Design', 'progress': 0.6, 'hours': 18},
      {'category': 'Business', 'progress': 0.4, 'hours': 12},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: progressData.length,
      itemBuilder: (context, index) {
        final data = progressData[index];
        return _buildProgressCard(data, index);
      },
    );
  }

  Widget _buildProgressCard(Map<String, dynamic> data, int index) {
    final theme = Theme.of(context);
    final progress = data['progress'] as double;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 20),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getCategoryIcon(data['category'] as String),
                    color: _getCategoryColor(data['category'] as String),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      data['category'] as String,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getCategoryColor(data['category'] as String),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: progress),
                duration: Duration(milliseconds: 1000 + (index * 200)),
                curve: Curves.easeOutCubic,
                builder: (context, animatedProgress, child) {
                  return LinearProgressIndicator(
                    value: animatedProgress,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getCategoryColor(data['category'] as String),
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  );
                },
              ),
              const SizedBox(height: 12),
              Text(
                '${data['hours']} hours of learning',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadgesTab() {
    final achievementsAsync = ref.watch(
      userAchievementsProvider(widget.user.id),
    );

    return achievementsAsync.when(
      data: (achievements) {
        final allAchievements = achievements.entries.map((entry) {
          final info = _getAchievementInfo(entry.key);
          return {'key': entry.key, 'unlocked': entry.value, ...info};
        }).toList();

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: allAchievements.length,
          itemBuilder: (context, index) {
            final achievement = allAchievements[index];
            return _buildBadgeCard(achievement, index);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Error loading badges: $error')),
    );
  }

  Widget _buildBadgeCard(Map<String, dynamic> achievement, int index) {
    final theme = Theme.of(context);
    final isUnlocked = achievement['unlocked'] as bool;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: isUnlocked ? 8 : 2,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: isUnlocked
                    ? LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      )
                    : null,
                color: isUnlocked ? null : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    achievement['icon'] as IconData,
                    size: 48,
                    color: isUnlocked ? Colors.white : Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    achievement['title'] as String,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? Colors.white : Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    achievement['description'] as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isUnlocked
                          ? Colors.white.withOpacity(0.9)
                          : Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isUnlocked) ...[
                    const SizedBox(height: 8),
                    Icon(Icons.check_circle, color: Colors.white, size: 20),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleBecomeTutor() async {
    try {
      await ref
          .read(profileNotifierProvider.notifier)
          .updateUserRole(widget.user.id, 'tutor');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Congratulations! You are now a tutor!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back and refresh
        context.go('/profile');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'design':
        return Icons.brush;
      case 'development':
      case 'flutter':
        return Icons.code;
      case 'marketing':
        return Icons.trending_up;
      case 'business':
        return Icons.business;
      case 'photography':
        return Icons.camera_alt;
      case 'music':
        return Icons.music_note;
      case 'cooking':
        return Icons.restaurant;
      case 'fitness':
        return Icons.fitness_center;
      case 'language':
        return Icons.language;
      case 'science':
        return Icons.science;
      case 'math':
        return Icons.calculate;
      case 'art':
        return Icons.palette;
      case 'writing':
        return Icons.create;
      case 'finance':
        return Icons.attach_money;
      case 'technology':
        return Icons.devices;
      case 'health':
        return Icons.favorite;
      default:
        return Icons.school;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'design':
        return Colors.purple;
      case 'development':
      case 'flutter':
        return Colors.blue;
      case 'marketing':
        return Colors.green;
      case 'business':
        return Colors.amber.shade800;
      case 'photography':
        return Colors.indigo;
      case 'music':
        return Colors.pink;
      case 'cooking':
        return Colors.orange;
      case 'fitness':
        return Colors.teal;
      case 'language':
        return Colors.lightBlue;
      case 'science':
        return Colors.deepPurple;
      case 'math':
        return Colors.red;
      case 'art':
        return Colors.deepOrange;
      case 'writing':
        return Colors.brown;
      case 'finance':
        return Colors.green.shade800;
      case 'technology':
        return Colors.blueGrey;
      case 'health':
        return Colors.red.shade400;
      default:
        return Colors.grey;
    }
  }

  Map<String, dynamic> _getAchievementInfo(String key) {
    switch (key) {
      case 'curious_learner':
        return {
          'title': 'Curious Learner',
          'description': 'Watch 10 different skills',
          'icon': Icons.school,
        };
      case 'week_warrior':
        return {
          'title': 'Week Warrior',
          'description': 'Maintain a 7-day streak',
          'icon': Icons.local_fire_department,
        };
      case 'design_novice':
        return {
          'title': 'Design Novice',
          'description': 'Watch 5 design videos',
          'icon': Icons.brush,
        };
      case 'specialist':
        return {
          'title': 'Specialist',
          'description': 'Watch 25 videos in one category',
          'icon': Icons.workspace_premium,
        };
      case 'first_bookmark':
        return {
          'title': 'First Bookmark',
          'description': 'Save your first skill',
          'icon': Icons.bookmark,
        };
      default:
        return {
          'title': 'Achievement',
          'description': 'Unlocked achievement',
          'icon': Icons.emoji_events,
        };
    }
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
