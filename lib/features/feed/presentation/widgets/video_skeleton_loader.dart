import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';

class VideoSkeletonLoader extends StatefulWidget {
  const VideoSkeletonLoader({super.key});

  @override
  State<VideoSkeletonLoader> createState() => _VideoSkeletonLoaderState();
}

class _VideoSkeletonLoaderState extends State<VideoSkeletonLoader>
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
    
    // Shimmer animation controller
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Pulse animation controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Stagger animation controller
    _staggerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Shimmer animation
    _shimmerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    ));
    
    // Pulse animation
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Stagger animation
    _staggerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _staggerController,
      curve: Curves.easeOut,
    ));
    
    // Start animations
    _shimmerController.repeat();
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
    final size = MediaQuery.of(context).size;
    
    return Container(
      width: size.width,
      height: size.height,
      color: const Color(0xFF000000),
      child: Stack(
        children: [
          // Video background with gradient overlay
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1A1A1A),
                  Color(0xFF0D0D0D),
                  Color(0xFF000000),
                ],
              ),
            ),
          ),
          
          // Top header skeleton
          _buildTopHeader(),
          
          // Bottom content overlay skeleton
          _buildBottomContent(),
          
          // Right side action buttons skeleton
          _buildSideActions(),
          
          // Center play button skeleton
          _buildCenterPlayButton(),
        ],
      ),
    );
  }

  Widget _buildTopHeader() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _staggerAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _staggerAnimation.value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - _staggerAnimation.value)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeaderTab('Following', false),
                  const SizedBox(width: 16),
                  _buildHeaderTab('For You', true),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderTab(String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF2A2A2A) : const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? const Color(0xFF404040) : Colors.transparent,
          width: 1,
        ),
      ),
      child: Shimmer.fromColors(
        baseColor: isActive ? const Color(0xFF404040) : const Color(0xFF2A2A2A),
        highlightColor: isActive ? const Color(0xFF606060) : const Color(0xFF404040),
        child: Container(
          width: text == 'Following' ? 60 : 50,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFF606060),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomContent() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: _staggerAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _staggerAnimation.value,
            child: Transform.translate(
              offset: Offset(0, 30 * (1 - _staggerAnimation.value)),
              child: Container(
                padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 90),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Color(0xCC000000),
                      Color(0x66000000),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCreatorInfo(),
                    const SizedBox(height: 16),
                    _buildVideoDescription(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCreatorInfo() {
    return Row(
      children: [
        // Avatar skeleton
        Shimmer.fromColors(
          baseColor: const Color(0xFF2A2A2A),
          highlightColor: const Color(0xFF404040),
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF606060),
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Username and info skeleton
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Shimmer.fromColors(
                baseColor: const Color(0xFF2A2A2A),
                highlightColor: const Color(0xFF404040),
                child: Container(
                  width: 120,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFF606060),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Shimmer.fromColors(
                baseColor: const Color(0xFF2A2A2A),
                highlightColor: const Color(0xFF404040),
                child: Container(
                  width: 180,
                  height: 14,
                  decoration: BoxDecoration(
                    color: const Color(0xFF606060),
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Shimmer.fromColors(
                    baseColor: const Color(0xFF2A2A2A),
                    highlightColor: const Color(0xFF404040),
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFF606060),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Shimmer.fromColors(
                    baseColor: const Color(0xFF2A2A2A),
                    highlightColor: const Color(0xFF404040),
                    child: Container(
                      width: 40,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF606060),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVideoDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shimmer.fromColors(
          baseColor: const Color(0xFF2A2A2A),
          highlightColor: const Color(0xFF404040),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: 14,
            decoration: BoxDecoration(
              color: const Color(0xFF606060),
              borderRadius: BorderRadius.circular(7),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Shimmer.fromColors(
          baseColor: const Color(0xFF2A2A2A),
          highlightColor: const Color(0xFF404040),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: 14,
            decoration: BoxDecoration(
              color: const Color(0xFF606060),
              borderRadius: BorderRadius.circular(7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSideActions() {
    return Positioned(
      right: 16,
      bottom: MediaQuery.of(context).padding.bottom + 120,
      child: Column(
        children: [
          _buildStaggeredActionButton(0, _buildProfileAvatar()),
          const SizedBox(height: 20),
          _buildStaggeredActionButton(1, _buildActionButton(Icons.favorite, '0')),
          const SizedBox(height: 16),
          _buildStaggeredActionButton(2, _buildActionButton(Icons.comment, '0')),
          const SizedBox(height: 16),
          _buildStaggeredActionButton(3, _buildActionButton(Icons.share, 'Share')),
        ],
      ),
    );
  }

  Widget _buildStaggeredActionButton(int index, Widget child) {
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
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildProfileAvatar() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Shimmer.fromColors(
            baseColor: const Color(0xFF2A2A2A),
            highlightColor: const Color(0xFF404040),
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xFF606060),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Shimmer.fromColors(
                baseColor: const Color(0xFF2A2A2A),
                highlightColor: const Color(0xFF404040),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Color(0xFF606060),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Shimmer.fromColors(
          baseColor: const Color(0xFF2A2A2A),
          highlightColor: const Color(0xFF404040),
          child: Container(
            width: label == 'Share' ? 30 : 20,
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFF606060),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCenterPlayButton() {
    return Center(
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Shimmer.fromColors(
              baseColor: const Color(0xFF2A2A2A),
              highlightColor: const Color(0xFF404040),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF606060).withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: const Color(0xFF606060).withOpacity(0.5),
                  size: 40,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class FeedSkeletonLoader extends StatefulWidget {
  final int itemCount;
  
  const FeedSkeletonLoader({
    super.key,
    this.itemCount = 3,
  });

  @override
  State<FeedSkeletonLoader> createState() => _FeedSkeletonLoaderState();
}

class _FeedSkeletonLoaderState extends State<FeedSkeletonLoader>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: widget.itemCount,
            itemBuilder: (context, index) {
              return SizedBox(
                height: MediaQuery.of(context).size.height,
                child: const VideoSkeletonLoader(),
              );
            },
          ),
        );
      },
    );
  }
}

// Additional skeleton components for reusability
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

  const SkeletonCircle({
    super.key,
    required this.size,
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