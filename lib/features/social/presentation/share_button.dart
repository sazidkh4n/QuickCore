import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickcore/features/notifications/data/chat_conversation_model.dart';
import 'package:quickcore/features/notifications/data/notifications_repository.dart';
import 'package:quickcore/features/notifications/data/enhanced_chat_message_model.dart';
import 'package:quickcore/features/feed/data/skill_model.dart';
import 'package:quickcore/features/auth/providers/auth_provider.dart';
import 'package:quickcore/features/auth/data/user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:quickcore/shared/widgets/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as dev;

class ShareButton extends ConsumerStatefulWidget {
  final String skillId;
  final SkillModel skill;
  final bool vertical;

  const ShareButton({
    super.key,
    required this.skillId,
    required this.skill,
    this.vertical = false,
  });

  @override
  ConsumerState<ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends ConsumerState<ShareButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showShareDialog,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(
                Icons.share,
                color: Colors.white,
                size: widget.vertical ? 28 : 24,
              ),
      ),
    );
  }

  void _showShareDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7, // Half screen
      ),
      builder: (context) => _ShareBottomSheet(
        skillId: widget.skillId,
        skill: widget.skill,
        onShare: _shareToUser,
      ),
    );
  }

  Future<void> _shareToUser(String userId, String userName) async {
    setState(() => _isLoading = true);

    try {
      final user = ref.read(authProvider).value;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Create a message with the shared video
      final message = EnhancedChatMessageModel(
        id: const Uuid().v4(), // Generate proper UUID
        senderId: user.id,
        receiverId: userId,
        message: 'Check out this video: ${widget.skill.title}',
        messageType: MessageType.video,
        metadata: {
          'videoData': {
            'skillId': widget.skillId,
            'title': widget.skill.title,
            'thumbnailUrl': widget.skill.thumbnailUrl,
            'videoUrl': widget.skill.videoUrl,
            'creatorName': widget.skill.creatorName,
          },
        },
        createdAt: DateTime.now(),
      );

      // Send the message
      final repository = NotificationsRepository(Supabase.instance.client);
      await repository.sendMessage(userId, 'Check out this video: ${widget.skill.title}');

      // Navigate to the chat
      if (mounted) {
        context.pop(); // Close the share dialog
        context.push('/chat/$userId?name=${Uri.encodeComponent(userName)}');
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Video shared with $userName!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      dev.log('Error sharing video: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share video: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _ShareBottomSheet extends ConsumerWidget {
  final String skillId;
  final SkillModel skill;
  final Function(String, String) onShare;

  const _ShareBottomSheet({
    required this.skillId,
    required this.skill,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followedUsersAsync = ref.watch(followedUsersProvider);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark 
            ? const Color(0xFF1E1E1E) 
            : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.grey.shade600 
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.share, 
                  size: 24,
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white 
                      : Colors.black,
                ),
                const SizedBox(width: 8),
                Text(
                  'Share to User',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // Video preview
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark 
                  ? Colors.grey.shade800 
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 60,
                    height: 40,
                    child: SafeNetworkImage(
                      imageUrl: skill.thumbnailUrl,
                      fit: BoxFit.cover,
                      errorWidget: Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.video_file, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Video info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        skill.title,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.white 
                              : Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (skill.creatorName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'by ${skill.creatorName}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark 
                                ? Colors.grey.shade400 
                                : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Users list
          Flexible(
            child: followedUsersAsync.when(
              data: (users) {
                dev.log('Followed users loaded: ${users.length}');
                if (users.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.people_outline, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No users to share with',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Follow some users to share videos with them',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    dev.log('Rendering user: ${user.username}');
                    return _UserTile(
                      user: user,
                      onTap: () => onShare(user.id, user.name ?? (user.username != null ? '@${user.username}' : 'User')),
                    );
                  },
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) {
                dev.log('Error loading followed users: $error');
                return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading users',
                        style: TextStyle(fontSize: 16, color: Colors.red.shade700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;

  const _UserTile({
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
            ? ClipOval(
                child: CachedNetworkImage(
                  imageUrl: user.avatarUrl!,
                  fit: BoxFit.cover,
                  width: 40,
                  height: 40,
                  placeholder: (context, url) => Icon(
                    Icons.person,
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Colors.black,
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.person,
                    color: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.white 
                        : Colors.black,
                  ),
                ),
              )
            : Icon(
                Icons.person,
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.white 
                    : Colors.black,
              ),
      ),
      title: Text(
        user.name ?? (user.username != null ? '@${user.username}' : 'User'),
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.white 
              : Colors.black,
        ),
      ),
      subtitle: Text(
        user.email ?? '',
        style: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.grey.shade400 
              : Colors.grey.shade600,
        ),
      ),
      onTap: onTap,
    );
  }
}

// Provider for followed users
final followedUsersProvider = FutureProvider<List<UserModel>>((ref) async {
  final client = Supabase.instance.client;
  final repository = NotificationsRepository(client);
  
  // Check if user is authenticated
  final user = client.auth.currentUser;
  if (user == null) {
    return [];
  }
  
  final users = await repository.getFollowedUsers();
  return users;
}); 