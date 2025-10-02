import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickcore/features/notifications/data/notification_model.dart';
import 'package:quickcore/features/notifications/data/chat_conversation_model.dart';
import 'package:quickcore/features/notifications/providers/notifications_provider.dart';
import 'package:quickcore/features/notifications/providers/chat_provider.dart';
import 'package:quickcore/features/auth/data/user_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:ui';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Refresh data when screen is opened
    Future.microtask(() {
      ref.read(notificationsProvider.notifier).getNotifications();
      ref.read(conversationsProvider.notifier).getConversations();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unreadNotificationsCount = ref.watch(unreadNotificationsCountProvider);
    final unreadChatsCount = ref.watch(unreadConversationsCountProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = colorScheme.secondary;
    
    return Scaffold(
      extendBody: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: AppBar(
              title: Text(
                'Notifications',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                  color: accent,
                  fontSize: 24,
                ),
              ),
              elevation: 0,
              backgroundColor: colorScheme.surface.withValues(alpha: 0.9),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.done_all,
                      color: accent,
                      size: 20,
                    ),
                  ),
                  onPressed: () {
                    ref.read(notificationsProvider.notifier).markAllAsRead();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('All notifications marked as read'),
                        backgroundColor: accent,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  tooltip: 'Mark all as read',
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(56),
                child: Container(
                  color: Colors.transparent,
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        colors: [accent, accent.withValues(alpha: 0.7)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: accent.withValues(alpha: 0.6),
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                      fontSize: 16,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      fontSize: 16,
                    ),
                    tabs: [
                      _buildTabWithBadge('Chats', unreadChatsCount, accent),
                      _buildTabWithBadge('Notifications', unreadNotificationsCount, accent),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Luxury gradient background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.surface,
                    accent.withValues(alpha: 0.05),
                    colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Animated floating elements
          Positioned(
            top: 100,
            right: 20,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [accent.withValues(alpha: 0.1), accent.withValues(alpha: 0.05)],
                ),
              ),
            ),
          ),
          TabBarView(
            controller: _tabController,
            children: const [
              ChatListTab(),
              NotificationsListTab(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabWithBadge(String text, int count, Color accent) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Tab(text: text),
        if (count > 0)
          Positioned(
            right: -8,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.redAccent, accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withValues(alpha: 0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

class ChatListTab extends ConsumerWidget {
  const ChatListTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversationsAsync = ref.watch(conversationsProvider);
    final followedUsersAsync = ref.watch(followedUsersProvider);
    
    return Column(
      children: [
        // Followed users section
        _buildFollowedUsersSection(context, ref, followedUsersAsync),
        
        // Recent conversations section
        Expanded(
          child: conversationsAsync.when(
            data: (conversations) {
              if (conversations.isEmpty) {
                return _buildEmptyChatState(context, ref);
              }
              
              return RefreshIndicator(
                onRefresh: () => ref.read(conversationsProvider.notifier).getConversations(),
                child: ListView.builder(
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    return ConversationTile(conversation: conversations[index]);
                  },
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stackTrace) => _buildErrorState(context, ref),
          ),
        ),
      ],
    );
  }

  Widget _buildFollowedUsersSection(BuildContext context, WidgetRef ref, AsyncValue<List<UserModel>> followedUsersAsync) {
    return Container(
      height: 140,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(
                  Icons.people,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'People You Follow',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: followedUsersAsync.when(
              data: (users) {
                if (users.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 48,
                          color: Colors.grey.withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Follow users to see them here',
                          style: TextStyle(
                            color: Colors.grey.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return _buildFollowedUserBubble(context, user);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text('Could not load users: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowedUserBubble(BuildContext context, UserModel user) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.secondary;
    
    return GestureDetector(
      onTap: () {
        context.push('/chat/${user.id}?name=${Uri.encodeComponent(user.name ?? user.username ?? 'User')}&avatar=${user.avatarUrl ?? ''}');
      },
      child: Container(
        width: 85,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [accent.withValues(alpha: 0.1), accent.withValues(alpha: 0.05)],
                ),
                border: Border.all(
                  color: accent.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipOval(
                child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: user.avatarUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Icon(
                          Icons.person,
                          color: accent,
                          size: 35,
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.person,
                          color: accent,
                          size: 35,
                        ),
                      )
                    : Icon(Icons.person, color: accent, size: 35),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user.name ?? user.username ?? 'User',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChatState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: 40,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start chatting with learners and tutors!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(conversationsProvider.notifier).forceCleanup();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Force Cleanup & Sync'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Error loading conversations',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ref.read(conversationsProvider.notifier).getConversations(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

class ConversationTile extends ConsumerWidget {
  final ChatConversationModel conversation;
  
  const ConversationTile({
    super.key,
    required this.conversation,
  });
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = colorScheme.secondary;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () async {
          try {
            // Navigate to chat screen
            final chatRoute = '/chat/${conversation.otherUserId}?name=${Uri.encodeComponent(conversation.otherUserName)}&avatar=${conversation.otherUserAvatar ?? ''}';
            
            if (context.mounted) {
              context.push(chatRoute);
            }
            
            // Mark conversation as read
            await ref.read(conversationsProvider.notifier).markConversationAsRead(conversation.otherUserId);
            
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error opening chat: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    leading: _buildAvatarWithStatus(theme, accent),
                    title: Text(
                      conversation.otherUserName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.lastMessage ?? 'New conversation',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: 'Inter',
                              color: conversation.unreadCount > 0 
                                  ? theme.textTheme.bodyMedium?.color
                                  : theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                            ),
                          ),
                        ),
                        if (conversation.unreadCount > 0)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.mark_chat_unread,
                              color: accent,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          timeago.format(conversation.lastMessageTime, locale: 'en_short'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'Inter',
                            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                          ),
                        ),
                        if (conversation.unreadCount > 0)
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [accent, accent.withValues(alpha: 0.7)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Text(
                              conversation.unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarWithStatus(ThemeData theme, Color accent) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: conversation.isOnline 
                    ? Colors.greenAccent.withValues(alpha: 0.4)
                    : accent.withValues(alpha: 0.15),
                blurRadius: conversation.isOnline ? 16 : 8,
                spreadRadius: conversation.isOnline ? 2 : 0,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 30,
            backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
            child: conversation.otherUserAvatar != null && conversation.otherUserAvatar!.isNotEmpty
                ? ClipOval(
                    child: CachedNetworkImage(
                      imageUrl: conversation.otherUserAvatar!,
                      fit: BoxFit.cover,
                      width: 60,
                      height: 60,
                      placeholder: (context, url) => Icon(
                        Icons.person,
                        color: theme.primaryColor,
                        size: 30,
                      ),
                      errorWidget: (context, url, error) => Icon(
                        Icons.person,
                        color: theme.primaryColor,
                        size: 30,
                      ),
                    ),
                  )
                : Icon(Icons.person, color: theme.primaryColor, size: 30),
          ),
        ),
        if (conversation.isOnline)
          Positioned(
            right: 2,
            bottom: 2,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.greenAccent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.greenAccent.withValues(alpha: 0.6),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
                border: Border.all(
                  color: theme.colorScheme.surface,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class NotificationsListTab extends ConsumerWidget {
  const NotificationsListTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    
    return notificationsAsync.when(
      data: (notifications) {
        if (notifications.isEmpty) {
          return _buildEmptyNotificationsState(context);
        }
        
        return RefreshIndicator(
          onRefresh: () => ref.read(notificationsProvider.notifier).getNotifications(),
          child: ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              return NotificationTile(notification: notifications[index]);
            },
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => _buildErrorState(context, ref),
    );
  }

  Widget _buildEmptyNotificationsState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No notifications yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'When someone interacts with your content,\nyou\'ll see it here',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
              fontFamily: 'Inter',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red.withValues(alpha: 0.1),
            ),
            child: const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Error loading notifications',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ref.read(notificationsProvider.notifier).getNotifications(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

class NotificationTile extends ConsumerWidget {
  final NotificationModel notification;

  const NotificationTile({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = colorScheme.secondary;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () {
          _handleNotificationTap(context, notification, ref);
        },
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    tileColor: notification.isRead ? null : accent.withValues(alpha: 0.05),
                    leading: _buildLeadingAvatar(theme, accent),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: notification.isRead
                              ? Icon(
                                  Icons.check_circle,
                                  color: Colors.greenAccent,
                                  size: 20,
                                  key: const ValueKey('read'),
                                )
                              : Icon(
                                  Icons.circle,
                                  color: accent,
                                  size: 14,
                                  key: const ValueKey('unread'),
                                ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.message,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timeago.format(notification.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'Inter',
                            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildLeadingAvatar(ThemeData theme, Color accent) {
    // If we have a user avatar, use it
    if (notification.actionUserAvatar != null && notification.actionUserAvatar!.isNotEmpty) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.15),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 28,
          backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: notification.actionUserAvatar!,
              fit: BoxFit.cover,
              width: 56,
              height: 56,
              placeholder: (context, url) => Icon(
                Icons.person,
                color: theme.primaryColor,
                size: 28,
              ),
              errorWidget: (context, url, error) => Icon(
                Icons.person,
                color: theme.primaryColor,
                size: 28,
              ),
            ),
          ),
        ),
      );
    }
    
    // Otherwise, use an icon based on notification type
    IconData iconData;
    Color iconColor;
    
    switch (notification.notificationType) {
      case NotificationType.like:
        iconData = Icons.favorite;
        iconColor = Colors.red;
        break;
      case NotificationType.comment:
        iconData = Icons.comment;
        iconColor = Colors.blue;
        break;
      case NotificationType.follow:
        iconData = Icons.person_add;
        iconColor = Colors.green;
        break;
      case NotificationType.upload:
        iconData = Icons.video_library;
        iconColor = Colors.purple;
        break;
      case NotificationType.mention:
        iconData = Icons.alternate_email;
        iconColor = Colors.orange;
        break;
      case NotificationType.system:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
        break;
    }
    
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: iconColor.withValues(alpha: 0.2),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 28,
        backgroundColor: Colors.transparent,
        child: Icon(iconData, color: iconColor, size: 24),
      ),
    );
  }
  
  void _handleNotificationTap(BuildContext context, NotificationModel notification, WidgetRef ref) {
    // Mark as read first
    if (!notification.isRead) {
      ref.read(notificationsProvider.notifier).markAsRead(notification.id);
    }
    
    // Navigate based on notification type
    switch (notification.notificationType) {
      case NotificationType.like:
        if (notification.skillId != null) {
          // Navigate to the skill/video without opening comments
          context.push('/video/${notification.skillId}?source=feed');
        }
        break;
      case NotificationType.comment:
        if (notification.skillId != null) {
          // Navigate to the skill/video with comment section open
          context.push('/video/${notification.skillId}?source=feed&openComments=true&notificationType=comment');
        }
        break;
      case NotificationType.follow:
        if (notification.actionUserId != null) {
          // Navigate to user profile
          context.push('/profile/${notification.actionUserId}');
        }
        break;
      case NotificationType.upload:
        if (notification.skillId != null) {
          // Navigate to the new skill/video without opening comments
          context.push('/video/${notification.skillId}?source=feed');
        }
        break;
      case NotificationType.mention:
        if (notification.skillId != null) {
          // Navigate to the comment where mentioned
          context.push('/video/${notification.skillId}?source=feed&openComments=true&notificationType=mention');
        }
        break;
      case NotificationType.system:
        // System notifications might not have navigation
        break;
    }
  }
} 