import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:quickcore/features/profile/providers/profile_providers.dart';
import 'package:flutter/services.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/comment_model.dart';
import '../providers/social_provider.dart';

class CommentsBottomSheet extends ConsumerStatefulWidget {
  final String skillId;

  const CommentsBottomSheet({super.key, required this.skillId});

  @override
  ConsumerState<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends ConsumerState<CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  CommentModel? _replyingToComment;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    HapticFeedback.lightImpact();

    final user = ref.read(authProvider).value;
    if (user == null) return;

    await ref.read(socialProvider.notifier).addComment(
          widget.skillId,
          user.id,
          text,
          parentCommentId: _replyingToComment?.id,
        );

    _commentController.clear();
    setState(() {
      _replyingToComment = null;
    });
    FocusScope.of(context).unfocus(); // Dismiss keyboard
    // Invalidate based on whether it's a top-level comment or a reply
    if (_replyingToComment != null) {
      ref.invalidate(repliesProvider(_replyingToComment!.id));
    } else {
      ref.invalidate(commentsProvider(widget.skillId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsProvider(widget.skillId));
    final user = ref.watch(authProvider).value;
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Material(
      color: Colors.transparent,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF2C2C2E),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Draggable Handle
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.symmetric(vertical: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                // Comments Count
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: commentsAsync.when(
                    data: (comments) => Text(
                      '${comments.length} Comments',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    loading: () => const Text('Loading...',
                        style: TextStyle(color: Colors.white)),
                    error: (e, st) => const Text('Error',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
                const Divider(color: Colors.grey, height: 1),
                // Comments List
                Expanded(
                  child: commentsAsync.when(
                    data: (comments) {
                      if (comments.isEmpty) {
                        return const Center(
                            child: Text('Be the first to comment!',
                                style: TextStyle(color: Colors.white70)));
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          return CommentTile(
                            comment: comment,
                            onReply: (parentComment) {
                              setState(() {
                                _replyingToComment = parentComment;
                              });
                              FocusScope.of(context).requestFocus(FocusNode()); // Refocus text field
                            },
                          );
                        },
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, st) =>
                        Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
                  ),
                ),
                // Input Field
                if (user != null)
                  Container(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, keyboardPadding > 0 ? keyboardPadding + 8 : 24),
                    color: const Color(0xFF2C2C2E),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_replyingToComment != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0, left: 12.0),
                            child: Consumer(builder: (context, ref, _) {
                              final userProfileAsync = ref.watch(
                                  userProfileProvider(_replyingToComment!.userId));
                              return Row(
                                children: [
                                  Text(
                                    'Replying to ',
                                    style: TextStyle(
                                        color: Colors.white54, fontSize: 12),
                                  ),
                                  Text(
                                    userProfileAsync.when(
                                      data: (user) => user.name ?? (user.username != null ? '@${user.username}' : 'User'),
                                      loading: () => '...',
                                      error: (e, s) => 'User',
                                    ),
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _replyingToComment = null;
                                      });
                                    },
                                    child: const Icon(Icons.close,
                                        color: Colors.white54, size: 16),
                                  )
                                ],
                              );
                            }),
                          ),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _commentController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: _replyingToComment == null
                                      ? 'Add a comment...'
                                      : 'Add a reply...',
                                  hintStyle:
                                      TextStyle(color: Colors.white.withOpacity(0.7)),
                                  filled: true,
                                  fillColor: const Color(0xFF1C1C1E),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding:
                                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.send, color: Colors.white),
                              onPressed: _addComment,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CommentTile extends ConsumerStatefulWidget {
  final CommentModel comment;
  final Function(CommentModel) onReply;
  final bool isReply;

  const CommentTile({
    super.key,
    required this.comment,
    required this.onReply,
    this.isReply = false,
  });

  @override
  ConsumerState<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends ConsumerState<CommentTile> {
  bool _showReplies = false;

  @override
  Widget build(BuildContext context) {
    final userProfileAsync =
        ref.watch(userProfileProvider(widget.comment.userId));
    final repliesAsync = ref.watch(repliesProvider(widget.comment.id));
    final currentUserId = ref.watch(authProvider).value?.id;

    final avatar = userProfileAsync.when(
      data: (user) => CircleAvatar(
        radius: widget.isReply ? 16 : 20,
        backgroundImage:
            user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
        child: user.avatarUrl == null ? const Icon(Icons.person) : null,
      ),
      loading: () => CircleAvatar(
          radius: widget.isReply ? 16 : 20,
          child: const CircularProgressIndicator()),
      error: (e, st) => CircleAvatar(
          radius: widget.isReply ? 16 : 20,
          child: const Icon(Icons.person)),
    );

    final commentBody = Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          userProfileAsync.when(
            data: (user) => Text(
              user.name ?? (user.username != null ? '@${user.username}' : 'User'),
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
            ),
            loading: () => const Text('...',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
            error: (e, st) => const Text('User',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
          ),
          const SizedBox(height: 4),
          Text(widget.comment.content,
              style: const TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                timeago.format(widget.comment.createdAt),
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(width: 24),
              GestureDetector(
                onTap: () => widget.onReply(widget.comment),
                child: const Text('Reply',
                    style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );

    final likeButton = currentUserId != null
        ? CommentLikeButton(
            userId: currentUserId,
            commentId: widget.comment.id,
          )
        : const SizedBox.shrink();

    return Stack(
      children: [
        if (widget.isReply)
          Positioned.fill(
            child: CustomPaint(
              painter: ReplyLinePainter(
                avatarRadius: 16, // radius for reply avatar
                parentAvatarRadius: 20, // radius for parent avatar
              ),
            ),
          ),
        Padding(
          padding: EdgeInsets.only(
            left: widget.isReply ? 48.0 : 16.0,
            right: 16.0,
            top: 8.0,
            bottom: 8.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  avatar,
                  const SizedBox(width: 12),
                  commentBody,
                  likeButton,
                ],
              ),
              if (!widget.isReply)
                repliesAsync.when(
                  data: (replies) {
                    if (replies.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(left: 60.0, top: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_showReplies)
                            ...replies.map((reply) => CommentTile(
                                  comment: reply,
                                  onReply: widget.onReply,
                                  isReply: true,
                                )),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showReplies = !_showReplies;
                              });
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 1,
                                  color: Colors.grey.shade700,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _showReplies
                                      ? 'Hide replies'
                                      : 'View all ${replies.length} replies',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.only(left: 60.0, top: 8.0),
                    child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  error: (e, st) => const SizedBox.shrink(),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class ReplyLinePainter extends CustomPainter {
  final double parentAvatarRadius;
  final double avatarRadius;

  ReplyLinePainter({
    required this.parentAvatarRadius,
    required this.avatarRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = 1.5;

    // The thread line should start from below the parent's avatar
    // and go to the current reply's avatar.
    
    final parentCenterY = -8.0; // Starting point above the tile
    final thisCenterY = avatarRadius; // Y center of this reply's avatar

    // Vertical line coming down from parent
    canvas.drawLine(Offset(-24, parentCenterY), Offset(-24, thisCenterY), paint);

    // Horizontal line connecting to this reply's avatar
    canvas.drawLine(Offset(-24, thisCenterY), Offset(0, thisCenterY), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class CommentLikeButton extends ConsumerWidget {
  final String userId;
  final String commentId;
  const CommentLikeButton(
      {super.key, required this.userId, required this.commentId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLiked = ref.watch(isCommentLikedProvider((userId, commentId)));
    final likeCount = ref.watch(commentLikeCountProvider(commentId));

    return GestureDetector(
      onTap: () =>
          ref.read(socialProvider.notifier).toggleCommentLike(userId, commentId),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          isLiked.when(
            data: (d) => Icon(d ? Icons.favorite : Icons.favorite_border,
                color: d ? Colors.red : Colors.grey.shade400, size: 20),
            loading: () =>
                Icon(Icons.favorite_border, color: Colors.grey.shade400, size: 20),
            error: (e, s) =>
                Icon(Icons.favorite_border, color: Colors.grey.shade400, size: 20),
          ),
          const SizedBox(height: 2),
          likeCount.when(
            data: (d) => Text(
              d.toString(),
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
            loading: () => const SizedBox.shrink(),
            error: (e, s) => const SizedBox.shrink(),
          )
        ],
      ),
    );
  }
} 