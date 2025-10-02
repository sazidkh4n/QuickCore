import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickcore/features/auth/data/user_model.dart';
import 'package:quickcore/features/auth/providers/auth_provider.dart';
import 'package:quickcore/features/profile/providers/profile_providers.dart';
import 'package:quickcore/shared/widgets/cached_network_image.dart';
import 'dart:ui';
import 'dart:developer' as dev;

class UserProfileHeader extends ConsumerStatefulWidget {
  final UserModel user;
  final bool isCurrentUser;

  const UserProfileHeader({
    required this.user,
    required this.isCurrentUser,
    super.key,
  });

  @override
  ConsumerState<UserProfileHeader> createState() => _UserProfileHeaderState();
}

class _UserProfileHeaderState extends ConsumerState<UserProfileHeader>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _statsController;
  late Animation<double> _headerAnimation;
  late Animation<double> _statsAnimation;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _statsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _headerAnimation = CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    );
    _statsAnimation = CurvedAnimation(
      parent: _statsController,
      curve: Curves.easeOutCubic,
    );

    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _statsController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _statsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isTutor = widget.user.role == 'tutor';

    // Get live stats
    final followers = ref.watch(followerCountProvider(widget.user.id));
    final following = ref.watch(followingCountProvider(widget.user.id));
    final likes = ref.watch(userTotalLikesProvider(widget.user.id));

    // Check if current user is following this profile
    final currentUser = ref.watch(authProvider).value;
    final isFollowing = currentUser != null && !widget.isCurrentUser
        ? ref.watch(isFollowingProvider((currentUser.id, widget.user.id)))
        : null;

    dev.log('UserProfileHeader avatar URL: ${widget.user.avatarUrl}');

    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _headerAnimation.value) * 50),
          child: Opacity(opacity: _headerAnimation.value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Stack(
          children: [
            // Background with glassmorphism effect
            Container(
              height: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isTutor
                      ? [
                          colorScheme.primary.withOpacity(0.8),
                          colorScheme.secondary.withOpacity(0.6),
                          colorScheme.tertiary.withOpacity(0.4),
                        ]
                      : [
                          colorScheme.secondary.withOpacity(0.6),
                          colorScheme.primary.withOpacity(0.4),
                          colorScheme.surface.withOpacity(0.8),
                        ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 24,
                    spreadRadius: 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
            ),

            // Glassmorphism overlay
            ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: 320,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

            // Content
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 6),

                    // Avatar with glow effect
                    _buildAnimatedAvatar(isTutor, colorScheme),

                    const SizedBox(height: 6),

                    // Name and role
                    _buildUserInfo(theme, isTutor),

                    const SizedBox(height: 4),

                    // Bio
                    if (widget.user.bio != null && widget.user.bio!.isNotEmpty)
                      Flexible(child: _buildBio(theme)),

                    const Spacer(),

                    // Stats row
                    AnimatedBuilder(
                      animation: _statsAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _statsAnimation.value,
                          child: _buildStatsRow(
                            followers,
                            following,
                            likes,
                            theme,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 4),

                    // Action buttons
                    _buildActionButtons(
                      context,
                      isFollowing,
                      isTutor,
                      colorScheme,
                    ),
                  ],
                ),
              ),
            ),

            // Role badge
            if (isTutor)
              Positioned(
                top: 16,
                right: 16,
                child: _buildRoleBadge(colorScheme),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedAvatar(bool isTutor, ColorScheme colorScheme) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: isTutor
                      ? colorScheme.primary.withOpacity(0.4)
                      : colorScheme.secondary.withOpacity(0.3),
                  blurRadius: isTutor ? 32 : 24,
                  spreadRadius: isTutor ? 8 : 4,
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 45,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: ClipOval(
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child:
                      widget.user.avatarUrl != null &&
                          widget.user.avatarUrl!.isNotEmpty
                      ? SafeNetworkImage(
                          imageUrl: widget.user.avatarUrl,
                          fit: BoxFit.cover,
                          errorWidget: Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.white.withOpacity(0.8),
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserInfo(ThemeData theme, bool isTutor) {
    return Column(
      children: [
        Text(
          widget.user.name ?? 'No Name',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        if (widget.user.username != null) ...[
          const SizedBox(height: 4),
          Text(
            '@${widget.user.username!}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBio(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        widget.user.bio!,
        style: theme.textTheme.bodySmall?.copyWith(
          color: Colors.white.withOpacity(0.9),
          height: 1.3,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStatsRow(
    AsyncValue<int> followers,
    AsyncValue<int> following,
    AsyncValue<int> likes,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Following',
            following.when(
              data: (val) => _formatCount(val),
              loading: () => '...',
              error: (e, s) => '0',
            ),
            Icons.person_add_outlined,
            theme,
          ),
          _buildStatDivider(),
          _buildStatItem(
            'Followers',
            followers.when(
              data: (val) => _formatCount(val),
              loading: () => '...',
              error: (e, s) => '0',
            ),
            Icons.people_outlined,
            theme,
          ),
          _buildStatDivider(),
          _buildStatItem(
            'Likes',
            likes.when(
              data: (val) => _formatCount(val),
              loading: () => '...',
              error: (e, s) => '0',
            ),
            Icons.favorite_outline,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    ThemeData theme,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
        const SizedBox(height: 4),
        TweenAnimationBuilder<int>(
          tween: IntTween(
            begin: 0,
            end: int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
          ),
          duration: const Duration(milliseconds: 1500),
          builder: (context, animatedValue, child) {
            return Text(
              value.contains('K') || value.contains('M')
                  ? value
                  : animatedValue.toString(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          },
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    AsyncValue<bool>? isFollowing,
    bool isTutor,
    ColorScheme colorScheme,
  ) {
    if (widget.isCurrentUser) {
      return _buildCurrentUserActions(context, colorScheme);
    } else {
      return _buildOtherUserActions(context, isFollowing, colorScheme);
    }
  }

  Widget _buildCurrentUserActions(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => context.push('/edit-profile'),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              elevation: 0,
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () => context.push('/settings'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.2),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
            ),
            elevation: 0,
          ),
          child: const Icon(Icons.settings_outlined),
        ),
      ],
    );
  }

  Widget _buildOtherUserActions(
    BuildContext context,
    AsyncValue<bool>? isFollowing,
    ColorScheme colorScheme,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child:
              isFollowing?.when(
                data: (following) => ElevatedButton.icon(
                  onPressed: () => _handleFollowToggle(following),
                  icon: Icon(
                    following ? Icons.person_remove : Icons.person_add,
                  ),
                  label: Text(following ? 'Unfollow' : 'Follow'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: following
                        ? Colors.white.withOpacity(0.2)
                        : Colors.white,
                    foregroundColor: following
                        ? Colors.white
                        : colorScheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    elevation: 0,
                  ),
                ),
                loading: () => const ElevatedButton(
                  onPressed: null,
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                error: (e, s) => ElevatedButton.icon(
                  onPressed: () => _handleFollowToggle(false),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Follow'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: colorScheme.primary,
                  ),
                ),
              ) ??
              const SizedBox(),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () => _handleMessage(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.2),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
            ),
            elevation: 0,
          ),
          child: const Icon(Icons.message_outlined),
        ),
      ],
    );
  }

  Widget _buildRoleBadge(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.school, size: 16, color: Colors.white.withOpacity(0.9)),
          const SizedBox(width: 4),
          Text(
            'Tutor',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _handleFollowToggle(bool isCurrentlyFollowing) {
    final currentUser = ref.read(authProvider).value;
    if (currentUser == null) return;

    if (isCurrentlyFollowing) {
      ref.read(unfollowUserProvider((currentUser.id, widget.user.id)));
    } else {
      ref.read(followUserProvider((currentUser.id, widget.user.id)));
    }
  }

  void _handleMessage(BuildContext context) {
    context.push(
      '/chat/${widget.user.id}?name=${Uri.encodeComponent(widget.user.name ?? 'User')}&avatar=${Uri.encodeComponent(widget.user.avatarUrl ?? '')}',
    );
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '${(count / 1000000).toStringAsFixed(1)}M';
  }
}
