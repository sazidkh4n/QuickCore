import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickcore/features/notifications/data/enhanced_chat_message_model.dart';
import 'package:quickcore/features/notifications/providers/enhanced_chat_provider.dart';
import 'package:quickcore/features/notifications/presentation/widgets/enhanced_message_bubble.dart';
import 'package:quickcore/features/notifications/presentation/widgets/chat_input_widget.dart';
import 'package:quickcore/features/notifications/presentation/widgets/typing_indicator_widget.dart';
import 'package:quickcore/features/notifications/presentation/widgets/message_reactions_sheet.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:quickcore/features/auth/providers/auth_provider.dart';

class EnhancedChatScreen extends ConsumerStatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;

  const EnhancedChatScreen({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
  });

  @override
  ConsumerState<EnhancedChatScreen> createState() => _EnhancedChatScreenState();
}

class _EnhancedChatScreenState extends ConsumerState<EnhancedChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;
  
  bool _showScrollToBottom = false;
  EnhancedChatMessageModel? _replyToMessage;

  @override
  void initState() {
    super.initState();
    
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );

    _scrollController.addListener(_onScroll);
    _messageController.addListener(_onTextChanged);

    // Auto-scroll to bottom when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen(enhancedChatMessagesProvider(widget.otherUserId), (previous, next) {
        if (next.messages.isNotEmpty && 
            (previous == null || previous.messages.length != next.messages.length)) {
          _scrollToBottom();
        }
      });
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    _scrollController.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    final showButton = _scrollController.hasClients &&
        _scrollController.offset > 100;
    
    if (showButton != _showScrollToBottom) {
      setState(() {
        _showScrollToBottom = showButton;
      });
      
      if (showButton) {
        _fabAnimationController.forward();
      } else {
        _fabAnimationController.reverse();
      }
    }
  }

  void _onTextChanged() {
    final notifier = ref.read(enhancedChatMessagesProvider(widget.otherUserId).notifier);
    notifier.onTextChanged(_messageController.text);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _sendTextMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    final notifier = ref.read(enhancedChatMessagesProvider(widget.otherUserId).notifier);
    notifier.sendTextMessage(
      message,
      replyToMessageId: _replyToMessage?.id,
    );

    _messageController.clear();
    _clearReply();
    _scrollToBottom();
  }

  void _sendImageMessage(XFile imageFile, {String? caption}) {
    final notifier = ref.read(enhancedChatMessagesProvider(widget.otherUserId).notifier);
    notifier.sendImageMessage(
      imageFile,
      caption: caption,
      replyToMessageId: _replyToMessage?.id,
    );
    _clearReply();
    _scrollToBottom();
  }

  void _sendVideoMessage(XFile videoFile, {String? caption}) {
    final notifier = ref.read(enhancedChatMessagesProvider(widget.otherUserId).notifier);
    notifier.sendVideoMessage(
      videoFile,
      caption: caption,
      replyToMessageId: _replyToMessage?.id,
    );
    _clearReply();
    _scrollToBottom();
  }

  void _sendFileMessage(PlatformFile file, {String? caption}) {
    final notifier = ref.read(enhancedChatMessagesProvider(widget.otherUserId).notifier);
    notifier.sendFileMessage(
      file,
      caption: caption,
      replyToMessageId: _replyToMessage?.id,
    );
    _clearReply();
    _scrollToBottom();
  }

  void _setReplyToMessage(EnhancedChatMessageModel message) {
    setState(() {
      _replyToMessage = message;
    });
    _messageFocusNode.requestFocus();
  }

  void _clearReply() {
    setState(() {
      _replyToMessage = null;
    });
  }

  void _showReactionsSheet(EnhancedChatMessageModel message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => MessageReactionsSheet(
        message: message,
        onReactionTap: (reaction) {
          final notifier = ref.read(enhancedChatMessagesProvider(widget.otherUserId).notifier);
          notifier.addReaction(message.id, reaction);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showMediaPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _MediaPickerSheet(
        onImagePicked: _sendImageMessage,
        onVideoPicked: _sendVideoMessage,
        onFilePicked: _sendFileMessage,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(enhancedChatMessagesProvider(widget.otherUserId));
    final isUserOnline = ref.watch(isUserOnlineProvider(widget.otherUserId));
    final userLastSeen = ref.watch(userLastSeenProvider(widget.otherUserId));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: _buildAppBar(context, isUserOnline, userLastSeen),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: Stack(
              children: [
                // Chat background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        theme.colorScheme.surface,
                        theme.colorScheme.surface.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
                
                // Messages
                if (chatState.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (chatState.error != null)
                  _buildErrorWidget(chatState.error!)
                else if (chatState.messages.isEmpty)
                  _buildEmptyState()
                else
                  _buildMessagesList(chatState.messages),

                // Scroll to bottom FAB
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: ScaleTransition(
                    scale: _fabAnimation,
                    child: FloatingActionButton.small(
                      onPressed: _scrollToBottom,
                      backgroundColor: theme.colorScheme.primary,
                      child: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Typing indicators
          if (chatState.typingIndicators.isNotEmpty)
            TypingIndicatorWidget(indicators: chatState.typingIndicators),

          // Reply preview
          if (_replyToMessage != null)
            _buildReplyPreview(),

          // Message input
          ChatInputWidget(
            controller: _messageController,
            focusNode: _messageFocusNode,
            onSendMessage: _sendTextMessage,
            onAttachmentTap: _showMediaPicker,
            onVoiceMessageTap: () {
              // TODO: Implement voice message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Voice messages coming soon!')),
              );
            },
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isOnline, DateTime? lastSeen) {
    final theme = Theme.of(context);
    
    return AppBar(
      elevation: 0,
      backgroundColor: theme.colorScheme.surface.withOpacity(0.95),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => context.go('/notifications'),
      ),
      title: Row(
        children: [
          // User avatar with online indicator
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                child: widget.otherUserAvatar != null && widget.otherUserAvatar!.isNotEmpty
                    ? ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: widget.otherUserAvatar!,
                          fit: BoxFit.cover,
                          width: 40,
                          height: 40,
                          placeholder: (context, url) => Icon(
                            Icons.person, 
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.person, 
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                      )
                    : Icon(Icons.person, color: theme.colorScheme.primary),
              ),
              if (isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.otherUserName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  isOnline 
                      ? 'Online' 
                      : lastSeen != null 
                          ? 'Last seen ${timeago.format(lastSeen)}'
                          : 'Offline',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isOnline ? Colors.green : theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.videocam_outlined),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Video call coming soon!')),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.call_outlined),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Voice call coming soon!')),
            );
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'search':
                // TODO: Implement search
                break;
              case 'media':
                // TODO: Show media gallery
                break;
              case 'clear':
                // TODO: Clear chat
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'search',
              child: Row(
                children: [
                  Icon(Icons.search),
                  SizedBox(width: 12),
                  Text('Search'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'media',
              child: Row(
                children: [
                  Icon(Icons.photo_library),
                  SizedBox(width: 12),
                  Text('Media & Files'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'clear',
              child: Row(
                children: [
                  Icon(Icons.delete_outline),
                  SizedBox(width: 12),
                  Text('Clear Chat'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessagesList(List<EnhancedChatMessageModel> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final previousMessage = index > 0 ? messages[index - 1] : null;
        final nextMessage = index < messages.length - 1 ? messages[index + 1] : null;
        
        final isMe = message.senderId != widget.otherUserId;
        final showAvatar = _shouldShowAvatar(message, previousMessage, isMe);
        final showTimestamp = _shouldShowTimestamp(message, nextMessage);

        return EnhancedMessageBubble(
          message: message,
          isMe: isMe,
          showAvatar: showAvatar,
          showTimestamp: showTimestamp,
          otherUserAvatar: widget.otherUserAvatar,
          onReply: () => _setReplyToMessage(message),
          onReact: () => _showReactionsSheet(message),
          onLongPress: () => _showMessageOptions(message),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Send a message to start the conversation',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.refresh(enhancedChatMessagesProvider(widget.otherUserId));
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyPreview() {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${_replyToMessage!.senderId == widget.otherUserId ? widget.otherUserName : 'You'}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _replyToMessage!.message ?? _getMessageTypeText(_replyToMessage!.messageType),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _clearReply,
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  void _showMessageOptions(EnhancedChatMessageModel message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            ListTile(
              leading: const Icon(Icons.reply),
              title: const Text('Reply'),
              onTap: () {
                Navigator.pop(context);
                _setReplyToMessage(message);
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () {
                Navigator.pop(context);
                if (message.message != null) {
                  Clipboard.setData(ClipboardData(text: message.message!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Message copied')),
                  );
                }
              },
            ),
            
            if (message.senderId == ref.read(authProvider).value?.id)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement delete message
                },
              ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  bool _shouldShowAvatar(EnhancedChatMessageModel message, EnhancedChatMessageModel? previousMessage, bool isMe) {
    if (isMe) return false;
    if (previousMessage == null) return true;
    if (previousMessage.senderId != message.senderId) return true;
    
    final timeDiff = message.createdAt.difference(previousMessage.createdAt);
    return timeDiff.inMinutes > 5;
  }

  bool _shouldShowTimestamp(EnhancedChatMessageModel message, EnhancedChatMessageModel? nextMessage) {
    if (nextMessage == null) return true;
    if (nextMessage.senderId != message.senderId) return true;
    
    final timeDiff = nextMessage.createdAt.difference(message.createdAt);
    return timeDiff.inMinutes > 5;
  }

  String _getMessageTypeText(MessageType type) {
    switch (type) {
      case MessageType.image:
        return '📷 Photo';
      case MessageType.video:
        return '🎥 Video';
      case MessageType.audio:
        return '🎵 Audio';
      case MessageType.file:
        return '📎 File';
      case MessageType.location:
        return '📍 Location';
      case MessageType.contact:
        return '👤 Contact';
      case MessageType.sticker:
        return '😊 Sticker';
      case MessageType.gif:
        return '🎬 GIF';
      default:
        return 'Message';
    }
  }
}

class _MediaPickerSheet extends StatelessWidget {
  final Function(XFile) onImagePicked;
  final Function(XFile) onVideoPicked;
  final Function(PlatformFile) onFilePicked;

  const _MediaPickerSheet({
    required this.onImagePicked,
    required this.onVideoPicked,
    required this.onFilePicked,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _MediaOption(
                  icon: Icons.photo_camera,
                  label: 'Camera',
                  color: Colors.blue,
                  onTap: () async {
                    Navigator.pop(context);
                    final picker = ImagePicker();
                    final image = await picker.pickImage(source: ImageSource.camera);
                    if (image != null) {
                      onImagePicked(image);
                    }
                  },
                ),
                
                _MediaOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  color: Colors.green,
                  onTap: () async {
                    Navigator.pop(context);
                    final picker = ImagePicker();
                    final image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      onImagePicked(image);
                    }
                  },
                ),
                
                _MediaOption(
                  icon: Icons.videocam,
                  label: 'Video',
                  color: Colors.red,
                  onTap: () async {
                    Navigator.pop(context);
                    final picker = ImagePicker();
                    final video = await picker.pickVideo(source: ImageSource.gallery);
                    if (video != null) {
                      onVideoPicked(video);
                    }
                  },
                ),
                
                _MediaOption(
                  icon: Icons.attach_file,
                  label: 'File',
                  color: Colors.orange,
                  onTap: () async {
                    Navigator.pop(context);
                    final result = await FilePicker.platform.pickFiles();
                    if (result != null && result.files.isNotEmpty) {
                      onFilePicked(result.files.first);
                    }
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class _MediaOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MediaOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}