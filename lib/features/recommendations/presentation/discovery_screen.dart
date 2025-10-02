import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickcore/features/auth/data/user_model.dart';
import 'package:quickcore/features/feed/data/skill_model.dart';
import 'package:quickcore/features/recommendations/providers/recommendation_providers.dart';
import 'package:quickcore/shared/widgets/cached_network_image.dart';
import 'dart:math' as math;
import 'dart:developer' as dev;

class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(discoveryProvider);
    final notifier = ref.read(discoveryProvider.notifier);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => notifier.refresh(),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App Bar
            SliverAppBar(
              pinned: true,
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('Discover'),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Selected Topic Content
            if (state.selectedTopic != null) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => notifier.clearSelectedTopic(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        state.selectedTopic!,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
              ),
              state.topicContent.when(
                data: (skills) => skills.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text('No content found for this topic'),
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.all(16.0),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _SkillCard(skill: skills[index]),
                            childCount: skills.length,
                          ),
                        ),
                      ),
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, stack) => SliverToBoxAdapter(
                  child: Center(child: Text('Error: $error')),
                ),
              ),
            ]
            // Main Discovery Content
            else ...[
              // Personalized Recommendations
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'For You',
                  subtitle: 'Recommended based on your interests',
                  icon: Icons.recommend,
                ),
              ),
              state.personalizedRecommendations.when(
                data: (recommendations) => recommendations.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Card(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'Set your interests in your profile to get personalized recommendations',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      )
                    : SliverToBoxAdapter(
                        child: SizedBox(
                          height: 240,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: recommendations.length,
                            itemBuilder: (context, index) {
                              return _FeaturedSkillCard(
                                skill: recommendations[index],
                                width: 160,
                              );
                            },
                          ),
                        ),
                      ),
                loading: () => const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
                error: (error, stack) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error: $error'),
                  ),
                ),
              ),

              // Trending Content
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Trending Now',
                  subtitle: 'Popular content this week',
                  icon: Icons.trending_up,
                ),
              ),
              state.trendingContent.when(
                data: (trending) => SliverToBoxAdapter(
                  child: SizedBox(
                    height: 240,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: trending.length,
                      itemBuilder: (context, index) {
                        return _FeaturedSkillCard(
                          skill: trending[index],
                          width: 160,
                          showTrendingBadge: true,
                        );
                      },
                    ),
                  ),
                ),
                loading: () => const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
                error: (error, stack) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error: $error'),
                  ),
                ),
              ),

              // Recommended Creators
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Creators to Follow',
                  subtitle: 'Based on your interests',
                  icon: Icons.people,
                ),
              ),
              state.recommendedCreators.when(
                data: (creators) => creators.isEmpty
                    ? const SliverToBoxAdapter(child: SizedBox())
                    : SliverToBoxAdapter(
                        child: SizedBox(
                          height: 120,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            scrollDirection: Axis.horizontal,
                            itemCount: creators.length,
                            itemBuilder: (context, index) {
                              return _CreatorCard(creator: creators[index]);
                            },
                          ),
                        ),
                      ),
                loading: () => const SliverToBoxAdapter(child: SizedBox()),
                error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
              ),

              // Popular Topics
              SliverToBoxAdapter(
                child: _SectionHeader(
                  title: 'Browse by Topic',
                  subtitle: 'Explore content by category',
                  icon: Icons.category,
                ),
              ),
              state.popularTopics.when(
                data: (topics) => SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.0,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final topic = topics[index];
                        return _TopicCard(
                          topic: topic['category'],
                          count: topic['count'],
                          engagementScore: topic['engagement_score'],
                          onTap: () => notifier.selectTopic(topic['category']),
                        );
                      },
                      childCount: topics.length,
                    ),
                  ),
                ),
                loading: () => const SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
                error: (error, stack) => SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error: $error'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        children: [
          Icon(
            icon,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillCard extends StatelessWidget {
  final SkillModel skill;

  const _SkillCard({required this.skill});

  @override
  Widget build(BuildContext context) {
    // Log the thumbnail URL for debugging
    dev.log('SkillCard thumbnail URL: ${skill.thumbnailUrl}');
    dev.log('SkillCard creator name: ${skill.creatorName}');
    
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.go('/skill/${skill.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Expanded(
              child: SafeNetworkImage(
                imageUrl: skill.thumbnailUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    skill.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    skill.creatorName ?? 'Unknown Creator',
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.visibility_outlined,
                        size: 14,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${skill.viewCount}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.favorite_outline,
                        size: 14,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${skill.likeCount}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedSkillCard extends StatelessWidget {
  final SkillModel skill;
  final double width;
  final bool showTrendingBadge;

  const _FeaturedSkillCard({
    required this.skill,
    required this.width,
    this.showTrendingBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    // Log the thumbnail URL for debugging
    dev.log('FeaturedSkillCard thumbnail URL: ${skill.thumbnailUrl}');
    dev.log('FeaturedSkillCard creator name: ${skill.creatorName}');
    
    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () => context.go('/skill/${skill.id}'),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail
                  SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: SafeNetworkImage(
                      imageUrl: skill.thumbnailUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Info
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          skill.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          skill.creatorName ?? 'Unknown Creator',
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.visibility_outlined,
                              size: 14,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${skill.viewCount}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (showTrendingBadge)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.trending_up,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Trending',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
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
}

class _TopicCard extends StatelessWidget {
  final String topic;
  final int count;
  final double engagementScore;
  final VoidCallback onTap;

  const _TopicCard({
    required this.topic,
    required this.count,
    required this.engagementScore,
    required this.onTap,
  });

  Color _getTopicColor(String topic) {
    // Generate a consistent color based on the topic name
    final hash = topic.hashCode;
    final hue = (hash % 360).toDouble();
    return HSVColor.fromAHSV(1.0, hue, 0.6, 0.8).toColor();
  }

  IconData _getTopicIcon(String topic) {
    // Map topics to appropriate icons
    final lowerTopic = topic.toLowerCase();
    if (lowerTopic.contains('design')) return Icons.design_services;
    if (lowerTopic.contains('code') || lowerTopic.contains('programming')) return Icons.code;
    if (lowerTopic.contains('music')) return Icons.music_note;
    if (lowerTopic.contains('photo')) return Icons.photo_camera;
    if (lowerTopic.contains('art')) return Icons.palette;
    if (lowerTopic.contains('business')) return Icons.business;
    if (lowerTopic.contains('health') || lowerTopic.contains('fitness')) return Icons.fitness_center;
    if (lowerTopic.contains('cook')) return Icons.restaurant;
    if (lowerTopic.contains('language')) return Icons.language;
    if (lowerTopic.contains('math')) return Icons.functions;
    if (lowerTopic.contains('science')) return Icons.science;
    return Icons.category;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getTopicColor(topic);
    final icon = _getTopicIcon(topic);

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color,
                color.withOpacity(0.7),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned.fill(
                child: CustomPaint(
                  painter: _PatternPainter(color: Colors.white.withOpacity(0.1)),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(
                          icon,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            topic,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$count videos',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                          ),
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
}

class _CreatorCard extends StatelessWidget {
  final UserModel creator;

  const _CreatorCard({required this.creator});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: () => context.go('/profile/${creator.id}'),
        child: Column(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundImage: creator.avatarUrl != null ? NetworkImage(creator.avatarUrl!) : null,
              child: creator.avatarUrl == null
                  ? const Icon(
                      Icons.person,
                      size: 36,
                      color: Colors.white70,
                    )
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              creator.name ?? 'Unknown',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            Text(
              creator.username != null ? '@${creator.username}' : 'User',
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _PatternPainter extends CustomPainter {
  final Color color;

  _PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final spacing = 20.0;
    final angleInRadians = math.pi / 4; // 45 degrees

    for (double i = -size.width; i <= size.width + size.height; i += spacing) {
      final startX = i;
      final startY = 0.0;
      final endX = i + size.height * math.cos(angleInRadians);
      final endY = size.height * math.sin(angleInRadians);

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 