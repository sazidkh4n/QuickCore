import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:quickcore/features/notifications/data/enhanced_chat_message_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class EnhancedMessageBubble extends StatefulWidget {
  final EnhancedChatMessageModel message;
  final bool isMe;
  final bool showAvatar;
  final bool showTimestamp;
  final String? otherUserAvatar;
  final VoidCallback? onReply;
  final VoidCallback? onReact;
  final VoidCallback? onLongPress;

  const EnhancedMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.showAvatar = true,
    this.showTimestamp = true,
    this.otherUserAvatar,
    this.onReply,
    this.onReact,
    this.onLongPress,
  });

  @override
  State<EnhancedMessageBubble> createState() => _EnhancedMessageBubbleState();
}

class _EnhancedMessageBubbleState extends State<EnhancedMessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _showActions = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onLongPress() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    
    setState(() {
      _showActions = true;
    });
    
    widget.onLongPress?.call();
    
    // Hide actions after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showActions = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        children: [
          // Reply preview
          if (widget.message.replyToMessageId != null)
            _buildReplyPreview(theme),
          
          // Main message
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              // Other user's avatar
              if (!widget.isMe && widget.showAvatar)
                _buildAvatar()
              else if (!widget.isMe && !widget.showAvatar)
                const SizedBox(width: 40),
              
              const SizedBox(width: 8),
              
              // Message content
              Flexible(
                child: GestureDetector(
                  onLongPress: _onLongPress,
                  onTap: () {
                    if (_showActions) {
                      setState(() {
                        _showActions = false;
                      });
                    }
                  },
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      crossAxisAlignment: widget.isMe 
                          ? CrossAxisAlignment.end 
                          : CrossAxisAlignment.start,
                      children: [
                        // Message bubble
                        _buildMessageBubble(theme),
                        
                        // Message reactions
                        if (widget.message.reactions.isNotEmpty)
                          _buildReactions(theme),
                        
                        // Quick actions
                        if (_showActions)
                          _buildQuickActions(theme),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 8),
              
              // My avatar space (for alignment)
              if (widget.isMe && widget.showAvatar)
                const SizedBox(width: 40)
              else if (widget.isMe && !widget.showAvatar)
                const SizedBox(width: 40),
            ],
          ),
          
          // Timestamp
          if (widget.showTimestamp)
            _buildTimestamp(theme),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      backgroundImage: widget.otherUserAvatar != null
          ? CachedNetworkImageProvider(widget.otherUserAvatar!)
          : null,
      child: widget.otherUserAvatar == null
          ? Icon(
              Icons.person,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
    );
  }

  Widget _buildMessageBubble(ThemeData theme) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: widget.isMe
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: widget.isMe ? const Radius.circular(20) : const Radius.circular(4),
          bottomRight: widget.isMe ? const Radius.circular(4) : const Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Message content based on type
          _buildMessageContent(theme),
          
          // Message status and time
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeago.format(widget.message.createdAt, locale: 'en_short'),
                style: TextStyle(
                  fontSize: 11,
                  color: widget.isMe
                      ? Colors.white.withOpacity(0.7)
                      : theme.colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              if (widget.isMe) ...[
                const SizedBox(width: 4),
                Icon(
                  _getStatusIcon(widget.message.status),
                  size: 14,
                  color: Colors.white.withOpacity(0.7),
                ),
              ],
              if (widget.message.isEdited == true) ...[
                const SizedBox(width: 4),
                Text(
                  'edited',
                  style: TextStyle(
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                    color: widget.isMe
                        ? Colors.white.withOpacity(0.5)
                        : theme.colorScheme.onSurface.withOpacity(0.4),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(ThemeData theme) {
    switch (widget.message.messageType) {
      case MessageType.text:
        return _buildTextContent(theme);
      case MessageType.image:
        return _buildImageContent(theme);
      case MessageType.video:
        return _buildVideoContent(theme);
      case MessageType.file:
        return _buildFileContent(theme);
      case MessageType.audio:
        return _buildAudioContent(theme);
      default:
        return _buildTextContent(theme);
    }
  }

  Widget _buildTextContent(ThemeData theme) {
    if (widget.message.message == null || widget.message.message!.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return SelectableText(
      widget.message.message!,
      style: TextStyle(
        color: widget.isMe ? Colors.white : theme.colorScheme.onSurface,
        fontSize: 16,
        height: 1.3,
      ),
    );
  }

  Widget _buildImageContent(ThemeData theme) {
    final attachment = widget.message.mediaAttachment;
    if (attachment == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: attachment.url,
            width: 200,
            height: 200,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: 200,
              height: 200,
              color: theme.colorScheme.surfaceVariant,
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              width: 200,
              height: 200,
              color: theme.colorScheme.errorContainer,
              child: const Icon(Icons.error),
            ),
          ),
        ),
        if (widget.message.message != null && widget.message.message!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            widget.message.message!,
            style: TextStyle(
              color: widget.isMe ? Colors.white : theme.colorScheme.onSurface,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVideoContent(ThemeData theme) {
    // Check if this is a shared video from feed
    final videoData = widget.message.metadata?['videoData'];
    if (videoData != null) {
      return _buildSharedVideoContent(theme, videoData);
    }
    
    // Regular video attachment
    final attachment = widget.message.mediaAttachment;
    if (attachment == null) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 200,
          height: 150,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (attachment.thumbnailUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: attachment.thumbnailUrl!,
                    width: 200,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
        if (widget.message.message != null && widget.message.message!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            widget.message.message!,
            style: TextStyle(
              color: widget.isMe ? Colors.white : theme.colorScheme.onSurface,
              fontSize: 14,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSharedVideoContent(ThemeData theme, Map<String, dynamic> videoData) {
    final title = videoData['title'] as String? ?? 'Shared Video';
    final thumbnailUrl = videoData['thumbnailUrl'] as String?;
    final creatorName = videoData['creatorName'] as String?;
    final skillId = videoData['skillId'] as String?;
    
    return GestureDetector(
      onTap: () {
        if (skillId != null) {
          // Navigate to the video in feed with proper back navigation
          // Pass the current chat information so we can return to the same chat
          final currentState = GoRouterState.of(context);
          final chatUserId = currentState.pathParameters['userId'];
          final chatName = currentState.uri.queryParameters['name'] ?? 'User';
          final chatAvatar = currentState.uri.queryParameters['avatar'] ?? '';
          context.push('/video/${skillId}?source=chat&fromChat=true&chatUserId=$chatUserId&chatName=${Uri.encodeComponent(chatName)}&chatAvatar=${Uri.encodeComponent(chatAvatar)}');
        }
      },
      child: Container(
        width: 250,
        decoration: BoxDecoration(
          color: widget.isMe 
              ? Colors.white.withOpacity(0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: widget.isMe 
                ? Colors.white.withOpacity(0.2)
                : theme.colorScheme.outline.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (thumbnailUrl != null)
                    CachedNetworkImage(
                      imageUrl: thumbnailUrl,
                      width: 250,
                      height: 140,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 250,
                        height: 140,
                        color: theme.colorScheme.surfaceVariant,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 250,
                        height: 140,
                        color: theme.colorScheme.errorContainer,
                        child: const Icon(Icons.video_file, size: 40),
                      ),
                    )
                  else
                    Container(
                      width: 250,
                      height: 140,
                      color: theme.colorScheme.surfaceVariant,
                      child: const Icon(Icons.video_file, size: 40),
                    ),
                  // Play button overlay
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
            // Video info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: widget.isMe ? Colors.white : theme.colorScheme.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (creatorName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'by $creatorName',
                      style: TextStyle(
                        color: widget.isMe 
                            ? Colors.white.withOpacity(0.7)
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.play_circle_outline,
                        size: 16,
                        color: widget.isMe 
                            ? Colors.white.withOpacity(0.7)
                            : theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Tap to watch',
                        style: TextStyle(
                          color: widget.isMe 
                              ? Colors.white.withOpacity(0.7)
                              : theme.colorScheme.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileContent(ThemeData theme) {
    final attachment = widget.message.mediaAttachment;
    if (attachment == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isMe 
            ? Colors.white.withOpacity(0.1)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getFileIcon(attachment.fileName),
            color: widget.isMe ? Colors.white : theme.colorScheme.primary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.fileName,
                  style: TextStyle(
                    color: widget.isMe ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _formatFileSize(attachment.fileSize),
                  style: TextStyle(
                    color: widget.isMe 
                        ? Colors.white.withOpacity(0.7)
                        : theme.colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioContent(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.isMe 
            ? Colors.white.withOpacity(0.1)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_circle_filled,
            color: widget.isMe ? Colors.white : theme.colorScheme.primary,
            size: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: widget.isMe 
                        ? Colors.white.withOpacity(0.3)
                        : theme.colorScheme.outline.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(1),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.3, // Progress
                    child: Container(
                      decoration: BoxDecoration(
                        color: widget.isMe ? Colors.white : theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '0:15', // Duration
                  style: TextStyle(
                    color: widget.isMe 
                        ? Colors.white.withOpacity(0.7)
                        : theme.colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPreview(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 30,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reply to message',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Original message content...',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactions(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      child: Wrap(
        spacing: 4,
        children: widget.message.reactions.map((reaction) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  reaction.reaction.value,
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 2),
                Text(
                  '1', // Count of this reaction
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QuickActionButton(
            icon: Icons.reply,
            onTap: widget.onReply,
          ),
          const SizedBox(width: 8),
          _QuickActionButton(
            icon: Icons.add_reaction_outlined,
            onTap: widget.onReact,
          ),
        ],
      ),
    );
  }

  Widget _buildTimestamp(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        timeago.format(widget.message.createdAt),
        style: TextStyle(
          fontSize: 11,
          color: theme.colorScheme.onSurface.withOpacity(0.4),
        ),
      ),
    );
  }

  IconData _getStatusIcon(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return Icons.access_time;
      case MessageStatus.sent:
        return Icons.check;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.read:
        return Icons.done_all;
      case MessageStatus.failed:
        return Icons.error_outline;
    }
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'zip':
      case 'rar':
        return Icons.archive;
      case 'mp3':
      case 'wav':
        return Icons.audio_file;
      case 'mp4':
      case 'avi':
        return Icons.video_file;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QuickActionButton({
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
    );
  }
}