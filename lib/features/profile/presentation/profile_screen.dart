import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickcore/features/auth/data/user_model.dart';
import 'package:quickcore/features/auth/providers/auth_provider.dart';
import 'package:quickcore/features/profile/providers/profile_providers.dart';
import 'package:quickcore/features/profile/providers/learning_stats_providers.dart';
import 'package:quickcore/features/profile/presentation/interests_screen.dart';
import 'package:quickcore/features/profile/presentation/tutor_profile_screen.dart';
import 'package:quickcore/features/bookmarks/providers/bookmarks_provider.dart';
import 'package:quickcore/features/feed/data/skill_model.dart';
import 'package:quickcore/shared/widgets/cached_network_image.dart';
import 'dart:developer' as dev;

class ProfileScreen extends ConsumerStatefulWidget {
  final String? userId;
  
  const ProfileScreen({this.userId, super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final currentUser = authState.value;

    // If userId is not provided, use the current user's ID
    final String targetUserId = widget.userId ?? currentUser?.id ?? '';
    final bool isCurrentUser = widget.userId == null || widget.userId == currentUser?.id;
    
    return authState.when(
      data: (user) {
        if (user == null) {
          return const Center(child: Text('Please log in to view profiles'));
        }

        final userAsync = ref.watch(userProfileProvider(targetUserId));
        
        return userAsync.when(
          data: (profileUser) {
            // Check if user is a tutor
            if (profileUser.role == 'tutor') {
              return TutorProfileScreen(user: profileUser);
            }

            // Default to learner profile
            return Scaffold(
              body: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      expandedHeight: 0,
                      floating: true,
                      pinned: true,
                      actions: [
                        if (isCurrentUser)
                          IconButton(
                            icon: const Icon(Icons.settings),
                            onPressed: () => context.push('/settings'),
                          ),
                      ],
                    ),
                    SliverToBoxAdapter(
                      child: _ProfileHeader(user: profileUser),
                    ),
                    SliverToBoxAdapter(
                      child: _LearningStats(userId: targetUserId),
                    ),
                    // Add the "Become a Tutor" button here for current user
                    if (isCurrentUser)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Card(
                            elevation: 4,
                            color: Theme.of(context).colorScheme.primaryContainer,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Share Your Knowledge',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Become a tutor and start earning by creating educational content',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                                        backgroundColor: Theme.of(context).colorScheme.primary,
                                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                      ),
                                      icon: const Icon(Icons.school),
                                      label: const Text('Become a Tutor'),
                                      onPressed: () async {
                                        try {
                                          // Show loading indicator
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Updating your role to tutor...')),
                                          );
                                          
                                          // Use the profile notifier to update role
                                          await ref.read(profileNotifierProvider.notifier).updateUserRole(profileUser.id, 'tutor');
                                          
                                          // Force refresh providers
                                          ref.invalidate(authProvider);
                                          ref.invalidate(userProfileProvider(profileUser.id));
                                          
                                          // Explicitly reload the user data
                                          await ref.read(authProvider.notifier).reloadUser();
                                          
                                          // Show success message
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('You are now a tutor! Your profile will update shortly.')),
                                          );
                                          
                                          // Force a complete rebuild by navigating to a different page and back
                                          if (context.mounted) {
                                            // Navigate to home page temporarily
                                            context.go('/');
                                            
                                            // Wait a moment before navigating back to profile
                                            Future.delayed(const Duration(seconds: 1), () {
                                              if (context.mounted) {
                                                // Return to profile page to see tutor view
                                                context.go('/profile');
                                              }
                                            });
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Error: ${e.toString()}')),
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: _AchievementsBadges(userId: targetUserId),
                    ),
                    SliverToBoxAdapter(
                      child: _MyInterests(userId: targetUserId),
                    ),
                    SliverPersistentHeader(
                      delegate: _SliverTabBarDelegate(
                        TabBar(
                          controller: _tabController,
                          labelColor: Theme.of(context).colorScheme.primary,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Theme.of(context).colorScheme.primary,
                          tabs: const [
                            Tab(text: 'Liked Skills'),
                            Tab(text: 'Bookmarked'),
                            Tab(text: 'History'),
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
                    _LikedSkillsTab(userId: targetUserId),
                    _BookmarkedSkillsTab(userId: targetUserId),
                    _HistoryTab(userId: targetUserId),
                  ],
                ),
              ),
              floatingActionButton: isCurrentUser ? _buildFloatingActionButton(context) : null,
            );
          },
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (err, stack) => Scaffold(
            body: Center(
              child: Text('Error loading profile: ${err.toString()}'),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Text('Error: ${err.toString()}'),
        ),
      ),
    );
  }
  
  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton.extended(
            onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => _QuickActionsSheet(),
        );
      },
      icon: const Icon(Icons.bolt),
      label: const Text('Quick Actions'),
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }
}

class _QuickActionsSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _ActionButton(
            icon: Icons.edit,
            label: 'Edit Profile',
            onTap: () {
              Navigator.pop(context);
              context.push('/edit-profile');
            },
          ),
          _ActionButton(
            icon: Icons.interests,
            label: 'Update Interests',
            onTap: () {
              Navigator.pop(context);
              context.push('/interests');
            },
          ),
          _ActionButton(
            icon: Icons.settings,
            label: 'Settings',
            onTap: () {
              Navigator.pop(context);
              context.push('/settings');
            },
          ),
          _ActionButton(
            icon: Icons.upload,
            label: 'Upload New Skill',
            onTap: () {
              Navigator.pop(context);
              context.push('/upload');
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
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

class _LikedSkillsTab extends ConsumerWidget {
  final String userId;
  
  const _LikedSkillsTab({required this.userId});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedSkillsAsync = ref.watch(likedSkillsProvider(userId));
    
    return likedSkillsAsync.when(
      data: (skills) {
        if (skills.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No liked skills'),
                SizedBox(height: 8),
                Text(
                  'Skills you like will appear here',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }
        
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: skills.length,
          itemBuilder: (context, index) {
            final skill = skills[index];
            return _SkillCard(skill: skill, index: index);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}

class _BookmarkedSkillsTab extends ConsumerWidget {
  final String userId;
  
  const _BookmarkedSkillsTab({required this.userId});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(userBookmarksProvider(userId));
    
    return bookmarksAsync.when(
      data: (skills) {
        if (skills.isEmpty) {
          return const Center(
            child: Text('No bookmarked skills yet'),
          );
        }
        
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: skills.length,
          itemBuilder: (context, index) {
            final skill = skills[index];
            return _SkillCard(skill: skill, index: index);
          },
        );
          },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Text('Error loading bookmarks: ${err.toString()}'),
      ),
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  final String userId;
  
  const _HistoryTab({required this.userId});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(viewHistoryProvider(userId));
    
    return historyAsync.when(
      data: (skills) {
        if (skills.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
            children: [
                Icon(Icons.history, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No watch history'),
                SizedBox(height: 8),
                Text(
                  'Skills you watch will appear here',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }
        
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: skills.length,
          itemBuilder: (context, index) {
            final skill = skills[index];
            return _SkillCard(skill: skill, index: index);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}

class _LearningStats extends ConsumerWidget {
  final String userId;
  
  const _LearningStats({required this.userId});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(learningStatsProvider(userId));
    
    return statsAsync.when(
      data: (stats) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.8),
                Theme.of(context).colorScheme.secondary.withOpacity(0.7),
                ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
              _AnimatedStatItem(
                icon: Icons.visibility_outlined,
                value: stats.skillsViewed.toString(),
                label: 'Skills Viewed',
                color: Colors.white,
              ),
              _AnimatedStatItem(
                icon: Icons.timer_outlined,
                value: stats.minutesLearned.toString(),
                label: 'Minutes Learned',
                color: Colors.white,
              ),
              _AnimatedStatItem(
                icon: Icons.local_fire_department,
                value: stats.learningStreak.toString(),
                label: 'Daily Streak',
                iconColor: Colors.orange,
                color: Colors.white,
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => const SizedBox(),
    );
  }
}

class _AnimatedStatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? iconColor;
  final Color color;
  
  const _AnimatedStatItem({
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor,
    this.color = Colors.black,
  });
  
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 20),
            child: Column(
              children: [
                Icon(icon, size: 32, color: iconColor ?? color),
                const SizedBox(height: 8),
                TweenAnimationBuilder<int>(
                  tween: IntTween(begin: 0, end: int.parse(this.value)),
                  duration: const Duration(milliseconds: 1200),
                  builder: (context, value, child) {
                    return Text(
                      value.toString(),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    );
                  },
                ),
                Text(
                  label, 
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: color.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
        );
      },
    );
  }
}

class _AchievementsBadges extends ConsumerWidget {
  final String userId;
  
  const _AchievementsBadges({required this.userId});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievementsAsync = ref.watch(userAchievementsProvider(userId));
    
    return achievementsAsync.when(
      data: (achievements) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Achievements',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${achievements.values.where((v) => v).length}/${achievements.length}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 130,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _EnhancedAchievementBadge(
                    title: 'Curious Learner',
                    description: 'Watch 10 different skills',
                    icon: Icons.school,
                    isUnlocked: achievements['curious_learner'] ?? false,
                    index: 0,
                  ),
                  _EnhancedAchievementBadge(
                    title: 'Week-Long Warrior',
                    description: 'Maintain a 7-day learning streak',
                    icon: Icons.local_fire_department,
                    isUnlocked: achievements['week_warrior'] ?? false,
                    index: 1,
                  ),
                  _EnhancedAchievementBadge(
                    title: 'Design Novice',
                    description: 'Watch 5 videos in the "Design" category',
                    icon: Icons.brush,
                    isUnlocked: achievements['design_novice'] ?? false,
                    index: 2,
                  ),
                  _EnhancedAchievementBadge(
                    title: 'Specialist',
                    description: 'Watch 25 videos in a single category',
                    icon: Icons.workspace_premium,
                    isUnlocked: achievements['specialist'] ?? false,
                    index: 3,
                  ),
                  _EnhancedAchievementBadge(
                    title: 'First Bookmark',
                    description: 'Save your first skill',
                    icon: Icons.bookmark,
                    isUnlocked: achievements['first_bookmark'] ?? false,
                    index: 4,
                  ),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(height: 120),
      error: (err, stack) => const SizedBox(),
    );
  }
}

class _EnhancedAchievementBadge extends StatefulWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isUnlocked;
  final int index;
  
  const _EnhancedAchievementBadge({
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.index,
  });
  
  @override
  State<_EnhancedAchievementBadge> createState() => _EnhancedAchievementBadgeState();
}

class _EnhancedAchievementBadgeState extends State<_EnhancedAchievementBadge> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    
    // Stagger the animations
    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(
                    widget.icon,
                    color: widget.isUnlocked
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(widget.title),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.description),
                  const SizedBox(height: 16),
                  if (widget.isUnlocked)
                    const Text(
                      '🎉 Achievement Unlocked!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    )
                  else
                    Text(
                      'Keep going to unlock this achievement!',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
        child: Container(
          width: 90,
          margin: const EdgeInsets.only(right: 16),
          child: Column(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: widget.isUnlocked
                      ? LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: widget.isUnlocked ? null : Colors.grey.shade200,
                  boxShadow: widget.isUnlocked
                      ? [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Icon(
                    widget.icon,
                    color: widget.isUnlocked
                        ? Colors.white
                        : Colors.grey.shade400,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: widget.isUnlocked ? FontWeight.bold : null,
                  color: widget.isUnlocked 
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (widget.isUnlocked)
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 14,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MyInterests extends ConsumerWidget {
  final String userId;
  
  const _MyInterests({required this.userId});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interestsAsync = ref.watch(userInterestsProvider(userId));
    
    return interestsAsync.when(
      data: (interests) {
        if (interests.isEmpty) {
          return const SizedBox();
        }
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.only(top: 16, bottom: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.interests,
                          color: Theme.of(context).colorScheme.primary,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'My Interests',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => InterestsScreen(userId: userId),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ],
                ),
              ),
              _InterestTagsList(interests: interests),
            ],
          ),
        );
      },
      loading: () => const SizedBox(),
      error: (err, stack) => const SizedBox(),
    );
  }
}

class _InterestTagsList extends StatefulWidget {
  final List<String> interests;
  
  const _InterestTagsList({required this.interests});
  
  @override
  State<_InterestTagsList> createState() => _InterestTagsListState();
}

class _InterestTagsListState extends State<_InterestTagsList> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: widget.interests.length,
        itemBuilder: (context, index) {
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: 1),
            duration: Duration(milliseconds: 400 + (index * 100)),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      avatar: _getCategoryIcon(widget.interests[index]),
                      label: Text(widget.interests[index]),
                      backgroundColor: _getCategoryColor(widget.interests[index], context).withOpacity(0.15),
                      labelStyle: TextStyle(
                        color: _getCategoryColor(widget.interests[index], context),
                        fontWeight: FontWeight.w500,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      onPressed: () {
                        // Navigate to explore page with this category filter
                        context.push('/explore?category=${widget.interests[index]}');
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
  
  Widget _getCategoryIcon(String category) {
    IconData icon;
    
    switch (category.toLowerCase()) {
      case 'design':
        icon = Icons.brush;
        break;
      case 'development':
        icon = Icons.code;
        break;
      case 'marketing':
        icon = Icons.trending_up;
        break;
      case 'business':
        icon = Icons.business;
        break;
      case 'photography':
        icon = Icons.camera_alt;
        break;
      case 'music':
        icon = Icons.music_note;
        break;
      case 'cooking':
        icon = Icons.restaurant;
        break;
      case 'fitness':
        icon = Icons.fitness_center;
        break;
      case 'language':
        icon = Icons.language;
        break;
      case 'science':
        icon = Icons.science;
        break;
      case 'math':
        icon = Icons.calculate;
        break;
      case 'art':
        icon = Icons.palette;
        break;
      case 'writing':
        icon = Icons.create;
        break;
      case 'finance':
        icon = Icons.attach_money;
        break;
      case 'technology':
        icon = Icons.devices;
        break;
      case 'health':
        icon = Icons.favorite;
        break;
      default:
        icon = Icons.tag;
    }
    
    return Icon(icon, size: 16);
  }
  
  Color _getCategoryColor(String category, BuildContext context) {
    final theme = Theme.of(context);
    
    switch (category.toLowerCase()) {
      case 'design':
        return Colors.purple;
      case 'development':
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
        return theme.colorScheme.primary;
    }
  }
}

class _ProfileHeader extends ConsumerWidget {
  final UserModel user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // Log avatar URL for debugging
    dev.log('_ProfileHeader avatar URL: ${user.avatarUrl}');

    return Stack(
        children: [
        // Background gradient
        Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        
        // Content
        Column(
          children: [
            const SizedBox(height: 100),
            // Avatar with border
            Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.scaffoldBackgroundColor,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Hero(
                  tag: 'profile-avatar-${user.id}',
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                    child: ClipOval(
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                          ? SafeNetworkImage(
                              imageUrl: user.avatarUrl,
                              fit: BoxFit.cover,
                              errorWidget: Icon(Icons.person, size: 50, color: theme.colorScheme.primary),
                            )
                          : Icon(Icons.person, size: 50, color: theme.colorScheme.primary),
                      ),
                    ),
                  ),
                ),
              ),
          ),
          const SizedBox(height: 16),
            
            // Name and username with animation
            _AnimatedText(
              text: user.name ?? 'No Name',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          if (user.username != null)
              _AnimatedText(
                text: '@${user.username!}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
                delay: 200,
              ),
          if (user.bio != null && user.bio!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _AnimatedText(
                  text: user.bio!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                  delay: 300,
                ),
              ),
          ],
          const SizedBox(height: 24),
            
            // Stats row with animations
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: _AnimatedStatsRow(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ],
    );
  }
}

class _AnimatedText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final int delay;

  const _AnimatedText({
    required this.text,
    this.style,
    this.textAlign = TextAlign.center,
    this.delay = 0,
  });

  @override
  State<_AnimatedText> createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<_AnimatedText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideIn = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeIn,
          child: SlideTransition(
            position: _slideIn,
            child: Text(
              widget.text,
              style: widget.style,
              textAlign: widget.textAlign,
            ),
          ),
        );
      },
    );
  }
}

class _AnimatedStatsRow extends ConsumerStatefulWidget {
  const _AnimatedStatsRow();

  @override
  ConsumerState<_AnimatedStatsRow> createState() => _AnimatedStatsRowState();
}

class _AnimatedStatsRowState extends ConsumerState<_AnimatedStatsRow> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // These would be populated by providers, hardcoded for now
              _ProfileStat(label: 'Following', value: '123'),
              _ProfileStat(label: 'Followers', value: '45k'),
              _ProfileStat(label: 'Likes', value: '1.2M'),
            ],
          ),
          ),
        );
      },
    );
  }
}

class _SkillCard extends StatefulWidget {
  final SkillModel skill;
  final int index;
  
  const _SkillCard({
    required this.skill,
    required this.index,
  });
  
  @override
  State<_SkillCard> createState() => _SkillCardState();
}

class _SkillCardState extends State<_SkillCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    
    // Stagger the animations
    Future.delayed(Duration(milliseconds: 100 * widget.index % 8), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Log thumbnail URL for debugging
    dev.log('_SkillCard thumbnail URL: ${widget.skill.thumbnailUrl}');
    dev.log('_SkillCard creator name: ${widget.skill.creatorName}');
    dev.log('_SkillCard creator avatar URL: ${widget.skill.creatorAvatarUrl}');
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.2),
        child: InkWell(
          onTap: () {
            // Navigate to video detail or play video
            context.push('/video/${widget.skill.id}?source=profile');
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  // Thumbnail
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: SafeNetworkImage(
                      imageUrl: widget.skill.thumbnailUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorWidget: Container(
                        color: Colors.grey.shade800,
                        child: const Center(child: Icon(Icons.play_arrow, color: Colors.white, size: 40)),
                      ),
                    ),
                  ),
                  
                  // Play button overlay
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.8),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  
                  // Duration chip
                  if (widget.skill.duration != null)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _formatDuration(widget.skill.duration!),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.skill.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                          child: ClipOval(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: widget.skill.creatorAvatarUrl != null && widget.skill.creatorAvatarUrl!.isNotEmpty
                                ? SafeNetworkImage(
                                    imageUrl: widget.skill.creatorAvatarUrl,
                                    fit: BoxFit.cover,
                                    errorWidget: Icon(Icons.person, size: 10, color: theme.colorScheme.primary),
                                  )
                                : Icon(Icons.person, size: 10, color: theme.colorScheme.primary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.skill.creatorName ?? 'Unknown Creator',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
  
  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}