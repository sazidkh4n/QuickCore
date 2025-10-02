import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import 'dart:math' as math;

class LearningPathsWidget extends ConsumerStatefulWidget {
  final Function(LearningPath)? onPathTap;

  const LearningPathsWidget({super.key, this.onPathTap});

  @override
  ConsumerState<LearningPathsWidget> createState() =>
      _LearningPathsWidgetState();
}

class _LearningPathsWidgetState extends ConsumerState<LearningPathsWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _progressController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  final List<LearningPath> _learningPaths = [
    LearningPath(
      id: '1',
      title: 'Flutter Mastery',
      description: 'Complete Flutter development journey',
      totalSkills: 12,
      completedSkills: 7,
      estimatedHours: 45,
      difficulty: 'Intermediate',
      category: 'Mobile Development',
      color: Colors.blue,
      skills: [
        'Flutter Basics',
        'Widgets & Layouts',
        'State Management',
        'Navigation',
        'Animations',
        'Testing',
      ],
      isPopular: true,
    ),
    LearningPath(
      id: '2',
      title: 'UI/UX Design Pro',
      description: 'Master modern design principles',
      totalSkills: 8,
      completedSkills: 3,
      estimatedHours: 32,
      difficulty: 'Beginner',
      category: 'Design',
      color: Colors.purple,
      skills: [
        'Design Principles',
        'Color Theory',
        'Typography',
        'Prototyping',
        'User Research',
      ],
      isPopular: false,
    ),
    LearningPath(
      id: '3',
      title: 'Full Stack Developer',
      description: 'Frontend to backend mastery',
      totalSkills: 15,
      completedSkills: 0,
      estimatedHours: 80,
      difficulty: 'Advanced',
      category: 'Web Development',
      color: Colors.green,
      skills: [
        'HTML/CSS',
        'JavaScript',
        'React',
        'Node.js',
        'Databases',
        'DevOps',
      ],
      isPopular: true,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
    _progressController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressController.dispose();
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
                      color: colorScheme.surface.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: colorScheme.outline.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        _buildHeader(theme, colorScheme),

                        // Learning paths list
                        _buildPathsList(theme, colorScheme),

                        // Create custom path button
                        _buildCreatePathButton(theme, colorScheme),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.indigo, Colors.purple]),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.route_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Learning Paths',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  'Structured learning journeys',
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
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.secondary],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'NEW',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPathsList(ThemeData theme, ColorScheme colorScheme) {
    return SizedBox(
      height: 380, // Increased from 350px to 380px for more space
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: _learningPaths.length,
        itemBuilder: (context, index) {
          final path = _learningPaths[index];
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

              return Transform.scale(
                scale: itemAnimation.value,
                child: Opacity(
                  opacity: itemAnimation.value,
                  child: _buildPathCard(path, theme, colorScheme),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildPathCard(
    LearningPath path,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final progress = path.completedSkills / path.totalSkills;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onPathTap?.call(path);
      },
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: path.color.withOpacity(0.3)),
        ),
        child: Stack(
          children: [
            // Background gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      path.color.withOpacity(0.1),
                      path.color.withOpacity(0.05),
                      Colors.transparent,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // Changed from default to min
                children: [
                  // Header with badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: path.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getPathIcon(path.category),
                          color: path.color,
                          size: 20,
                        ),
                      ),
                      const Spacer(),
                      if (path.isPopular)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_fire_department_rounded,
                                size: 12,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'Popular',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Title and description
                  Text(
                    path.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    path.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 16),

                  // Progress section
                  Row(
                    children: [
                      Text(
                        'Progress',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${path.completedSkills}/${path.totalSkills}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: path.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Progress bar
                  AnimatedBuilder(
                    animation: _progressController,
                    builder: (context, child) {
                      return LinearProgressIndicator(
                        value: progress * _progressController.value,
                        backgroundColor: path.color.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(path.color),
                        borderRadius: BorderRadius.circular(4),
                      );
                    },
                  ),

                  const SizedBox(height: 12), // Reduced from 16 to 12

                  // Skills preview - Limit to max 2 skills to prevent overflow
                  Text(
                    'Skills included:',
                    style: theme.textTheme.labelSmall?.copyWith( // Changed to labelSmall
                      color: colorScheme.onSurface.withOpacity(0.8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4), // Reduced from 8 to 4

                  // Only display 2 skills max to prevent overflow
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: path.skills.take(2).map((skill) { // Reduced from 3 to 2 skills
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3, // Reduced vertical padding from 4 to 3
                        ),
                        decoration: BoxDecoration(
                          color: path.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          skill,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: path.color,
                            fontWeight: FontWeight.w500,
                            fontSize: 10, // Added explicit smaller font size
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  if (path.skills.length > 2) ...[
                    const SizedBox(height: 2), // Reduced from 4 to 2
                    Text(
                      '+${path.skills.length - 2} more', // Changed from -3 to -2
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        fontStyle: FontStyle.italic,
                        fontSize: 10, // Added explicit smaller font size
                      ),
                    ),
                  ],

                  const SizedBox(height: 12), // Reduced from 16 to 12

                  // Footer info
                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        size: 16,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${path.estimatedHours}h',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getDifficultyColor(
                            path.difficulty,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          path.difficulty,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _getDifficultyColor(path.difficulty),
                            fontWeight: FontWeight.w600,
                          ),
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
    );
  }

  Widget _buildCreatePathButton(ThemeData theme, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            // Navigate to create custom path
          },
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            side: BorderSide(color: colorScheme.primary),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_road_rounded,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Create Custom Learning Path',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPathIcon(String category) {
    switch (category.toLowerCase()) {
      case 'mobile development':
        return Icons.phone_android_rounded;
      case 'design':
        return Icons.palette_rounded;
      case 'web development':
        return Icons.web_rounded;
      default:
        return Icons.school_rounded;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}

class LearningPath {
  final String id;
  final String title;
  final String description;
  final int totalSkills;
  final int completedSkills;
  final int estimatedHours;
  final String difficulty;
  final String category;
  final Color color;
  final List<String> skills;
  final bool isPopular;

  LearningPath({
    required this.id,
    required this.title,
    required this.description,
    required this.totalSkills,
    required this.completedSkills,
    required this.estimatedHours,
    required this.difficulty,
    required this.category,
    required this.color,
    required this.skills,
    required this.isPopular,
  });
}
