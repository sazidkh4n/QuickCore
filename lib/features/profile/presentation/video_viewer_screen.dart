import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quickcore/features/feed/data/skill_model.dart';
import 'package:quickcore/features/feed/presentation/video_player_widget.dart';
import 'package:quickcore/features/auth/providers/auth_provider.dart';
import 'package:quickcore/features/social/providers/social_provider.dart';
import 'package:quickcore/features/social/presentation/comments_bottom_sheet.dart';
import 'package:quickcore/features/social/presentation/share_button.dart';
import 'package:quickcore/features/bookmarks/providers/bookmarks_provider.dart';
import 'dart:ui' as ui;

// Add a provider to fetch a single skill/video by ID
final singleSkillProvider = FutureProvider.family<SkillModel, String>((
  ref,
  videoId,
) async {
  // Get Supabase client directly
  final supabase = Supabase.instance.client;
  final response = await supabase
      .from('skills')
      .select()
      .eq('id', videoId)
      .maybeSingle();

  if (response == null) {
    throw Exception('Video not found');
  }

  return SkillModel.fromJson(response);
});

class VideoViewerScreen extends ConsumerWidget {
  final String? videoId;
  final List<SkillModel>? skills;
  final int initialIndex;
  final bool showAnalytics;
  final String source; // Add source parameter
  final bool openComments; // Add openComments parameter
  final String? notificationType; // Add notificationType parameter

  const VideoViewerScreen({
    super.key,
    this.videoId,
    this.skills,
    this.initialIndex = 0,
    this.showAnalytics = false,
    this.source = 'feed', // Default to feed
    this.openComments = false, // Default to false
    this.notificationType, // Default to null
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If videoId is provided, load a single video
    if (videoId != null) {
      final videoAsync = ref.watch(singleSkillProvider(videoId!));

      return videoAsync.when(
        data: (video) => _buildSingleVideoView(context, video),
        loading: () =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (error, stack) => Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: Center(child: Text('Error loading video: ${error.toString()}')),
        ),
      );
    }

    // Otherwise use the list of videos
    return _buildMultipleVideosView(context);
  }

  Widget _buildSingleVideoView(BuildContext context, SkillModel video) {
    return Consumer(
      builder: (context, ref, child) {
        final user = ref.watch(authProvider).value;

        // Auto-open comments only for comment-related notifications
        if (openComments && (notificationType == 'comment' || notificationType == 'mention')) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Only open comments if this is from a comment notification
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => CommentsBottomSheet(skillId: video.id),
            );
          });
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                // Navigate back based on the source
                if (source == 'explore') {
                  context.go('/explore');
                } else {
                  context.go('/feed');
                }
              },
            ),
            title: showAnalytics ? const Text('Video Analytics') : null,
          ),
          body: showAnalytics
              ? Column(
                  children: [
                    // Video Player takes the top half
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: VideoPlayerWidget(
                        skill: video, 
                        isActive: true, 
                        heroTagPrefix: source, // Pass source as heroTagPrefix
                      ),
                    ),
                    // Analytics section
                    Expanded(child: _buildAnalyticsSection(context, video)),
                  ],
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    // Full screen video player
                    VideoPlayerWidget(
                      skill: video, 
                      isActive: true,
                      heroTagPrefix: source, // Pass source as heroTagPrefix
                    ),
                    // Social action buttons on the right
                    _buildActionButtons(context, video, user?.id),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildAnalyticsSection(BuildContext context, SkillModel video) {
    // Calculate bottom padding to account for the navigation bar
    final bottomPadding =
        MediaQuery.of(context).padding.bottom +
        80.0; // Navigation bar height + extra padding

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, bottomPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Video Analytics',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),

          // Performance Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Performance',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow(
                    context,
                    'Views',
                    '${video.viewCount}',
                    Icons.visibility_outlined,
                  ),
                  const SizedBox(height: 8),
                  _buildStatRow(
                    context,
                    'Likes',
                    '${video.likeCount}',
                    Icons.favorite_outline,
                  ),
                  const SizedBox(height: 8),
                  // Additional stats would be added here
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Engagement Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Engagement Rate',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),

                  // Calculate engagement rate (likes divided by views)
                  _buildEngagementMeter(
                    context,
                    video.viewCount > 0
                        ? (video.likeCount / video.viewCount) * 100
                        : 0.0,
                  ),
                ],
              ),
            ),
          ),

          // Add extra space at the bottom to ensure content is not covered by navigation bar
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildEngagementMeter(BuildContext context, double percentage) {
    // Cap at 100%
    percentage = percentage > 100 ? 100 : percentage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              percentage < 5
                  ? 'Low Engagement'
                  : percentage < 15
                  ? 'Average Engagement'
                  : 'High Engagement',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: percentage / 100,
          minHeight: 10,
          borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    SkillModel skill,
    String? currentUserId,
  ) {
    final double iconSize = 26;
    final double bgSize = 44;
    final Color iconColor = Colors.white;
    final TextStyle countStyle = TextStyle(
      color: Colors.white.withOpacity(0.92),
      fontSize: 12,
      fontWeight: FontWeight.w600,
      shadows: [Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 2)],
    );

    Widget glassButton({
      required Widget icon,
      required VoidCallback onTap,
      required String count,
      String? semanticLabel,
      bool isActive = false,
    }) {
      return GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            AnimatedScale(
              scale: 1.0,
              duration: const Duration(milliseconds: 120),
              child: Container(
                width: bgSize,
                height: bgSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.18),
                      Colors.white.withOpacity(0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(alignment: Alignment.center, child: icon),
                  ),
                ),
              ),
            ),
            if (count.isNotEmpty) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.10),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(count, style: countStyle),
              ),
            ],
          ],
        ),
      );
    }

    return Positioned(
      right: 16,
      bottom: 110,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentUserId != null) ...[
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
                    data: (isLiked) => glassButton(
                      icon: Icon(
                        Icons.favorite,
                        color: isLiked ? Colors.redAccent : iconColor,
                        size: iconSize,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      onTap: () => notifier.toggleLike(currentUserId, skill.id),
                      count: likeCount.toString(),
                      semanticLabel: 'Like',
                      isActive: isLiked,
                    ),
                    loading: () => glassButton(
                      icon: Icon(
                        Icons.favorite_border,
                        color: iconColor,
                        size: iconSize,
                      ),
                      onTap: () {},
                      count: likeCount.toString(),
                    ),
                    error: (_, __) => glassButton(
                      icon: Icon(
                        Icons.favorite_border,
                        color: iconColor,
                        size: iconSize,
                      ),
                      onTap: () {},
                      count: likeCount.toString(),
                    ),
                  ),
                  loading: () => glassButton(
                    icon: Icon(
                      Icons.favorite_border,
                      color: iconColor,
                      size: iconSize,
                    ),
                    onTap: () {},
                    count: '0',
                  ),
                  error: (_, __) => glassButton(
                    icon: Icon(
                      Icons.favorite_border,
                      color: iconColor,
                      size: iconSize,
                    ),
                    onTap: () {},
                    count: '0',
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Comment Button
            Consumer(
              builder: (context, ref, _) {
                final commentsAsync = ref.watch(commentsProvider(skill.id));
                return commentsAsync.when(
                  data: (comments) => glassButton(
                    icon: Icon(
                      Icons.comment,
                      color: iconColor,
                      size: iconSize,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => CommentsBottomSheet(skillId: skill.id),
                      );
                    },
                    count: comments.length.toString(),
                    semanticLabel: 'Comments',
                  ),
                  loading: () => glassButton(
                    icon: Icon(Icons.comment, color: iconColor, size: iconSize),
                    onTap: () {},
                    count: '0',
                  ),
                  error: (_, __) => glassButton(
                    icon: Icon(Icons.comment, color: iconColor, size: iconSize),
                    onTap: () {},
                    count: '0',
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Share Button
            SizedBox(
              width: bgSize,
              height: bgSize,
              child: ShareButton(
                skillId: skill.id,
                skill: skill,
                vertical: true,
              ),
            ),
            const SizedBox(height: 16),
            // Save/Bookmark Button
            Consumer(
              builder: (context, ref, _) {
                final isBookmarkedAsync = ref.watch(
                  isBookmarkedProvider((currentUserId, skill.id)),
                );
                final bookmarksNotifier = ref.read(bookmarksProvider.notifier);
                return isBookmarkedAsync.when(
                  data: (isBookmarked) => glassButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: iconColor,
                      size: iconSize,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    onTap: () => bookmarksNotifier.toggleBookmark(
                      currentUserId,
                      skill.id,
                    ),
                    count: '',
                    semanticLabel: 'Save',
                    isActive: isBookmarked,
                  ),
                  loading: () => glassButton(
                    icon: Icon(
                      Icons.bookmark_border,
                      color: iconColor,
                      size: iconSize,
                    ),
                    onTap: () {},
                    count: '',
                  ),
                  error: (_, __) => glassButton(
                    icon: Icon(
                      Icons.bookmark_border,
                      color: iconColor,
                      size: iconSize,
                    ),
                    onTap: () {},
                    count: '',
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMultipleVideosView(BuildContext context) {
    return _MultiVideoViewer(skills: skills!, initialIndex: initialIndex);
  }
}

// Extracted the original functionality into a separate widget
class _MultiVideoViewer extends ConsumerStatefulWidget {
  final List<SkillModel> skills;
  final int initialIndex;

  const _MultiVideoViewer({required this.skills, required this.initialIndex});

  @override
  ConsumerState<_MultiVideoViewer> createState() => _MultiVideoViewerState();
}

class _MultiVideoViewerState extends ConsumerState<_MultiVideoViewer> {
  late final PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _pageController.addListener(() {
      final newPage = _pageController.page?.round();
      if (newPage != null && newPage != _currentPage) {
        setState(() {
          _currentPage = newPage;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/feed'),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.skills.length,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          final skill = widget.skills[index];
          return Stack(
            fit: StackFit.expand,
            children: [
              VideoPlayerWidget(skill: skill, isActive: index == _currentPage),
              // Social action buttons on the right
              _buildActionButtons(context, skill, user?.id),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    SkillModel skill,
    String? currentUserId,
  ) {
    final double iconSize = 26;
    final double bgSize = 44;
    final Color iconColor = Colors.white;
    final TextStyle countStyle = TextStyle(
      color: Colors.white.withOpacity(0.92),
      fontSize: 12,
      fontWeight: FontWeight.w600,
      shadows: [Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 2)],
    );

    Widget glassButton({
      required Widget icon,
      required VoidCallback onTap,
      required String count,
      String? semanticLabel,
      bool isActive = false,
    }) {
      return GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            AnimatedScale(
              scale: 1.0,
              duration: const Duration(milliseconds: 120),
              child: Container(
                width: bgSize,
                height: bgSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.18),
                      Colors.white.withOpacity(0.08),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: ClipOval(
                  child: BackdropFilter(
                    filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(alignment: Alignment.center, child: icon),
                  ),
                ),
              ),
            ),
            if (count.isNotEmpty) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.10),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(count, style: countStyle),
              ),
            ],
          ],
        ),
      );
    }

    return Positioned(
      right: 16,
      bottom: 110,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (currentUserId != null) ...[
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
                    data: (isLiked) => glassButton(
                      icon: Icon(
                        Icons.favorite,
                        color: isLiked ? Colors.redAccent : iconColor,
                        size: iconSize,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      onTap: () => notifier.toggleLike(currentUserId, skill.id),
                      count: likeCount.toString(),
                      semanticLabel: 'Like',
                      isActive: isLiked,
                    ),
                    loading: () => glassButton(
                      icon: Icon(
                        Icons.favorite_border,
                        color: iconColor,
                        size: iconSize,
                      ),
                      onTap: () {},
                      count: likeCount.toString(),
                    ),
                    error: (_, __) => glassButton(
                      icon: Icon(
                        Icons.favorite_border,
                        color: iconColor,
                        size: iconSize,
                      ),
                      onTap: () {},
                      count: likeCount.toString(),
                    ),
                  ),
                  loading: () => glassButton(
                    icon: Icon(
                      Icons.favorite_border,
                      color: iconColor,
                      size: iconSize,
                    ),
                    onTap: () {},
                    count: '0',
                  ),
                  error: (_, __) => glassButton(
                    icon: Icon(
                      Icons.favorite_border,
                      color: iconColor,
                      size: iconSize,
                    ),
                    onTap: () {},
                    count: '0',
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Comment Button
            Consumer(
              builder: (context, ref, _) {
                final commentsAsync = ref.watch(commentsProvider(skill.id));
                return commentsAsync.when(
                  data: (comments) => glassButton(
                    icon: Icon(
                      Icons.comment,
                      color: iconColor,
                      size: iconSize,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (_) => CommentsBottomSheet(skillId: skill.id),
                      );
                    },
                    count: comments.length.toString(),
                    semanticLabel: 'Comments',
                  ),
                  loading: () => glassButton(
                    icon: Icon(Icons.comment, color: iconColor, size: iconSize),
                    onTap: () {},
                    count: '0',
                  ),
                  error: (_, __) => glassButton(
                    icon: Icon(Icons.comment, color: iconColor, size: iconSize),
                    onTap: () {},
                    count: '0',
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            // Share Button
            SizedBox(
              width: bgSize,
              height: bgSize,
              child: ShareButton(
                skillId: skill.id,
                skill: skill,
                vertical: true,
              ),
            ),
            const SizedBox(height: 16),
            // Save/Bookmark Button
            Consumer(
              builder: (context, ref, _) {
                final isBookmarkedAsync = ref.watch(
                  isBookmarkedProvider((currentUserId, skill.id)),
                );
                final bookmarksNotifier = ref.read(bookmarksProvider.notifier);
                return isBookmarkedAsync.when(
                  data: (isBookmarked) => glassButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: iconColor,
                      size: iconSize,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    onTap: () => bookmarksNotifier.toggleBookmark(
                      currentUserId,
                      skill.id,
                    ),
                    count: '',
                    semanticLabel: 'Save',
                    isActive: isBookmarked,
                  ),
                  loading: () => glassButton(
                    icon: Icon(
                      Icons.bookmark_border,
                      color: iconColor,
                      size: iconSize,
                    ),
                    onTap: () {},
                    count: '',
                  ),
                  error: (_, __) => glassButton(
                    icon: Icon(
                      Icons.bookmark_border,
                      color: iconColor,
                      size: iconSize,
                    ),
                    onTap: () {},
                    count: '',
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
