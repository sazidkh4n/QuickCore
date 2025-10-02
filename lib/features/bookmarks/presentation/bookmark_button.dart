import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bookmarks_provider.dart';

class BookmarkButton extends ConsumerWidget {
  final String userId;
  final String skillId;
  final bool vertical;

  const BookmarkButton({
    super.key,
    required this.userId,
    required this.skillId,
    this.vertical = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBookmarkedAsync = ref.watch(isBookmarkedProvider((userId, skillId)));

    return isBookmarkedAsync.when(
      data: (isBookmarked) {
        if (vertical) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: isBookmarked ? Colors.amber : Colors.white,
                  size: 35,
                ),
                onPressed: () {
                  ref
                      .read(bookmarksProvider.notifier)
                      .toggleBookmark(userId, skillId);
                },
              ),
              const Text('Save', style: TextStyle(color: Colors.white)),
            ],
          );
        }
        return IconButton(
          icon: Icon(
            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: isBookmarked
                ? Colors.amber
                : Theme.of(context).colorScheme.primary,
          ),
          onPressed: () {
            ref
                .read(bookmarksProvider.notifier)
                .toggleBookmark(userId, skillId);
          },
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (err, stack) => const Icon(Icons.error),
    );
  }
} 