import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quickcore/features/notifications/data/notification_model.dart';
import 'package:quickcore/features/notifications/data/chat_message_model.dart' as chat;
import 'package:quickcore/features/notifications/data/chat_conversation_model.dart';
import 'package:quickcore/features/notifications/data/enhanced_chat_message_model.dart';
import 'package:quickcore/features/auth/data/user_model.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

class NotificationsRepository {
  final SupabaseClient _client;

  NotificationsRepository(this._client);

  // Get notifications for the current user
  Future<List<NotificationModel>> getNotifications() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final response = await _client
          .from('notifications')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(50);

      return response.map<NotificationModel>((json) {
        // Ensure data is a Map<String, dynamic>
        final Map<String, dynamic> data = json['data'] is Map ? 
          Map<String, dynamic>.from(json['data'] as Map) : 
          <String, dynamic>{};
          
        return NotificationModel(
          id: json['id'],
          userId: json['user_id'],
          type: json['type'],
          data: data,
          isRead: json['is_read'] ?? false,
          createdAt: DateTime.parse(json['created_at']),
        );
      }).toList();
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  // Mark a notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId)
          .eq('user_id', user.id);
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  // Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', user.id)
          .eq('is_read', false);
    } catch (e) {
      print('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  // Get users that the current user follows
  Future<List<UserModel>> getFollowedUsers() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      final response = await _client
          .from('follows')
          .select('followed_id')
          .eq('follower_id', user.id);

      if (response.isEmpty) {
        return [];
      }

      final followedIds = response.map((item) => item['followed_id'] as String).toList();

      final usersResponse = await _client
          .from('profiles')
          .select()
          .filter('id', 'in', followedIds);

      return usersResponse.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching followed users: $e');
      return [];
    }
  }

  // Get conversations
  Future<List<ChatConversationModel>> getConversations() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      print('Fetching conversations for user: ${user.id}');
      
      // First, sync conversations with latest messages
      await _syncConversationsWithMessages();
      
      // First, let's check if there are any conversations at all
      final allConversations = await _client
          .from('conversations')
          .select('*');
      print('All conversations in database: $allConversations');
      
      // Fetch conversations where the current user is either user_id or other_user_id
      final response = await _client
          .from('conversations')
          .select('*')
          .or('user_id.eq.${user.id},other_user_id.eq.${user.id}')
          .order('last_message_time', ascending: false);

      print('Raw conversations response for user ${user.id}: $response');
      
      if (response == null || response.isEmpty) {
        print('No conversations found for user ${user.id}');
        
        // Let's also check if there are any messages for this user
        final messages = await _client
            .from('messages')
            .select('*')
            .or('sender_id.eq.${user.id},receiver_id.eq.${user.id}')
            .order('created_at', ascending: false);
        print('Messages for user ${user.id}: $messages');
        
        // Create conversations from existing messages if no conversations are found
        await _createConversationsFromMessages();
        
        return [];
      }

      final List<ChatConversationModel> conversations = [];
      final Set<String> processedIds = {};

      for (int i = 0; i < response.length; i++) {
        final json = response[i];
        print('Processing conversation ${i + 1}: $json');
        
        // Create a unique ID for this conversation
        final conversationId = '${json['user_id']}_${json['other_user_id']}';
        if (processedIds.contains(conversationId)) {
          print('Skipping duplicate conversation: $conversationId');
          continue;
        }
        
        processedIds.add(conversationId);
        print('Processing conversation ${i + 1}/${response.length}: $conversationId');
        
        // Determine which user is the "other" user (not the current user)
        String otherUserId;
        String otherUserName;
        String? otherUserAvatar;
        
        if (json['user_id'] == user.id) {
          // Current user is the user_id, so other_user_id is the other person
          otherUserId = json['other_user_id']?.toString() ?? '';
          otherUserName = json['other_user_name']?.toString() ?? 'Unknown User';
          otherUserAvatar = json['other_user_avatar'];
        } else {
          // Current user is the other_user_id, so user_id is the other person
          otherUserId = json['user_id']?.toString() ?? '';
          otherUserName = json['other_user_name']?.toString() ?? 'Unknown User';
          otherUserAvatar = json['other_user_avatar'];
        }
        
        // Try to fetch the actual user profile for the other user
        if (otherUserId.isNotEmpty && otherUserId != user.id) {
          try {
            final profileResponse = await _client
                .from('profiles')
                .select('username, avatar_url, display_name')
                .eq('id', otherUserId)
                .single();
            
            if (profileResponse != null) {
              // Prioritize display_name, then username
              final displayName = profileResponse['display_name']?.toString();
              final username = profileResponse['username']?.toString();
              
              if (displayName != null && displayName.isNotEmpty) {
                otherUserName = displayName;
              } else if (username != null && username.isNotEmpty) {
                otherUserName = username;
              }
              
              otherUserAvatar = profileResponse['avatar_url']?.toString() ?? otherUserAvatar;
              
              // Update the conversation with the correct name
              if (json['other_user_name'] != otherUserName) {
                try {
                  await _client
                      .from('conversations')
                      .update({'other_user_name': otherUserName})
                      .eq('id', json['id']);
                  print('Updated conversation ${json['id']} with correct name: $otherUserName');
                } catch (e) {
                  print('Could not update conversation name: $e');
                }
              }
            }
          } catch (e) {
            print('Could not fetch profile for user $otherUserId: $e');
            // Keep the fallback values
          }
        }
        
        // Ensure all required fields are present with fallbacks
        final normalizedJson = {
          'id': json['id']?.toString() ?? '',
          'user_id': user.id, // Always set current user as user_id
          'other_user_id': otherUserId,
          'other_user_name': otherUserName,
          'other_user_avatar': otherUserAvatar,
          'last_message': json['last_message'] ?? 'No messages yet',
          'last_message_time': json['last_message_time']?.toString() ?? DateTime.now().toIso8601String(),
          'unread_count': json['unread_count'] ?? 0,
          'is_online': json['is_online'] ?? false,
        };
        
        print('Normalized JSON: $normalizedJson');
        
        try {
          conversations.add(ChatConversationModel.fromJson(normalizedJson));
        } catch (e) {
          print('Error parsing conversation: $e');
          print('JSON that failed: $normalizedJson');
          rethrow;
        }
      }
      
      print('Returning ${conversations.length} conversations');
      return conversations;
    } catch (e) {
      print('Error fetching conversations: $e');
      return [];
    }
  }

  // Mark conversation as read
  Future<void> markConversationAsRead(String otherUserId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Update the conversation to mark messages as read
      await _client
          .from('conversations')
          .update({'unread_count': 0})
          .or('user_id.eq.${user.id},other_user_id.eq.${user.id}')
          .eq('other_user_id', otherUserId);
    } catch (e) {
      print('Error marking conversation as read: $e');
      rethrow;
    }
  }

  // Remove conversation
  Future<void> removeConversation(String otherUserId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Delete the conversation
      await _client
          .from('conversations')
          .delete()
          .or('user_id.eq.${user.id},other_user_id.eq.${user.id}')
          .eq('other_user_id', otherUserId);
    } catch (e) {
      print('Error removing conversation: $e');
      rethrow;
    }
  }

  // Get messages with a specific user
  Stream<List<Map<String, dynamic>>> getMessagesWithUser(String otherUserId) {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('sender_id', user.id)
        .order('created_at')
        .map((response) => response);
  }

  // Send a message
  Future<void> sendMessage(String receiverId, String message) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Insert the message
      await _client.from('messages').insert({
        'sender_id': user.id,
        'receiver_id': receiverId,
        'message': message,
        'created_at': DateTime.now().toIso8601String(),
      });

      // Update or create conversation
      await _updateConversation(receiverId, message);
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }

  // Update conversation
  Future<void> _updateConversation(String otherUserId, String lastMessage) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      print('Updating conversation between ${user.id} and $otherUserId');
      
      // Check if conversation exists for current user (where current user is user_id)
      final existingConversationAsUser = await _client
          .from('conversations')
          .select()
          .eq('user_id', user.id)
          .eq('other_user_id', otherUserId)
          .maybeSingle();

      // Check if conversation exists for current user (where current user is other_user_id)
      final existingConversationAsOther = await _client
          .from('conversations')
          .select()
          .eq('user_id', otherUserId)
          .eq('other_user_id', user.id)
          .maybeSingle();

      if (existingConversationAsUser != null) {
        print('Updating existing conversation where current user is user_id: ${existingConversationAsUser['id']}');
        // Update existing conversation
        await _client
            .from('conversations')
            .update({
              'last_message': lastMessage,
              'last_message_time': DateTime.now().toIso8601String(),
              'unread_count': 0, // Reset unread count when sending
            })
            .eq('id', existingConversationAsUser['id']);
      } else if (existingConversationAsOther != null) {
        print('Updating existing conversation where current user is other_user_id: ${existingConversationAsOther['id']}');
        // Update existing conversation
        await _client
            .from('conversations')
            .update({
              'last_message': lastMessage,
              'last_message_time': DateTime.now().toIso8601String(),
              'unread_count': 0, // Reset unread count when sending
            })
            .eq('id', existingConversationAsOther['id']);
      } else {
        print('Creating new conversation for current user');
        try {
          await _client.from('conversations').insert({
            'user_id': user.id,
            'other_user_id': otherUserId,
            'last_message': lastMessage,
            'last_message_time': DateTime.now().toIso8601String(),
            'unread_count': 0,
          });
        } catch (e) {
          print('Error creating conversation, trying upsert: $e');
          await _client.from('conversations').upsert({
            'user_id': user.id,
            'other_user_id': otherUserId,
            'last_message': lastMessage,
            'last_message_time': DateTime.now().toIso8601String(),
            'unread_count': 0,
          });
        }
      }

      // Also ensure the other user has a conversation entry
      final otherUserConversation = await _client
          .from('conversations')
          .select()
          .eq('user_id', otherUserId)
          .eq('other_user_id', user.id)
          .maybeSingle();

      if (otherUserConversation == null) {
        print('Creating conversation entry for other user');
        try {
          await _client.from('conversations').insert({
            'user_id': otherUserId,
            'other_user_id': user.id,
            'last_message': lastMessage,
            'last_message_time': DateTime.now().toIso8601String(),
            'unread_count': 1, // Increment unread count for other user
          });
        } catch (e) {
          print('Error creating conversation for other user, trying upsert: $e');
          await _client.from('conversations').upsert({
            'user_id': otherUserId,
            'other_user_id': user.id,
            'last_message': lastMessage,
            'last_message_time': DateTime.now().toIso8601String(),
            'unread_count': 1, // Increment unread count for other user
          });
        }
      }
    } catch (e) {
      print('Error updating conversation: $e');
    }
  }

  // Listen to new notifications (simplified version)
  Stream<NotificationModel> listenToNewNotifications() {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Return an empty stream for now to avoid compilation errors
    return Stream.empty();
  }

  // Listen to new messages (simplified version)
  Stream<chat.ChatMessageModel> listenToNewMessages() {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Return an empty stream for now to avoid compilation errors
    return Stream.empty();
  }

  // Public method to manually merge conversations
  Future<void> mergeConversations() async {
    await _mergeConversationsByUser();
  }

  // Force cleanup and merge all conversations
  Future<void> forceCleanupConversations() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      print('Force cleaning up all conversations for user: ${user.id}');
      
      // First, get all conversations for this user
      final conversations = await _client
          .from('conversations')
          .select('*')
          .or('user_id.eq.${user.id},other_user_id.eq.${user.id}');

      print('Found ${conversations.length} conversations before cleanup');

      // Group conversations by the other user ID
      final Map<String, List<Map<String, dynamic>>> userGroups = {};
      
      for (final conversation in conversations) {
        String otherUserId;
        if (conversation['user_id'] == user.id) {
          otherUserId = conversation['other_user_id'];
        } else {
          otherUserId = conversation['user_id'];
        }
        
        if (!userGroups.containsKey(otherUserId)) {
          userGroups[otherUserId] = [];
        }
        userGroups[otherUserId]!.add(conversation);
      }

      // For each user group, keep only the most recent conversation
      for (final entry in userGroups.entries) {
        final otherUserId = entry.key;
        final conversations = entry.value;
        
        if (conversations.length > 1) {
          print('Found ${conversations.length} conversations for user $otherUserId, keeping only the most recent');
          
          // Sort by last_message_time to find the most recent
          conversations.sort((a, b) {
            final timeA = DateTime.parse(a['last_message_time'] ?? DateTime.now().toIso8601String());
            final timeB = DateTime.parse(b['last_message_time'] ?? DateTime.now().toIso8601String());
            return timeB.compareTo(timeA);
          });
          
          // Keep the first (most recent) and delete the rest
          final toKeep = conversations.first;
          final toDelete = conversations.skip(1).toList();
          
          for (final conversation in toDelete) {
            print('Deleting duplicate conversation: ${conversation['id']}');
            await _client
                .from('conversations')
                .delete()
                .eq('id', conversation['id']);
          }
        }
      }

      // Now sync with latest messages
      await _syncConversationsWithMessages();
      
      print('Force cleanup completed');
    } catch (e) {
      print('Error during force cleanup: $e');
    }
  }

  // Get current user
  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  // Create conversations from existing messages
  Future<void> _createConversationsFromMessages() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      print('Creating conversations from existing messages for user: ${user.id}');
      
      // Get all messages for this user
      final messages = await _client
          .from('messages')
          .select('*')
          .or('sender_id.eq.${user.id},receiver_id.eq.${user.id}')
          .order('created_at', ascending: false);

      if (messages.isEmpty) {
        print('No messages found for user ${user.id}');
        return;
      }

      // Group messages by conversation partner
      final Map<String, List<Map<String, dynamic>>> conversations = {};
      
      for (final message in messages) {
        String otherUserId;
        if (message['sender_id'] == user.id) {
          otherUserId = message['receiver_id'];
        } else {
          otherUserId = message['sender_id'];
        }
        
        if (!conversations.containsKey(otherUserId)) {
          conversations[otherUserId] = [];
        }
        conversations[otherUserId]!.add(message);
      }

      // Create conversation records for each conversation partner
      for (final entry in conversations.entries) {
        final otherUserId = entry.key;
        final messages = entry.value;
        
        if (messages.isEmpty) continue;
        
        // Get the latest message
        final latestMessage = messages.first;
        final lastMessage = latestMessage['message'] ?? 'No message';
        final lastMessageTime = latestMessage['created_at'] ?? DateTime.now().toIso8601String();
        
        // Check if conversation already exists
        final existingConversation = await _client
            .from('conversations')
            .select()
            .eq('user_id', user.id)
            .eq('other_user_id', otherUserId)
            .maybeSingle();

        if (existingConversation == null) {
          print('Creating conversation from messages for user $otherUserId');
          await _client.from('conversations').insert({
            'user_id': user.id,
            'other_user_id': otherUserId,
            'last_message': lastMessage,
            'last_message_time': lastMessageTime,
            'unread_count': 0,
          });
        }
      }
      
      print('Finished creating conversations from messages');
    } catch (e) {
      print('Error creating conversations from messages: $e');
    }
  }

  // Sync conversations with latest messages
  Future<void> _syncConversationsWithMessages() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      print('Syncing conversations with latest messages for user: ${user.id}');
      
      // Get all messages for this user
      final messages = await _client
          .from('messages')
          .select('*')
          .or('sender_id.eq.${user.id},receiver_id.eq.${user.id}')
          .order('created_at', ascending: false);

      if (messages.isEmpty) {
        print('No messages found for user ${user.id}');
        return;
      }

      // Group messages by conversation partner
      final Map<String, List<Map<String, dynamic>>> conversations = {};
      
      for (final message in messages) {
        String otherUserId;
        if (message['sender_id'] == user.id) {
          otherUserId = message['receiver_id'];
        } else {
          otherUserId = message['sender_id'];
        }
        
        if (!conversations.containsKey(otherUserId)) {
          conversations[otherUserId] = [];
        }
        conversations[otherUserId]!.add(message);
      }

      // Update each conversation with the latest message
      for (final entry in conversations.entries) {
        final otherUserId = entry.key;
        final messages = entry.value;
        
        if (messages.isEmpty) continue;
        
        // Get the latest message
        final latestMessage = messages.first;
        final lastMessage = latestMessage['message'] ?? 'No message';
        final lastMessageTime = latestMessage['created_at'] ?? DateTime.now().toIso8601String();
        
        // Count unread messages for the other user
        int unreadCount = 0;
        for (final message in messages) {
          if (message['sender_id'] == otherUserId && message['read'] != true) {
            unreadCount++;
          }
        }
        
        // Update or create conversation for current user
        final existingConversation = await _client
            .from('conversations')
            .select()
            .eq('user_id', user.id)
            .eq('other_user_id', otherUserId)
            .maybeSingle();

        if (existingConversation != null) {
          print('Updating conversation with latest message for user $otherUserId');
          await _client
              .from('conversations')
              .update({
                'last_message': lastMessage,
                'last_message_time': lastMessageTime,
                'unread_count': 0, // Reset for current user
              })
              .eq('id', existingConversation['id']);
        } else {
          print('Creating conversation with latest message for user $otherUserId');
          try {
            await _client.from('conversations').insert({
              'user_id': user.id,
              'other_user_id': otherUserId,
              'last_message': lastMessage,
              'last_message_time': lastMessageTime,
              'unread_count': 0,
            });
          } catch (e) {
            print('Error creating conversation, trying upsert: $e');
            await _client.from('conversations').upsert({
              'user_id': user.id,
              'other_user_id': otherUserId,
              'last_message': lastMessage,
              'last_message_time': lastMessageTime,
              'unread_count': 0,
            });
          }
        }

        // Update or create conversation for other user
        final otherUserConversation = await _client
            .from('conversations')
            .select()
            .eq('user_id', otherUserId)
            .eq('other_user_id', user.id)
            .maybeSingle();

        if (otherUserConversation != null) {
          await _client
              .from('conversations')
              .update({
                'last_message': lastMessage,
                'last_message_time': lastMessageTime,
                'unread_count': unreadCount,
              })
              .eq('id', otherUserConversation['id']);
        } else {
          print('Creating conversation entry for other user');
          try {
            await _client.from('conversations').insert({
              'user_id': otherUserId,
              'other_user_id': user.id,
              'last_message': lastMessage,
              'last_message_time': lastMessageTime,
              'unread_count': unreadCount,
            });
          } catch (e) {
            print('Error creating conversation for other user, trying upsert: $e');
            await _client.from('conversations').upsert({
              'user_id': otherUserId,
              'other_user_id': user.id,
              'last_message': lastMessage,
              'last_message_time': lastMessageTime,
              'unread_count': unreadCount,
            });
          }
        }
      }
      
      // Clean up duplicate conversations
      await _cleanupDuplicateConversations();
      
      // Merge conversations for the same user
      await _mergeConversationsByUser();

      print('Finished syncing conversations with messages');
    } catch (e) {
      print('Error syncing conversations with messages: $e');
    }
  }

  // Clean up duplicate conversations
  Future<void> _cleanupDuplicateConversations() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      print('Cleaning up duplicate conversations for user: ${user.id}');
      
      // Get all conversations for this user
      final conversations = await _client
          .from('conversations')
          .select('*')
          .or('user_id.eq.${user.id},other_user_id.eq.${user.id}');

      final Map<String, List<Map<String, dynamic>>> conversationGroups = {};
      
      // Group conversations by the other user
      for (final conversation in conversations) {
        String otherUserId;
        if (conversation['user_id'] == user.id) {
          otherUserId = conversation['other_user_id'];
        } else {
          otherUserId = conversation['user_id'];
        }
        
        if (!conversationGroups.containsKey(otherUserId)) {
          conversationGroups[otherUserId] = [];
        }
        conversationGroups[otherUserId]!.add(conversation);
      }

      // For each group, keep only the most recent conversation
      for (final entry in conversationGroups.entries) {
        final otherUserId = entry.key;
        final conversations = entry.value;
        
        if (conversations.length > 1) {
          print('Found ${conversations.length} duplicate conversations for user $otherUserId');
          
          // Sort by last_message_time to find the most recent
          conversations.sort((a, b) {
            final timeA = DateTime.parse(a['last_message_time'] ?? DateTime.now().toIso8601String());
            final timeB = DateTime.parse(b['last_message_time'] ?? DateTime.now().toIso8601String());
            return timeB.compareTo(timeA);
          });
          
          // Keep the first (most recent) and delete the rest
          final toKeep = conversations.first;
          final toDelete = conversations.skip(1).toList();
          
          for (final conversation in toDelete) {
            print('Deleting duplicate conversation: ${conversation['id']}');
            await _client
                .from('conversations')
                .delete()
                .eq('id', conversation['id']);
          }
        }
      }
      
      print('Finished cleaning up duplicate conversations');
    } catch (e) {
      print('Error cleaning up duplicate conversations: $e');
    }
  }

  // Merge conversations for the same user (by email/name)
  Future<void> _mergeConversationsByUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      print('Merging conversations for the same user');
      
      // Get all conversations for this user
      final conversations = await _client
          .from('conversations')
          .select('*')
          .or('user_id.eq.${user.id},other_user_id.eq.${user.id}');

      // Group conversations by user profile (email/name)
      final Map<String, List<Map<String, dynamic>>> userGroups = {};
      
      for (final conversation in conversations) {
        String otherUserId;
        if (conversation['user_id'] == user.id) {
          otherUserId = conversation['other_user_id'];
        } else {
          otherUserId = conversation['user_id'];
        }
        
        // Try to get the user's profile to identify them by username
        try {
          final profile = await _client
              .from('profiles')
              .select('username')
              .eq('id', otherUserId)
              .single();
          
          final userIdentifier = profile['username']?.toString() ?? otherUserId;
          
          if (!userGroups.containsKey(userIdentifier)) {
            userGroups[userIdentifier] = [];
          }
          userGroups[userIdentifier]!.add(conversation);
        } catch (e) {
          // If we can't get profile, use the user ID
          if (!userGroups.containsKey(otherUserId)) {
            userGroups[otherUserId] = [];
          }
          userGroups[otherUserId]!.add(conversation);
        }
      }

      // For each group, merge conversations
      for (final entry in userGroups.entries) {
        final userIdentifier = entry.key;
        final conversations = entry.value;
        
        if (conversations.length > 1) {
          print('Found ${conversations.length} conversations for user $userIdentifier');
          
          // Sort by last_message_time to find the most recent
          conversations.sort((a, b) {
            final timeA = DateTime.parse(a['last_message_time'] ?? DateTime.now().toIso8601String());
            final timeB = DateTime.parse(b['last_message_time'] ?? DateTime.now().toIso8601String());
            return timeB.compareTo(timeA);
          });
          
          // Keep the first (most recent) and delete the rest
          final toKeep = conversations.first;
          final toDelete = conversations.skip(1).toList();
          
          for (final conversation in toDelete) {
            print('Deleting duplicate conversation for $userIdentifier: ${conversation['id']}');
            await _client
                .from('conversations')
                .delete()
                .eq('id', conversation['id']);
          }
        }
      }
      
      print('Finished merging conversations by user');
    } catch (e) {
      print('Error merging conversations by user: $e');
    }
  }
}

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  final client = Supabase.instance.client;
  return NotificationsRepository(client);
}); 