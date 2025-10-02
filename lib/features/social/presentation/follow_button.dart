import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/social_provider.dart';

class FollowButton extends ConsumerWidget {
  final String followerId;
  final String followedId;
  final bool showFollowerCount;
  const FollowButton({super.key, required this.followerId, required this.followedId, this.showFollowerCount = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followKey = '$followerId|$followedId';
    final isFollowingAsync = ref.watch(followsProvider(followKey));
    final followerCountAsync = ref.watch(followerCountProvider(followedId));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        isFollowingAsync.when(
          data: (isFollowing) => ElevatedButton(
            onPressed: () async {
              if (isFollowing) {
                await FollowActions.unfollow(followerId, followedId);
              } else {
                await FollowActions.follow(followerId, followedId);
              }
              ref.invalidate(followsProvider(followKey));
              ref.invalidate(followerCountProvider(followedId));
            },
            child: Text(isFollowing ? 'Unfollow' : 'Follow'),
          ),
          loading: () => const ElevatedButton(onPressed: null, child: Text('...')),
          error: (e, __) => const ElevatedButton(onPressed: null, child: Text('Error')),
        ),
        if (showFollowerCount) ...[
          const SizedBox(width: 8),
          followerCountAsync.when(
            data: (count) => Text('$count followers'),
            loading: () => const Text('...'),
            error: (e, __) => const Text('?'),
          ),
        ],
      ],
    );
  }
} 