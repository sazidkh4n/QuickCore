import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../providers/profile_providers.dart' as profile_providers;
import 'video_viewer_screen.dart';

class UserProfileScreen extends ConsumerWidget {
  final String userId;
  const UserProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(profile_providers.userProfileProvider(userId));
    final userSkills = ref.watch(profile_providers.skillsByCreatorProvider(userId));
    final currentUserId = ref.watch(authProvider).value?.id;

    return Scaffold(
      appBar: AppBar(
        title: userProfileAsync.when(
          data: (user) => Text(user.name ?? 'Profile'),
          loading: () => const Text('Profile'),
          error: (_, __) => const Text('Profile'),
        ),
      ),
      body: userProfileAsync.when(
        data: (user) => NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: user.avatarUrl != null
                          ? NetworkImage(user.avatarUrl!)
                          : null,
                      child: user.avatarUrl == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(user.name ?? 'No Name',
                        style: Theme.of(context).textTheme.headlineSmall),
                    Text('@${user.username ?? 'user'}',
                        style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 16),
                    _StatsRow(userId: userId),
                    const SizedBox(height: 16),
                    if (currentUserId != null && currentUserId != userId)
                      _FollowButton(
                          currentUserId: currentUserId, profileUserId: userId),
                  ],
                ),
              ),
            ),
          ],
          body: userSkills.when(
            data: (skills) => GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: skills.length,
              itemBuilder: (context, index) {
                final skill = skills[index];
                if (skill.thumbnailUrl == null) {
                  return const Icon(Icons.videocam_off);
                }
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => VideoViewerScreen(
                          skills: skills,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                  child: Image.network(
                    skill.thumbnailUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error);
                    },
                  ),
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error loading skills: $e')),
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading profile: $e')),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final String userId;
  const _StatsRow({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(
            label: 'Following',
            statProvider: profile_providers.followingCountProvider(userId)),
        _StatItem(
            label: 'Followers',
            statProvider: profile_providers.followerCountProvider(userId)),
        _StatItem(
            label: 'Likes',
            statProvider: profile_providers.userTotalLikesProvider(userId)),
      ],
    );
  }
}

class _StatItem extends ConsumerWidget {
  final String label;
  final ProviderBase<AsyncValue<int>> statProvider;

  const _StatItem({required this.label, required this.statProvider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(statProvider);
    return Column(
      children: [
        count.when(
          data: (value) => Text(value.toString(),
              style: Theme.of(context).textTheme.titleLarge),
          loading: () => const SizedBox(
              width: 20, height: 20, child: CircularProgressIndicator()),
          error: (_, __) => const Text('0'),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _FollowButton extends ConsumerWidget {
  final String currentUserId;
  final String profileUserId;

  const _FollowButton(
      {required this.currentUserId, required this.profileUserId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFollowingAsync =
        ref.watch(profile_providers.isFollowingProvider((currentUserId, profileUserId)));

    return isFollowingAsync.when(
      data: (isFollowing) => ElevatedButton(
        onPressed: () {
          if (isFollowing) {
            ref.read(
                profile_providers.unfollowUserProvider((currentUserId, profileUserId)));
          } else {
            ref.read(
                profile_providers.followUserProvider((currentUserId, profileUserId)));
          }
        },
        child: Text(isFollowing ? 'Unfollow' : 'Follow'),
      ),
      loading: () => const ElevatedButton(
        onPressed: null,
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, __) =>
          const ElevatedButton(onPressed: null, child: Text('Error')),
    );
  }
} 