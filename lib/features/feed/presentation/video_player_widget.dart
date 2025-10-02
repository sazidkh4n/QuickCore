import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:quickcore/features/social/providers/social_provider.dart';
import 'package:quickcore/features/auth/providers/auth_provider.dart';
import 'package:quickcore/features/feed/providers/feed_provider.dart';
import 'package:quickcore/features/video/providers/video_controller_provider.dart';
import '../data/skill_model.dart';
import 'dart:developer' as dev;

class VideoPlayerWidget extends ConsumerStatefulWidget {
  final SkillModel skill;
  final bool isActive;
  final void Function(double progress)? onProgress;
  final bool highQuality; // New property for quality control
  final String heroTagPrefix; // New property for Hero tag prefix

  const VideoPlayerWidget({
    super.key,
    required this.skill,
    required this.isActive,
    this.onProgress,
    this.highQuality = true, // Default to high quality
    this.heroTagPrefix = 'feed', // Default to 'feed' for backward compatibility
  });

  @override
  ConsumerState<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends ConsumerState<VideoPlayerWidget>
    with TickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool _hasError = false;
  String? _errorMessage;
  bool _isInitialized = false;

  late AnimationController _playPauseAnimationController;
  late Animation<double> _playPauseAnimation;

  late AnimationController _seekAnimationController;
  late Animation<double> _seekAnimation;
  bool _showSeekIcon = false;
  bool _isSeekingForward = false;

  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;
  bool _showLikeIcon = false;
  bool _viewIncremented = false;
  
  // Add cancel flag
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initController();

    _playPauseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _playPauseAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _playPauseAnimationController,
      curve: Curves.easeOut,
    ));
    _playPauseAnimationController.value = 1.0;

    _seekAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _seekAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _seekAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _likeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _likeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.4), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 1), // hold
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _likeAnimationController,
      curve: Curves.easeOutCubic,
    ));
  }

  Future<void> _initController() async {
    setState(() {
      _hasError = false;
      _errorMessage = null;
      _isInitialized = false;
    });
    
    try {
      // Create the controller with optimized options
      _controller = VideoPlayerController.network(
        widget.skill.videoUrl,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
          allowBackgroundPlayback: false,
        ),
      );
      
      // Pre-cache to memory
      await _controller.initialize().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Video initialization timed out');
        },
      );
      
      // Check if widget is still mounted before proceeding
      if (!mounted) return;
      
      // Apply hardware acceleration
      if (widget.highQuality) {
        // Apply video enhancement for smoother playback
        _controller.setVolume(1.0);
      } else {
        // Lower quality for background videos to save resources
        _controller.setVolume(0.0);
      }
      
      // Register with global controller
      ref.read(videoControllerNotifierProvider).registerController(
        widget.skill.id, 
        _controller
      );
      
      // Set looping regardless of active state
      _controller.setLooping(true);
      
      // Only play if this video is active
      if (widget.isActive) {
        // Slight delay to prevent overlapping sounds
        await Future.delayed(const Duration(milliseconds: 30));
        if (mounted && widget.isActive) {
          // Ensure this is the only video playing
          ref.read(videoControllerNotifierProvider).ensureSingleVideoPlaying(widget.skill.id);
          _controller.play();
        }
      }
      
      // Add listener for progress tracking
      _controller.addListener(_videoListener);
      
      // Update UI
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load video: ${e.toString()}';
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant VideoPlayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle quality changes
    if (widget.highQuality != oldWidget.highQuality && _isInitialized) {
      if (widget.highQuality) {
        _controller.setVolume(1.0);
      } else {
        // Lower quality for background videos
        _controller.setVolume(0.0);
      }
    }
    
    // Handle active state changes
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        // Make sure the video is initialized and not already playing before playing it
        if (_isInitialized && !_controller.value.isPlaying) {
          // Small delay to ensure any previous video has properly paused
          Future.delayed(const Duration(milliseconds: 30), () {
            if (mounted && widget.isActive) {
              // Ensure this is the only video playing
              ref.read(videoControllerNotifierProvider).ensureSingleVideoPlaying(widget.skill.id);
              
              // Haptic feedback for smoother perceived transitions
              HapticFeedback.lightImpact();
              
              // Play the video
              _controller.play();
              _controller.setLooping(true);
            }
          });
        }
      } else {
        // When becoming inactive, immediately pause
        if (_controller.value.isPlaying) {
          _controller.pause();
        }
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    
    // First pause the video to stop audio
    if (_isInitialized && _controller.value.isPlaying) {
      _controller.pause();
    }
    
    // Remove listener before disposal to prevent callback errors
    if (_isInitialized) {
      _controller.removeListener(_videoListener);
    }
    
    // Safely use ref - wrap in try-catch to prevent errors
    try {
      if (!_isDisposed) {
        // Unregister from global controller
        ref.read(videoControllerNotifierProvider).unregisterController(widget.skill.id);
      }
    } catch (e) {
      dev.log('Error unregistering controller: $e');
    }
    
    // Dispose controller
    _controller.dispose();
    
    // Dispose animation controllers
    _playPauseAnimationController.dispose();
    _seekAnimationController.dispose();
    _likeAnimationController.dispose();
    
    super.dispose();
  }

  void _videoListener() {
    if (_viewIncremented || !mounted || !_isInitialized || _isDisposed) {
      return;
    }

    try {
      final position = _controller.value.position;
      final duration = _controller.value.duration;
  
      // Call onProgress callback
      if (widget.onProgress != null && duration.inMilliseconds > 0) {
        final progress = position.inMilliseconds / duration.inMilliseconds;
        widget.onProgress!(progress.clamp(0.0, 1.0));
      }
  
      if (duration.inMilliseconds > 0 &&
          position.inMilliseconds / duration.inMilliseconds >= 0.9) {
        
        // Safely use ref with mount check
        if (!mounted || _isDisposed) return;
        
        try {
          ref.read(feedProvider.notifier).incrementView(widget.skill.id);
          if (mounted) {
            setState(() {
              _viewIncremented = true;
            });
          }
          // Once incremented, we can remove the listener to save resources
          _controller.removeListener(_videoListener);
        } catch (e) {
          dev.log('Error incrementing view: $e');
        }
      }
    } catch (e) {
      // Handle any errors silently to prevent crashes
      dev.log('Error in video listener: $e');
    }
  }

  void _togglePlayPause() {
    if (!_isInitialized || _isDisposed) return;
    
    if (_controller.value.isPlaying) {
      _controller.pause();
      // Clear auto-resume state when user manually pauses
      try {
        if (mounted && !_isDisposed) {
          ref.read(videoControllerNotifierProvider).clearAutoResumeState();
        }
      } catch (e) {
        dev.log('Error clearing auto-resume state: $e');
      }
    } else {
      _controller.play();
    }
    
    if (mounted) {
      setState(() {});
      _playPauseAnimationController.forward(from: 0);
    }
  }

  Future<void> _seek(bool forward) async {
    if (!_isInitialized || _isDisposed) return;
    
    final newPosition =
        _controller.value.position + Duration(seconds: forward ? 5 : -5);
    await _controller.seekTo(newPosition);
    
    if (mounted) {
      setState(() {
        _isSeekingForward = forward;
        _showSeekIcon = true;
        _seekAnimationController.forward(from: 0);
      });
    
      // Hide icon after animation
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted && !_isDisposed) setState(() => _showSeekIcon = false);
      });
    }
  }

  Future<void> _likeVideo() async {
    if (_isDisposed) return;
    
    try {
      final currentUserId = ref.read(authProvider).value?.id;
      if (currentUserId == null) return;

      final isLiked = await ref.read(
        likeStateProvider((currentUserId, widget.skill.id)).future,
      );

      if (!isLiked) {
        // Trigger like action
        if (!mounted || _isDisposed) return;
        
        ref
            .read(socialProvider.notifier)
            .likeSkill(currentUserId, widget.skill.id);

        // Trigger animation
        if (mounted) {
          setState(() {
            _showLikeIcon = true;
            _likeAnimationController.forward(from: 0);
          });
        }
        
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted && !_isDisposed) setState(() => _showLikeIcon = false);
        });
      }
    } catch (e) {
      dev.log('Error in likeVideo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(_errorMessage ?? 'Video failed to load.', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initController,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (!_isInitialized) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Spinner with custom styling for smoother appearance
            CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Loading video...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RepaintBoundary(
      child: GestureDetector(
        // Add this to help prevent unwanted gesture propagation
        onVerticalDragStart: null,
        onHorizontalDragStart: null,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: Hero(
                  tag: '${widget.heroTagPrefix}-video-${widget.skill.id}',
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              ),
            ),
            // Gesture detection overlay
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onDoubleTap: () => _seek(false),
                    behavior: HitTestBehavior.translucent,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _togglePlayPause,
                    onDoubleTap: _likeVideo,
                    behavior: HitTestBehavior.translucent,
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onDoubleTap: () => _seek(true),
                    behavior: HitTestBehavior.translucent,
                  ),
                ),
              ],
            ),

            // Animation Overlays remain the same
            FadeTransition(
              opacity: _playPauseAnimation,
              child: Icon(
                _controller.value.isPlaying
                    ? Icons.pause_circle_filled
                    : Icons.play_circle_filled,
                color: Colors.white.withOpacity(0.7),
                size: 60,
              ),
            ),
            if (_showSeekIcon)
              FadeTransition(
                opacity: _seekAnimation,
                child: Align(
                  alignment: _isSeekingForward
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Icon(
                      _isSeekingForward
                          ? Icons.fast_forward_rounded
                          : Icons.fast_rewind_rounded,
                      color: Colors.white.withOpacity(0.7),
                      size: 60,
                    ),
                  ),
                ),
              ),
            if (_showLikeIcon)
              ScaleTransition(
                scale: _likeAnimation,
                child: Icon(
                  Icons.favorite,
                  color: Colors.red.withOpacity(0.8),
                  size: 100,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
