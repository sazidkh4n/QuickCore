import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/feed/presentation/widgets/video_skeleton_loader.dart';

/// A comprehensive skeleton loader system for the QuickCore app
/// Provides various skeleton types with professional animations

class SkeletonLoader extends StatefulWidget {
  final SkeletonType type;
  final int itemCount;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final bool showShimmer;

  const SkeletonLoader({
    super.key,
    required this.type,
    this.itemCount = 1,
    this.width,
    this.height,
    this.padding,
    this.showShimmer = true,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _pulseController;
  late AnimationController _staggerController;

  late Animation<double> _shimmerAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _staggerAnimation;

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _shimmerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut),
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _staggerAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _staggerController, curve: Curves.easeOut),
    );

    if (widget.showShimmer) {
      _shimmerController.repeat();
    }
    _pulseController.repeat(reverse: true);
    _staggerController.forward();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      padding: widget.padding,
      child: _buildSkeletonByType(),
    );
  }

  Widget _buildSkeletonByType() {
    switch (widget.type) {
      case SkeletonType.feed:
        return _buildFeedSkeleton();
      case SkeletonType.card:
        return _buildCardSkeleton();
      case SkeletonType.list:
        return _buildListSkeleton();
      case SkeletonType.profile:
        return _buildProfileSkeleton();
      case SkeletonType.chat:
        return _buildChatSkeleton();
      case SkeletonType.explore:
        return _buildExploreSkeleton();
      case SkeletonType.upload:
        return _buildUploadSkeleton();
    }
  }

  Widget _buildFeedSkeleton() {
    return ListView.builder(
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return SizedBox(
          height: MediaQuery.of(context).size.height,
          child: const VideoSkeletonLoader(),
        );
      },
    );
  }

  Widget _buildCardSkeleton() {
    return ListView.builder(
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _staggerAnimation,
          builder: (context, child) {
            final delay = index * 100.0;
            final progress = (_staggerAnimation.value * 1000 - delay) / 600;
            final opacity = progress.clamp(0.0, 1.0);
            final offset = 20 * (1 - opacity);

            return Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(0, offset),
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2A2A2A),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SkeletonCircle(size: 40),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SkeletonText(width: 120, height: 16),
                                const SizedBox(height: 4),
                                SkeletonText(width: 80, height: 12),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SkeletonText(width: double.infinity, height: 100),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          SkeletonText(width: 60, height: 12),
                          const SizedBox(width: 16),
                          SkeletonText(width: 60, height: 12),
                          const Spacer(),
                          SkeletonCircle(size: 24),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildListSkeleton() {
    return ListView.builder(
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _staggerAnimation,
          builder: (context, child) {
            final delay = index * 50.0;
            final progress = (_staggerAnimation.value * 1000 - delay) / 600;
            final opacity = progress.clamp(0.0, 1.0);
            final offset = 10 * (1 - opacity);

            return Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(0, offset),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      SkeletonCircle(size: 48),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonText(width: 150, height: 16),
                            const SizedBox(height: 4),
                            SkeletonText(width: 100, height: 12),
                          ],
                        ),
                      ),
                      SkeletonCircle(size: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileSkeleton() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header section
          AnimatedBuilder(
            animation: _staggerAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _staggerAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - _staggerAnimation.value)),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        SkeletonCircle(size: 100),
                        const SizedBox(height: 16),
                        SkeletonText(width: 120, height: 20),
                        const SizedBox(height: 8),
                        SkeletonText(width: 80, height: 14),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem('Posts', '0'),
                            _buildStatItem('Followers', '0'),
                            _buildStatItem('Following', '0'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Content section
          AnimatedBuilder(
            animation: _staggerAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _staggerAnimation.value,
                child: Transform.translate(
                  offset: Offset(0, 30 * (1 - _staggerAnimation.value)),
                  child: Column(
                    children: List.generate(
                      widget.itemCount,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SkeletonCircle(size: 32),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: SkeletonText(width: 100, height: 14),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SkeletonText(width: double.infinity, height: 80),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                SkeletonCircle(size: 20),
                                const SizedBox(width: 8),
                                SkeletonText(width: 40, height: 12),
                                const Spacer(),
                                SkeletonCircle(size: 20),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChatSkeleton() {
    return ListView.builder(
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        final isMe = index % 2 == 0;
        return AnimatedBuilder(
          animation: _staggerAnimation,
          builder: (context, child) {
            final delay = index * 100.0;
            final progress = (_staggerAnimation.value * 1000 - delay) / 600;
            final opacity = progress.clamp(0.0, 1.0);
            final offset = 15 * (1 - opacity);

            return Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(0, offset),
                child: Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: isMe
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      if (!isMe) ...[
                        SkeletonCircle(size: 32),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isMe
                                ? const Color(0xFF2A2A2A)
                                : const Color(0xFF1A1A1A),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: SkeletonText(
                            width: 120 + (index * 20) % 80,
                            height: 16,
                          ),
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 8),
                        SkeletonCircle(size: 32),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildExploreSkeleton() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: widget.itemCount,
      itemBuilder: (context, index) {
        return AnimatedBuilder(
          animation: _staggerAnimation,
          builder: (context, child) {
            final delay = index * 50.0;
            final progress = (_staggerAnimation.value * 1000 - delay) / 600;
            final opacity = progress.clamp(0.0, 1.0);
            final offset = 20 * (1 - opacity);

            return Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(0, offset),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonText(width: 80, height: 14),
                            const SizedBox(height: 4),
                            SkeletonText(width: 60, height: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUploadSkeleton() {
    return Column(
      children: [
        // Upload area
        AnimatedBuilder(
          animation: _staggerAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _staggerAnimation.value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - _staggerAnimation.value)),
                child: Container(
                  margin: const EdgeInsets.all(16),
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2A2A2A),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SkeletonCircle(size: 48),
                        const SizedBox(height: 16),
                        SkeletonText(width: 120, height: 16),
                        const SizedBox(height: 8),
                        SkeletonText(width: 80, height: 12),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        // Form fields
        AnimatedBuilder(
          animation: _staggerAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _staggerAnimation.value,
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - _staggerAnimation.value)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: List.generate(
                      widget.itemCount,
                      (index) => Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SkeletonText(width: 80, height: 14),
                            const SizedBox(height: 8),
                            SkeletonText(width: double.infinity, height: 48),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        SkeletonText(width: 40, height: 16),
        const SizedBox(height: 4),
        SkeletonText(width: 60, height: 12),
      ],
    );
  }
}

enum SkeletonType { feed, card, list, profile, chat, explore, upload }

// Reusable skeleton components
class SkeletonText extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsets? margin;

  const SkeletonText({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Shimmer.fromColors(
        baseColor: const Color(0xFF2A2A2A),
        highlightColor: const Color(0xFF404040),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF606060),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}

class SkeletonCircle extends StatelessWidget {
  final double size;
  final EdgeInsets? margin;

  const SkeletonCircle({super.key, required this.size, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Shimmer.fromColors(
        baseColor: const Color(0xFF2A2A2A),
        highlightColor: const Color(0xFF404040),
        child: Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: Color(0xFF606060),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

class SkeletonRectangle extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final EdgeInsets? margin;

  const SkeletonRectangle({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: Shimmer.fromColors(
        baseColor: const Color(0xFF2A2A2A),
        highlightColor: const Color(0xFF404040),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFF606060),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      ),
    );
  }
}

// Pulse animation wrapper
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const PulseAnimation({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2000),
    this.minScale = 0.95,
    this.maxScale = 1.05,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(scale: _animation.value, child: widget.child);
      },
    );
  }
}
