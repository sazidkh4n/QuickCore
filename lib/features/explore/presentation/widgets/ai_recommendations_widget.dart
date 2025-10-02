import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickcore/features/feed/data/skill_model.dart';
import 'package:quickcore/shared/widgets/cached_network_image.dart';
import 'dart:ui';
import 'dart:math' as math;

class AIRecommendationsWidget extends ConsumerStatefulWidget {
  final Function(SkillModel)? onSkillTap;

  const AIRecommendationsWidget({super.key, this.onSkillTap});

  @override
  ConsumerState<AIRecommendationsWidget> createState() =>
      _AIRecommendationsWidgetState();
}

class _AIRecommendationsWidgetState
    extends ConsumerState<AIRecommendationsWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _aiPulseController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _aiPulseAnimation;

  // Mock AI recommendations data
  final List<AIRecommendation> _recommendations = [
    AIRecommendation(
      skill: SkillModel(
        id: '1',
        title: 'Advanced Flutter Animations',
        description: 'Master complex animations in Flutter',
        videoUrl: 'https://example.com/video1.mp4', // Required field
        thumbnailUrl: 'https://picsum.photos/300/200?random=1',
        category: 'Flutter',
        creatorName: 'John Doe',
        viewCount: 15420,
        likeCount: 892,
        createdAt: DateTime.now(), // Required field
      ),
      confidence: 0.95,
      reason: 'Based on your recent Flutter projects',
      tags: ['Animation', 'UI/UX', 'Advanced'],
    ),
    AIRecommendation(
      skill: SkillModel(
        id: '2',
        title: 'State Management with Riverpod',
        description: 'Learn modern state management',
        videoUrl: 'https://example.com/video2.mp4', // Required field
        thumbnailUrl: 'https://picsum.photos/300/200?random=2',
        category: 'Flutter',
        creatorName: 'Jane Smith',
        viewCount: 12340,
        likeCount: 567,
        createdAt: DateTime.now(), // Required field
      ),
      confidence: 0.88,
      reason: 'Recommended for Flutter developers',
      tags: ['State Management', 'Architecture'],
    ),
    AIRecommendation(
      skill: SkillModel(
        id: '3',
        title: 'Machine Learning Basics',
        description: 'Introduction to ML concepts',
        videoUrl: 'https://example.com/video3.mp4', // Required field
        thumbnailUrl: 'https://picsum.photos/300/200?random=3',
        category: 'AI/ML',
        creatorName: 'Dr. Alex Johnson',
        viewCount: 23450,
        likeCount: 1234,
        createdAt: DateTime.now(), // Required field
      ),
      confidence: 0.82,
      reason: 'Trending in your interests',
      tags: ['Machine Learning', 'Python', 'Beginner'],
    ),
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _aiPulseController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _aiPulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _aiPulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
    _aiPulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _aiPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colorScheme.surface.withOpacity(0.9),
                          colorScheme.primaryContainer.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with AI branding
                        _buildHeader(theme, colorScheme),

                        // Recommendations list
                        _buildRecommendationsList(theme, colorScheme),

                        // View all button
                        _buildViewAllButton(theme, colorScheme),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _aiPulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _aiPulseAnimation.value,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple, Colors.blue, Colors.cyan],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.psychology_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'AI Recommendations',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.purple, Colors.blue],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'BETA',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  'Personalized for you',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Learning',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsList(ThemeData theme, ColorScheme colorScheme) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: _recommendations.length,
      itemBuilder: (context, index) {
        final recommendation = _recommendations[index];
        final delay = index * 0.1;

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            // Ensure delay values don't cause Interval to exceed 1.0
            final beginValue = math.min(0.3 + delay, 0.9);
            // Make sure endValue is always between beginValue and 1.0
            final endValue = math.max(beginValue + 0.1, math.min(0.9 + delay, 1.0));
            
            final itemAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: _animationController,
                curve: Interval(
                  beginValue,
                  endValue,
                  curve: Curves.easeOut,
                ),
              ),
            );

            return Transform.translate(
              offset: Offset(30 * (1 - itemAnimation.value), 0),
              child: Opacity(
                opacity: itemAnimation.value,
                child: _buildRecommendationCard(
                  recommendation,
                  theme,
                  colorScheme,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRecommendationCard(
    AIRecommendation recommendation,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onSkillTap?.call(recommendation.skill);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getConfidenceColor(
              recommendation.confidence,
            ).withOpacity(0.3),
          ),
        ),
        child: Stack(
          children: [
            // Background gradient based on confidence
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      _getConfidenceColor(
                        recommendation.confidence,
                      ).withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 80,
                      height: 60,
                      child: recommendation.skill.thumbnailUrl != null
                          ? SafeNetworkImage(
                              imageUrl: recommendation.skill.thumbnailUrl!,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: colorScheme.primaryContainer,
                              child: Icon(
                                Icons.play_circle_outline_rounded,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and confidence
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                recommendation.skill.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getConfidenceColor(
                                  recommendation.confidence,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${(recommendation.confidence * 100).toInt()}%',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: _getConfidenceColor(
                                    recommendation.confidence,
                                  ),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        // AI reason
                        Text(
                          recommendation.reason,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.7),
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        // Tags
                        Wrap(
                          spacing: 6,
                          children: recommendation.tags.take(3).map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                tag,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewAllButton(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            // Navigate to full AI recommendations page
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 20),
              const SizedBox(width: 8),
              Text(
                'View All AI Recommendations',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.9) return Colors.green;
    if (confidence >= 0.8) return Colors.blue;
    if (confidence >= 0.7) return Colors.orange;
    return Colors.red;
  }
}

class AIRecommendation {
  final SkillModel skill;
  final double confidence;
  final String reason;
  final List<String> tags;

  AIRecommendation({
    required this.skill,
    required this.confidence,
    required this.reason,
    required this.tags,
  });
}
