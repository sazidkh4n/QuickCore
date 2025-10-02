import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickcore/features/feed/data/skill_model.dart';
import 'package:quickcore/shared/widgets/cached_network_image.dart';
import 'package:quickcore/features/explore/providers/explore_provider.dart';
import 'dart:ui';

class ModernSkillCard extends ConsumerStatefulWidget {
  final SkillModel skill;
  final VoidCallback? onTap;
  final bool showBookmark;
  final bool isBookmarked;

  const ModernSkillCard({
    super.key,
    required this.skill,
    this.onTap,
    this.showBookmark = true,
    this.isBookmarked = false,
  });

  @override
  ConsumerState<ModernSkillCard> createState() => _ModernSkillCardState();
}

class _ModernSkillCardState extends ConsumerState<ModernSkillCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _bookmarkController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _bookmarkAnimation;

  bool _isBookmarked = false;
  
  // Helper method to format count numbers (e.g. 1500 -> 1.5K)
  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.isBookmarked;

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _bookmarkController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _bookmarkAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _bookmarkController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _bookmarkController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  void _onTap() {
    HapticFeedback.lightImpact();
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      context.go('/video/${widget.skill.id}?source=explore');
    }
  }

  void _toggleBookmark() async {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    _bookmarkController.forward().then((_) {
      _bookmarkController.reverse();
    });

    HapticFeedback.mediumImpact();

    try {
      if (_isBookmarked) {
        await ref.read(exploreProvider.notifier).bookmarkSkill(widget.skill.id);
      } else {
        await ref
            .read(exploreProvider.notifier)
            .unbookmarkSkill(widget.skill.id);
      }
    } catch (e) {
      // Revert state on error
      setState(() {
        _isBookmarked = !_isBookmarked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: _onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    // Background image
                    Positioned.fill(
                      child: Hero(
                        tag: 'explore-skill-${widget.skill.id}',
                        child: widget.skill.thumbnailUrl != null
                            ? SafeNetworkImage(
                                imageUrl: widget.skill.thumbnailUrl!,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      colorScheme.primaryContainer,
                                      colorScheme.secondaryContainer,
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.play_circle_outline_rounded,
                                    size: 64,
                                    color: colorScheme.onPrimaryContainer
                                        .withOpacity(0.7),
                                  ),
                                ),
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
                              Colors.black.withOpacity(0.3),
                              Colors.black.withOpacity(0.8),
                            ],
                            stops: const [0.0, 0.6, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // Glass morphism overlay for content
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: ClipRRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              border: Border(
                                top: BorderSide(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Title
                                Text(
                                  widget.skill.title,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                const SizedBox(height: 8),

                                // Category and stats - Replace Row with Wrap
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    if (widget.skill.category != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8, // Reduced from 12
                                          vertical: 4, // Reduced from 6
                                        ),
                                        constraints: BoxConstraints(
                                          maxWidth: 120, // Limit width
                                        ),
                                        decoration: BoxDecoration(
                                          color: colorScheme.primary
                                              .withOpacity(0.9),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          widget.skill.category!,
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 10, // Add explicit font size
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                    // View count
                                    if (widget.skill.viewCount != null)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.visibility_rounded,
                                            size: 14, // Reduced from 16
                                            color: Colors.white.withOpacity(0.8),
                                          ),
                                          const SizedBox(width: 2), // Reduced from 4
                                          Text(
                                            _formatCount(widget.skill.viewCount!),
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  color: Colors.white.withOpacity(0.8),
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 10, // Add explicit font size
                                                ),
                                          ),
                                        ],
                                      ),

                                    // Like count
                                    if (widget.skill.likeCount > 0)
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.favorite_rounded,
                                            size: 14, // Reduced from 16
                                            color: Colors.red.withOpacity(0.8),
                                          ),
                                          const SizedBox(width: 2), // Reduced from 4
                                          Text(
                                            _formatCount(widget.skill.likeCount),
                                            style: theme.textTheme.labelSmall
                                                ?.copyWith(
                                                  color: Colors.white.withOpacity(0.8),
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 10, // Add explicit font size
                                                ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Creator info
                                if (widget.skill.creatorName != null)
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 12,
                                        backgroundColor: Colors.white
                                            .withOpacity(0.2),
                                        child: Icon(
                                          Icons.person_rounded,
                                          size: 16,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'by ${widget.skill.creatorName}',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: Colors.white.withOpacity(
                                                  0.9,
                                                ),
                                                fontWeight: FontWeight.w500,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Bookmark button
                    if (widget.showBookmark)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: AnimatedBuilder(
                          animation: _bookmarkAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _bookmarkAnimation.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: _toggleBookmark,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Icon(
                                        _isBookmarked
                                            ? Icons.bookmark_rounded
                                            : Icons.bookmark_border_rounded,
                                        color: _isBookmarked
                                            ? colorScheme.primary
                                            : Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    // Play button overlay
                    Positioned.fill(
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.play_arrow_rounded,
                            size: 48,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ),

                    // Trending badge
                    // Removed isTrending check as it's not in the model
                    // Uncomment and implement when isTrending is added to SkillModel
                    /*
                    Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.orange, Colors.deepOrange],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.trending_up_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Trending',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    */
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
