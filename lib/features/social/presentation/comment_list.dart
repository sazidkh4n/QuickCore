import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/social_provider.dart';
import 'package:quickcore/shared/widgets/skeleton_loader.dart';

class CommentList extends ConsumerStatefulWidget {
  final String userId;
  final String skillId;
  const CommentList({super.key, required this.userId, required this.skillId});

  @override
  ConsumerState<CommentList> createState() => _CommentListState();
}

class _CommentListState extends ConsumerState<CommentList> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsProvider(widget.skillId));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Comments', style: TextStyle(fontWeight: FontWeight.bold)),
        commentsAsync.when(
          loading: () => SkeletonLoader(type: SkeletonType.list, itemCount: 5),
          error: (e, _) => Text('Error: $e'),
          data: (list) => list.isEmpty
              ? const Text('No comments yet.')
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final c = list[i];
                    final displayNameAsync = ref.watch(displayNameProvider(c.userId));
                    return ListTile(
                      leading: SkeletonCircle(size: 32),
                      title: Text(c.content),
                      subtitle: displayNameAsync.when(
                        data: (displayName) => Text('$displayName • ${c.createdAt}'),
                        loading: () => Text('Loading... • ${c.createdAt}'),
                        error: (_, __) => Text('User_${c.userId.substring(0, 8)} • ${c.createdAt}'),
                      ),
                    );
                  },
                ),
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(hintText: 'Add a comment...'),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () async {
                if (_controller.text.trim().isEmpty) return;
                await CommentActions.add(widget.userId, widget.skillId, _controller.text.trim());
                _controller.clear();
                ref.invalidate(commentsProvider(widget.skillId));
              },
            ),
          ],
        ),
      ],
    );
  }
} 