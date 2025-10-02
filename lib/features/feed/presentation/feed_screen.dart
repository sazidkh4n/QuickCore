import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import '../providers/feed_provider.dart';
import '../data/skill_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../social/presentation/like_button.dart';
import '../../social/presentation/comments_bottom_sheet.dart';
import '../../social/presentation/share_button.dart';
import '../../social/providers/social_provider.dart';
import '../../profile/presentation/user_profile_screen.dart';
import '../../bookmarks/presentation/bookmark_button.dart';
import '../../bookmarks/providers/bookmarks_provider.dart';
import '../../social/presentation/follow_button.dart';
import '../../profile/providers/profile_providers.dart';
import '../../video/providers/video_controller_provider.dart';
import 'video_player_widget.dart';
import 'widgets/video_skeleton_loader.dart' as video_skeleton;
import 'dart:developer' as dev;
import 'dart:math';
import 'dart:ui' as ui;
import 'package:palette_generator/palette_generator.dart';
import 'package:quickcore/shared/widgets/skeleton_loader.dart';
import 'dart:async';

enum FeedType { forYou, following }

class FeedScreen extends ConsumerStatefulWidget {
  final String? initialSkillId;

  const FeedScreen({super.key, this.initialSkillId});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  late PageController _pageController;
  int _currentPage = 0;
  FeedType _selectedFeed = FeedType.forYou;
  final bool _initialSkillLoaded = false;
  double _currentVideoProgress = 0.0;
  final Map<String, PaletteGenerator> _paletteCache = {};
  Color? _dominantColor;
  final GlobalKey _followingKey = GlobalKey();
  final GlobalKey _forYouKey = GlobalKey();
  double _underlineWidth = 60;
  double _underlineLeft = 0;
  double _tabSpacing = 18;
  final Set<String> _paletteLoading = {};
  Future<void>? _paletteDebounceFuture;
  Timer? _playbackDebounceTimer;

  @override
  bool get wantKeepAlive => false; // Don't keep alive to refresh on navigation

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 1.0,
      keepPage: true,
    );
    // Reduce initial loading delay
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateUnderlineWidth();
      // Set current screen context and try to resume if returning from profile
      final videoController = ref.read(videoControllerNotifierProvider);
      videoController.setCurrentScreen('feed');

      // Only try to resume if we have a delayed callback (indicating we're returning to feed)
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _tryResumeCurrentVideo();
        }
      });
    });
  }

  void _updateUnderlineWidth() {
    final followingBox =
        _followingKey.currentContext?.findRenderObject() as RenderBox?;
    final forYouBox =
        _forYouKey.currentContext?.findRenderObject() as RenderBox?;
    if (followingBox != null && forYouBox != null) {
      setState(() {
        if (_selectedFeed == FeedType.following) {
          _underlineWidth = followingBox.size.width + 4;
          _underlineLeft = 0;
        } else {
          _underlineWidth = forYouBox.size.width + 4;
          _underlineLeft = followingBox.size.width + _tabSpacing;
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _playbackDebounceTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // When app is resumed, set screen context and try to resume if appropriate
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref.read(videoControllerNotifierProvider).setCurrentScreen('feed');
          _tryResumeCurrentVideo();
        }
      });
    } else if (state == AppLifecycleState.paused) {
      // Clear auto-resume state when app goes to background
      ref.read(videoControllerNotifierProvider).clearAutoResumeState();
    }
  }

  void _tryResumeCurrentVideo() {
    final feedAsync = _selectedFeed == FeedType.forYou
        ? ref.read(feedProvider)
        : ref.read(followingFeedProvider);

    feedAsync.whenData((feed) {
      if (feed.isNotEmpty && _currentPage < feed.length) {
        final currentSkill = feed[_currentPage];
        ref
            .read(videoControllerNotifierProvider)
            .resumeVideoIfAppropriate(currentSkill.id);
      }
    });
  }

  // Refresh feed when switching tabs
  void _refreshFeed() {
    if (_selectedFeed == FeedType.forYou) {
      ref.read(feedProvider.notifier).refreshFeed();
    } else {
      ref.read(followingFeedProvider.notifier).refreshFeed();
    }
  }

  Future<void> _updatePalette(String? thumbnailUrl) async {
    if (thumbnailUrl == null) {
      _dominantColor = null;
      return;
    }
    if (_paletteCache.containsKey(thumbnailUrl)) {
      _dominantColor = _paletteCache[thumbnailUrl]?.dominantColor?.color;
      return;
    }
    if (_paletteLoading.contains(thumbnailUrl)) return;
    _paletteLoading.add(thumbnailUrl);
    // Debounce: only run if the video stays active for 100ms
    _paletteDebounceFuture?.ignore();
    _paletteDebounceFuture = Future.delayed(const Duration(milliseconds: 100));
    await _paletteDebounceFuture;
    try {
      final palette = await PaletteGenerator.fromImageProvider(
        NetworkImage(thumbnailUrl),
        size: const Size(200, 120),
        maximumColorCount: 8,
      );
      _paletteCache[thumbnailUrl] = palette;
      if (mounted) {
        // Use post-frame callback to prevent setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _dominantColor = palette.dominantColor?.color);
        });
      }
    } catch (_) {
      if (mounted) {
        // Use post-frame callback to prevent setState during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _dominantColor = null);
        });
      }
    } finally {
      _paletteLoading.remove(thumbnailUrl);
    }
  }

  void _preloadNextVideos(List<SkillModel> feed, int currentIndex) {
    if (!mounted) return;
    
    // Use a local reference to avoid using ref after disposal
    final videoControllerNotifier = ref.read(videoControllerNotifierProvider);
    
    // Only preload the next video
    final nextIndex = currentIndex + 1;
    if (nextIndex < feed.length) {
      final nextSkill = feed[nextIndex];
      if (videoControllerNotifier.getController(nextSkill.id) == null) {
        try {
          // Create controller without options for stability
          final controller = VideoPlayerController.network(nextSkill.videoUrl);
          videoControllerNotifier.registerController(nextSkill.id, controller);
          
          // Initialize in background without await to avoid hanging UI
          controller.initialize().catchError((error) {
            dev.log('Error initializing next video: $error');
          });
        } catch (e) {
          dev.log('Error preloading video: $e');
        }
      }
    }
  }

  void _pauseAllExceptCurrent(List<SkillModel> feed, int currentIndex) {
    final videoControllerNotifier = ref.read(videoControllerNotifierProvider);
    
    // First make sure all videos are paused
    for (int i = 0; i < feed.length; i++) {
      if (i != currentIndex) {
        final skill = feed[i];
        final controller = videoControllerNotifier.getController(skill.id);
        if (controller != null && controller.value.isInitialized && controller.value.isPlaying) {
          controller.pause();
        }
      }
    }
    
    // Cancel any pending playback timer
    _playbackDebounceTimer?.cancel();
    
    // Use a delayed timer to play the current video after ensuring all others are paused
    _playbackDebounceTimer = Timer(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      
      // Now play current video
      final skill = feed[currentIndex];
      final controller = videoControllerNotifier.getController(skill.id);
      if (controller != null && controller.value.isInitialized && !controller.value.isPlaying) {
        controller.play();
      }

      // Clean up old controllers to free memory
      _cleanupOldControllers(feed, currentIndex);
    });
  }

  void _cleanupOldControllers(List<SkillModel> feed, int currentIndex) {
    final videoControllerNotifier = ref.read(videoControllerNotifierProvider);
    final idsToKeep = <String>{};
    
    // Keep current video and 3 in each direction for immediate access
    for (int i = max(0, currentIndex - 3); i <= min(feed.length - 1, currentIndex + 3); i++) {
      idsToKeep.add(feed[i].id);
    }
    
    final allIds = videoControllerNotifier.state.keys.toList();
    for (final id in allIds) {
      if (!idsToKeep.contains(id)) {
        final controller = videoControllerNotifier.getController(id);
        if (controller != null) {
          controller.dispose();
          videoControllerNotifier.unregisterController(id);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final forYouFeed = ref.watch(feedProvider);
    final followingFeed = ref.watch(followingFeedProvider);
    final auth = ref.watch(authProvider);
    final user = auth.value;

    // Handle specific skill ID if provided
    if (widget.initialSkillId != null && !_initialSkillLoaded) {
      // Watch the single skill provider
      final singleSkillAsync = ref.watch(
        singleSkillProvider(widget.initialSkillId!),
      );

      return singleSkillAsync.when(
        data: (skill) {
          if (skill != null) {
            // Once we have the skill, render it directly
            return _buildSingleSkillView(skill, user?.id);
          } else {
            // If skill not found, show the regular feed
            return _buildRegularFeed(forYouFeed, followingFeed, user);
          }
        },
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, stack) {
          dev.log('Error loading single skill: $error');
          // On error, fall back to regular feed
          return _buildRegularFeed(forYouFeed, followingFeed, user);
        },
      );
    }

    // Regular feed view
    return _buildRegularFeed(forYouFeed, followingFeed, user);
  }

  Widget _buildSingleSkillView(SkillModel skill, String? userId) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          VideoPlayerWidget(
            key: ValueKey(skill.id),
            skill: skill,
            isActive: true,
            heroTagPrefix: 'feed', // Add heroTagPrefix to ensure proper hero animation
          ),
          _buildVideoOverlay(context, skill, userId),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                // Check if we came from chat and navigate back appropriately
                final uri = Uri.parse(GoRouterState.of(context).uri.toString());
                final fromChat = uri.queryParameters['fromChat'] == 'true';
                final chatUserId = uri.queryParameters['chatUserId'];

                if (fromChat && chatUserId != null) {
                  // If we came from a specific chat, go back to that chat with proper user info
                  final chatName = uri.queryParameters['chatName'] ?? 'User';
                  final chatAvatar = uri.queryParameters['chatAvatar'] ?? '';
                  context.go(
                    '/chat/$chatUserId?name=${Uri.decodeComponent(chatName)}&avatar=${Uri.decodeComponent(chatAvatar)}',
                  );
                } else if (fromChat) {
                  // If we came from chat but no specific user, go back to notifications
                  context.go('/notifications');
                } else {
                  // Otherwise, go back to explore page
                  context.go('/explore');
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegularFeed(
    AsyncValue<List<SkillModel>> forYouFeed,
    AsyncValue<List<SkillModel>> followingFeed,
    dynamic user,
  ) {
    final feedAsync = _selectedFeed == FeedType.forYou
        ? forYouFeed
        : followingFeed;

    return Scaffold(
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              _refreshFeed();
              if (_pageController.hasClients) {
                _pageController.jumpToPage(0);
              }
              setState(() {
                _currentPage = 0;
              });
            },
            child: feedAsync.when(
              data: (feed) {
                if (feed.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: Center(
                          child: Text(
                            _selectedFeed == FeedType.forYou
                                ? 'No videos in "For You" yet. Pull down to refresh.'
                                : 'Follow creators to see their videos here.',
                          ),
                        ),
                      ),
                    ],
                  );
                }
                return PageView.builder(
                  scrollDirection: Axis.vertical,
                  controller: _pageController,
                  itemCount: feed.length,
                  physics: const ClampingScrollPhysics(
                    parent: PageScrollPhysics(),
                  ),
                  pageSnapping: true,
                  onPageChanged: (index) {
                    if (!mounted) return;
                    HapticFeedback.lightImpact(); // Add haptic feedback for smoothness perception
                    setState(() {
                      _currentPage = index;
                    });
                    _pauseAllExceptCurrent(feed, index);
                    _preloadNextVideos(feed, index);
                    if (index >= feed.length - 3) {
                      dev.log('Near end of feed, refreshing for more videos');
                      _refreshFeed();
                    }
                  },
                  itemBuilder: (context, index) {
                    final skill = feed[index];
                    if (index == _currentPage) {
                      _updatePalette(skill.thumbnailUrl);
                    }
                    
                    // Use RepaintBoundary for better rendering performance
                    return RepaintBoundary(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Only add key if it's the current or adjacent page to avoid rebuilds
                          VideoPlayerWidget(
                            key: ValueKey('${skill.id}_${index == _currentPage}'),
                            skill: skill,
                            isActive: index == _currentPage,
                            onProgress: index == _currentPage
                                ? (progress) {
                                    if (mounted)
                                      setState(() => _currentVideoProgress = progress);
                                  }
                                : null,
                            highQuality: (index - _currentPage).abs() <= 1, // Only high quality for visible videos
                          ),
                          _buildDynamicGradientOverlay(),
                          _buildVideoOverlay(context, skill, user?.id),
                          _buildActionButtonsPro(context, skill, user?.id),
                          if (index == _currentPage)
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: LinearProgressIndicator(
                                value: _currentVideoProgress,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white.withOpacity(0.7),
                                ),
                                minHeight: 3,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const video_skeleton.FeedSkeletonLoader(itemCount: 3),
              error: (e, st) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text('Error loading feed: $e'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshFeed,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildTopHeader(),
        ],
      ),
    );
  }

  Widget _buildTopHeader() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_selectedFeed != FeedType.following) {
                        setState(() => _selectedFeed = FeedType.following);
                        ref.read(followingFeedProvider.notifier).refreshFeed();
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) => _updateUnderlineWidth(),
                        );
                      }
                    },
                    child: Center(
                      child: Container(
                        key: _followingKey,
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          'Following',
                          style: TextStyle(
                            color: _selectedFeed == FeedType.following
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: _tabSpacing),
                  GestureDetector(
                    onTap: () {
                      if (_selectedFeed != FeedType.forYou) {
                        setState(() => _selectedFeed = FeedType.forYou);
                        ref.read(feedProvider.notifier).refreshFeed();
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) => _updateUnderlineWidth(),
                        );
                      }
                    },
                    child: Center(
                      child: Container(
                        key: _forYouKey,
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Text(
                          'For You',
                          style: TextStyle(
                            color: _selectedFeed == FeedType.forYou
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.ease,
                left: _underlineLeft,
                bottom: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.ease,
                  width: _underlineWidth,
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _selectedFeed == FeedType.forYou
                            ? Colors.purpleAccent
                            : Colors.blueAccent,
                        Colors.white,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderTab(String text, FeedType feedType) {
    final isActive = _selectedFeed == feedType;
    return GestureDetector(
      onTap: () {
        if (!isActive) {
          setState(() {
            _selectedFeed = feedType;
            if (_pageController.hasClients) {
              _pageController.jumpToPage(0);
            }
            _currentPage = 0;
          });
          if (feedType == FeedType.forYou) {
            ref.read(feedProvider.notifier).refreshFeed();
          } else {
            ref.read(followingFeedProvider.notifier).refreshFeed();
          }
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.ease,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.1,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              margin: const EdgeInsets.only(top: 2),
              height: 2,
              width: isActive ? 22 : 0,
              decoration: BoxDecoration(
                color: isActive ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoOverlay(
    BuildContext context,
    SkillModel skill,
    String? currentUserId,
  ) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Positioned(
      left: 16,
      bottom: 110,
      right: MediaQuery.of(context).size.width * 0.2, // Wider container to fit longer texts
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return ui.Gradient.linear(
            bounds.topLeft,
            bounds.bottomRight,
            [Colors.white, Colors.white.withOpacity(0.7), Colors.transparent],
            [0.0, 0.7, 1.0],
          );
        },
        blendMode: BlendMode.dstIn,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.2),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (skill.creatorId != null) {
                        // Pause all videos before navigating to profile
                        ref
                            .read(videoControllerNotifierProvider)
                            .pauseAllVideos(reason: 'navigation_to_profile');
                        context.push('/profile/${skill.creatorId}');
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Consumer(
                          builder: (context, ref, _) {
                            final creatorProfile = ref.watch(
                              userProfileProvider(skill.creatorId ?? ''),
                            );
                            return creatorProfile.when(
                              data: (user) {
                                Color? glowColor;
                                if (user.role == 'tutor') {
                                  glowColor = Colors.blueAccent.withOpacity(
                                    0.7,
                                  );
                                } else if (user.role == 'learner') {
                                  glowColor = Colors.amberAccent.withOpacity(
                                    0.7,
                                  );
                                }
                                return Container(
                                  decoration: glowColor != null
                                      ? BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: glowColor,
                                              blurRadius: 18,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        )
                                      : null,
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundImage: user.avatarUrl != null
                                        ? NetworkImage(user.avatarUrl!)
                                        : null,
                                    child: user.avatarUrl == null
                                        ? const Icon(
                                            Icons.person,
                                            size: 18,
                                            color: Colors.black,
                                          )
                                        : null,
                                  ),
                                );
                              },
                              loading: () => SkeletonCircle(size: 32),
                              error: (_, __) => const CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.person,
                                  size: 18,
                                  color: Colors.black,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Consumer(
                            builder: (context, ref, _) {
                              final displayNameAsync = ref.watch(
                                displayNameProvider(skill.creatorId ?? ''),
                              );
                              return displayNameAsync.when(
                                data: (displayName) => Text(
                                  '@$displayName',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                loading: () => SkeletonText(width: 80, height: 16),
                                error: (_, __) => Text(
                                  '@User',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 15,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (skill.creatorId != null &&
                            currentUserId != null &&
                            skill.creatorId != currentUserId) ...[
                          const SizedBox(width: 10),
                          FollowButton(
                            followerId: currentUserId,
                            followedId: skill.creatorId!,
                            showFollowerCount: false,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.8,
                    ),
                    child: Text(
                      skill.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        letterSpacing: 0.1,
                        shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      // Show view count first to ensure it's always visible
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.remove_red_eye_outlined,
                            color: Colors.white54,
                            size: 15,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${skill.viewCount ?? 0} views',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      // Show hashtags with proper wrapping
                      ...skill.tags
                          .take(2) // Only show up to 2 tags to avoid overflow
                          .map(
                            (tag) => Text(
                              '#$tag',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
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
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    SkillModel skill,
    String? currentUserId,
  ) {
    final double iconSize = 36;
    final double bgSize = 54;
    final Color bgColor = Colors.black.withOpacity(0.35);
    final Color iconColor = Colors.white;
    final TextStyle countStyle = TextStyle(
      color: Colors.white.withOpacity(0.85),
      fontSize: 13,
      fontWeight: FontWeight.w500,
    );

    Widget animatedIcon({
      required Widget icon,
      required VoidCallback onTap,
      required String count,
      String? semanticLabel,
    }) {
      return GestureDetector(
        onTap: () {
          onTap();
        },
        child: Column(
          children: [
            AnimatedScale(
              scale: 1.0,
              duration: const Duration(milliseconds: 120),
              child: Container(
                width: bgSize,
                height: bgSize,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(child: icon),
              ),
            ),
            const SizedBox(height: 4),
            Text(count, style: countStyle),
          ],
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (currentUserId != null) ...[
          // Profile Avatar (bottom of stack)
          _buildProfileAvatar(context, skill.creatorId, currentUserId),
          const SizedBox(height: 28),
          // Like Button
          Consumer(
            builder: (context, ref, _) {
              final likeCountAsync = ref.watch(likeCountProvider(skill.id));
              final likeStateAsync = ref.watch(
                likeStateProvider((currentUserId, skill.id)),
              );
              final notifier = ref.read(socialProvider.notifier);
              return likeCountAsync.when(
                data: (likeCount) => likeStateAsync.when(
                  data: (isLiked) => _ActionButton(
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.redAccent : iconColor,
                      size: iconSize,
                    ),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      notifier.toggleLike(currentUserId, skill.id);
                    },
                    count: likeCount.toString(),
                    countStyle: countStyle,
                    bgSize: bgSize,
                    bgColor: bgColor,
                    glass: false,
                  ),
                  loading: () => _ActionButton(
                    icon: Icon(
                      Icons.favorite_border,
                      color: iconColor,
                      size: iconSize,
                    ),
                    onTap: () {},
                    count: likeCount.toString(),
                    countStyle: countStyle,
                    bgSize: bgSize,
                    bgColor: bgColor,
                    glass: false,
                  ),
                  error: (_, __) => _ActionButton(
                    icon: Icon(
                      Icons.favorite_border,
                      color: iconColor,
                      size: iconSize,
                    ),
                    onTap: () {},
                    count: likeCount.toString(),
                    countStyle: countStyle,
                    bgSize: bgSize,
                    bgColor: bgColor,
                    glass: false,
                  ),
                ),
                loading: () => _ActionButton(
                  icon: Icon(
                    Icons.favorite_border,
                    color: iconColor,
                    size: iconSize,
                  ),
                  onTap: () {},
                  count: '0',
                  countStyle: countStyle,
                  bgSize: bgSize,
                  bgColor: bgColor,
                  glass: false,
                ),
                error: (_, __) => _ActionButton(
                  icon: Icon(
                    Icons.favorite_border,
                    color: iconColor,
                    size: iconSize,
                  ),
                  onTap: () {},
                  count: '0',
                  countStyle: countStyle,
                  bgSize: bgSize,
                  bgColor: bgColor,
                  glass: false,
                ),
              );
            },
          ),
          const SizedBox(height: 28),
          // Comment Button
          Consumer(
            builder: (context, ref, _) {
              final commentsAsync = ref.watch(commentsProvider(skill.id));
              return commentsAsync.when(
                data: (comments) => _ActionButton(
                  icon: Icon(Icons.comment, color: iconColor, size: iconSize),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    showGeneralDialog(
                      context: context,
                      barrierDismissible: true,
                      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
                      transitionDuration: const Duration(milliseconds: 350),
                      pageBuilder: (context, animation, secondaryAnimation) => Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          heightFactor: 0.85,
                          child: CommentsBottomSheet(skillId: skill.id),
                        ),
                      ),
                      transitionBuilder: (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 1),
                            end: Offset.zero,
                          ).animate(animation),
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                    );
                  },
                  count: comments.length.toString(),
                  countStyle: countStyle,
                  bgSize: bgSize,
                  bgColor: bgColor,
                  glass: false,
                ),
                loading: () => _ActionButton(
                  icon: Icon(Icons.comment, color: iconColor, size: iconSize),
                  onTap: () {},
                  count: '0',
                  countStyle: countStyle,
                  bgSize: bgSize,
                  bgColor: bgColor,
                  glass: false,
                ),
                error: (_, __) => _ActionButton(
                  icon: Icon(Icons.comment, color: iconColor, size: iconSize),
                  onTap: () {},
                  count: '0',
                  countStyle: countStyle,
                  bgSize: bgSize,
                  bgColor: bgColor,
                  glass: false,
                ),
              );
            },
          ),
          const SizedBox(height: 28),
          // Share Button
          ShareButton(
            skillId: skill.id,
            skill: skill,
            vertical: true,
          ),
          const SizedBox(height: 28),
          // Save/Bookmark Button
          Consumer(
            builder: (context, ref, _) {
              final isBookmarkedAsync = ref.watch(
                isBookmarkedProvider((currentUserId, skill.id)),
              );
              final bookmarksNotifier = ref.read(bookmarksProvider.notifier);
              return isBookmarkedAsync.when(
                data: (isBookmarked) => _ActionButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: iconColor,
                    size: iconSize,
                  ),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    bookmarksNotifier.toggleBookmark(currentUserId, skill.id);
                  },
                  count: '',
                  countStyle: countStyle,
                  bgSize: bgSize,
                  bgColor: bgColor,
                  glass: false,
                ),
                loading: () => _ActionButton(
                  icon: Icon(
                    Icons.bookmark_border,
                    color: iconColor,
                    size: iconSize,
                  ),
                  onTap: () {},
                  count: '',
                  countStyle: countStyle,
                  bgSize: bgSize,
                  bgColor: bgColor,
                  glass: false,
                ),
                error: (_, __) => _ActionButton(
                  icon: Icon(
                    Icons.bookmark_border,
                    color: iconColor,
                    size: iconSize,
                  ),
                  onTap: () {},
                  count: '',
                  countStyle: countStyle,
                  bgSize: bgSize,
                  bgColor: bgColor,
                  glass: false,
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildProfileAvatar(
    BuildContext context,
    String? creatorId,
    String currentUserId,
  ) {
    if (creatorId == null) {
      return const CircleAvatar(
        radius: 25,
        backgroundColor: Colors.white,
        child: Icon(Icons.person, size: 30, color: Colors.black),
      );
    }

    final isOwnProfile = creatorId == currentUserId;

    return GestureDetector(
      onTap: () {
        // Pause all videos before navigating to profile
        ref
            .read(videoControllerNotifierProvider)
            .pauseAllVideos(reason: 'navigation_to_profile');
        context.push('/profile/$creatorId');
      },
      child: Consumer(
        builder: (context, ref, child) {
          final creatorProfile = ref.watch(userProfileProvider(creatorId));
          final isFollowingAsync = isOwnProfile
              ? null
              : ref.watch(isFollowingProvider((currentUserId, creatorId)));

          return creatorProfile.when(
            data: (user) {
              Color? glowColor;
              if (user.role == 'tutor') {
                glowColor = Colors.blueAccent;
              } else if (user.role == 'learner') {
                glowColor = Colors.amberAccent;
              }
              return Stack(
                alignment: Alignment.center,
                children: [
                  if (glowColor != null)
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: glowColor.withOpacity(0.55),
                            blurRadius: 40,
                            spreadRadius: 12,
                          ),
                          BoxShadow(
                            color: glowColor.withOpacity(0.25),
                            blurRadius: 60,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  CircleAvatar(
                    radius: 22,
                    backgroundImage: user.avatarUrl != null
                        ? NetworkImage(user.avatarUrl!)
                        : null,
                    child: user.avatarUrl == null
                        ? const Icon(
                            Icons.person,
                            size: 22,
                            color: Colors.black,
                          )
                        : null,
                  ),
                ],
              );
            },
            loading: () => SkeletonCircle(size: 40),
            error: (_, __) => const CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 30, color: Colors.black),
            ),
          );
        },
      ),
    );
  }

  // Helper methods for action buttons
  Widget _buildLikeButton(BuildContext context, SkillModel skill, String? currentUserId) {
    if (currentUserId == null) return const SizedBox.shrink();
    
    final double iconSize = 26;
    final double bgSize = 44;
    final Color bgColor = Colors.white.withOpacity(0.18);
    final Color iconColor = Colors.white;
    final TextStyle countStyle = TextStyle(
      color: Colors.white.withOpacity(0.92),
      fontSize: 12,
      fontWeight: FontWeight.w600,
      shadows: [Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 2)],
    );

    return Consumer(
      builder: (context, ref, _) {
        final likeCountAsync = ref.watch(likeCountProvider(skill.id));
        final likeStateAsync = ref.watch(
          likeStateProvider((currentUserId, skill.id)),
        );
        final notifier = ref.read(socialProvider.notifier);
        return likeCountAsync.when(
          data: (likeCount) => likeStateAsync.when(
            data: (isLiked) => _ActionButton(
              icon: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                color: isLiked ? Colors.redAccent : iconColor,
                size: iconSize,
              ),
              onTap: () {
                HapticFeedback.lightImpact();
                notifier.toggleLike(currentUserId, skill.id);
              },
              count: likeCount.toString(),
              countStyle: countStyle,
              bgSize: bgSize,
              bgColor: bgColor,
              glass: false,
            ),
            loading: () => _ActionButton(
              icon: Icon(
                Icons.favorite_border,
                color: iconColor,
                size: iconSize,
              ),
              onTap: () {},
              count: '0',
              countStyle: countStyle,
              bgSize: bgSize,
              bgColor: bgColor,
              glass: false,
            ),
            error: (_, __) => _ActionButton(
              icon: Icon(
                Icons.favorite_border,
                color: iconColor,
                size: iconSize,
              ),
              onTap: () {},
              count: '0',
              countStyle: countStyle,
              bgSize: bgSize,
              bgColor: bgColor,
              glass: false,
            ),
          ),
          loading: () => _ActionButton(
            icon: Icon(
              Icons.favorite_border,
              color: iconColor,
              size: iconSize,
            ),
            onTap: () {},
            count: '0',
            countStyle: countStyle,
            bgSize: bgSize,
            bgColor: bgColor,
            glass: false,
          ),
          error: (_, __) => _ActionButton(
            icon: Icon(
              Icons.favorite_border,
              color: iconColor,
              size: iconSize,
            ),
            onTap: () {},
            count: '0',
            countStyle: countStyle,
            bgSize: bgSize,
            bgColor: bgColor,
            glass: false,
          ),
        );
      },
    );
  }

  Widget _buildCommentButton(BuildContext context, SkillModel skill) {
    final double iconSize = 26;
    final double bgSize = 44;
    final Color bgColor = Colors.white.withOpacity(0.18);
    final Color iconColor = Colors.white;
    final TextStyle countStyle = TextStyle(
      color: Colors.white.withOpacity(0.92),
      fontSize: 12,
      fontWeight: FontWeight.w600,
      shadows: [Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 2)],
    );
    
    return Consumer(
      builder: (context, ref, _) {
        final commentsAsync = ref.watch(commentsProvider(skill.id));
        return commentsAsync.when(
          data: (comments) => _ActionButton(
            icon: Icon(
              Icons.comment,
              color: iconColor,
              size: iconSize,
            ),
            onTap: () {
              HapticFeedback.lightImpact();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => Material(
                  type: MaterialType.transparency,
                  child: SafeArea(
                    child: FractionallySizedBox(
                      heightFactor: 0.9,
                      child: CommentsBottomSheet(skillId: skill.id),
                    ),
                  ),
                ),
              );
            },
            count: comments.length.toString(),
            countStyle: countStyle,
            bgSize: bgSize,
            bgColor: bgColor,
            glass: false,
          ),
          loading: () => _ActionButton(
            icon: Icon(Icons.comment, color: iconColor, size: iconSize),
            onTap: () {},
            count: '0',
            countStyle: countStyle,
            bgSize: bgSize,
            bgColor: bgColor,
            glass: false,
          ),
          error: (_, __) => _ActionButton(
            icon: Icon(Icons.comment, color: iconColor, size: iconSize),
            onTap: () {},
            count: '0',
            countStyle: countStyle,
            bgSize: bgSize,
            bgColor: bgColor,
            glass: false,
          ),
        );
      },
    );
  }

  Widget _buildShareButton(BuildContext context, SkillModel skill) {
    final double bgSize = 44;
    
    return SizedBox(
      width: bgSize,
      height: bgSize,
      child: ShareButton(
        skillId: skill.id,
        skill: skill,
        vertical: true,
      ),
    );
  }

  Widget _buildBookmarkButton(BuildContext context, SkillModel skill, String? currentUserId) {
    if (currentUserId == null) return const SizedBox.shrink();
    
    final double iconSize = 26;
    final double bgSize = 44;
    final Color bgColor = Colors.white.withOpacity(0.18);
    final Color iconColor = Colors.white;
    final TextStyle countStyle = TextStyle(
      color: Colors.white.withOpacity(0.92),
      fontSize: 12,
      fontWeight: FontWeight.w600,
      shadows: [Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 2)],
    );
    
    return Consumer(
      builder: (context, ref, _) {
        final isBookmarkedAsync = ref.watch(
          isBookmarkedProvider((currentUserId, skill.id)),
        );
        final bookmarksNotifier = ref.read(bookmarksProvider.notifier);
        return isBookmarkedAsync.when(
          data: (isBookmarked) => _ActionButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: iconColor,
              size: iconSize,
            ),
            onTap: () {
              HapticFeedback.lightImpact();
              bookmarksNotifier.toggleBookmark(
                currentUserId,
                skill.id,
              );
            },
            count: '',
            countStyle: countStyle,
            bgSize: bgSize,
            bgColor: bgColor,
            glass: false,
          ),
          loading: () => _ActionButton(
            icon: Icon(
              Icons.bookmark_border,
              color: iconColor,
              size: iconSize,
            ),
            onTap: () {},
            count: '',
            countStyle: countStyle,
            bgSize: bgSize,
            bgColor: bgColor,
            glass: false,
          ),
          error: (_, __) => _ActionButton(
            icon: Icon(
              Icons.bookmark_border,
              color: iconColor,
              size: iconSize,
            ),
            onTap: () {},
            count: '',
            countStyle: countStyle,
            bgSize: bgSize,
            bgColor: bgColor,
            glass: false,
          ),
        );
      },
    );
  }

  Widget _buildDynamicGradientOverlay() {
    final color = _dominantColor ?? Colors.black.withOpacity(0.7);
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      height: 180,
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                color.withOpacity(0.85),
                color.withOpacity(0.35),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtonsPro(
    BuildContext context,
    SkillModel skill,
    String? currentUserId,
  ) {
    return Positioned(
      right: 8,
      bottom: MediaQuery.of(context).padding.bottom + 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Like Button
          _buildLikeButton(context, skill, currentUserId),
          const SizedBox(height: 16),
          
          // Comment Button
          _buildCommentButton(context, skill),
          const SizedBox(height: 16),
          
          // Share Button
          _buildShareButton(context, skill),
          const SizedBox(height: 16),
          
          // Bookmark Button
          _buildBookmarkButton(context, skill, currentUserId),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final Widget icon;
  final VoidCallback onTap;
  final String count;
  final TextStyle countStyle;
  final double bgSize;
  final Color bgColor;
  final bool glass;
  final BoxDecoration? glassDecoration;
  final Widget? child;
  const _ActionButton({
    required this.icon,
    required this.onTap,
    required this.count,
    required this.countStyle,
    required this.bgSize,
    required this.bgColor,
    this.glass = false,
    this.glassDecoration,
    this.child,
    super.key,
  });
  @override
  State<_ActionButton> createState() => _ActionButtonState();
}
class _ActionButtonState extends State<_ActionButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.85,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _controller;
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  void _onTap() async {
    await _controller.reverse();
    await _controller.forward();
    widget.onTap();
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _scaleAnim,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnim.value,
                child: Container(
                  width: widget.bgSize,
                  height: widget.bgSize,
                  decoration: widget.glass ? widget.glassDecoration : BoxDecoration(
                    color: widget.bgColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(child: widget.icon),
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          if (widget.count.isNotEmpty)
            Text(widget.count, style: widget.countStyle),
        ],
      ),
    );
  }
}
