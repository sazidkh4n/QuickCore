import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/social_provider.dart';

class LikeButton extends ConsumerWidget {
  final String userId;
  final String skillId;
  final bool vertical;

  const LikeButton({
    super.key,
    required this.userId,
    required this.skillId,
    this.vertical = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likeState = ref.watch(likeStateProvider((userId, skillId)));
    final likeCount = ref.watch(likeCountProvider(skillId));

    final isLiked = likeState.value ?? false;

    void handleLike() {
      ref.read(socialProvider.notifier).toggleLike(userId, skillId);
    }

    if (vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              isLiked ? Icons.favorite : Icons.favorite_border,
              color: isLiked ? Colors.red : Colors.white,
              size: 35,
            ),
            onPressed: handleLike,
          ),
          likeCount.when(
            data: (count) => Text(count.toString(), style: const TextStyle(color: Colors.white)),
            loading: () => const Text('0', style: TextStyle(color: Colors.white)),
            error: (_, __) => const Text('0', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    }

    return Row(
      children: [
        IconButton(
          icon: Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? Colors.red : Colors.white,
          ),
          onPressed: handleLike,
        ),
        likeCount.when(
          data: (count) => Text(count.toString(), style: const TextStyle(color: Colors.white)),
          loading: () => const SizedBox(),
          error: (_, __) => const SizedBox(),
        ),
      ],
    );
  }
} 