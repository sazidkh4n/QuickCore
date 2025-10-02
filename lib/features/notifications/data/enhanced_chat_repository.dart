import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quickcore/features/notifications/data/enhanced_chat_message_model.dart';
import 'package:quickcore/core/services/storage_service.dart';
import 'package:quickcore/features/notifications/data/chat_conversation_model.dart';
import 'package:quickcore/core/providers/storage_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';

class EnhancedChatRepository {
  final SupabaseClient _client;
  final StorageService _storageService;
  final _uuid = const Uuid();
  
  // Real-time subscriptions
  RealtimeChannel? _messagesChannel;
  RealtimeChannel? _typingChannel;
  RealtimeChannel? _presenceChannel;
  
  // Typing indicators cache
  final Map<String, TypingIndicator> _typingIndicators = {};
  final StreamController<List<TypingIndicator>> _typingController = StreamController.broadcast();
  
  // Presence cache
  final Map<String, ChatPresence> _presenceCache = {};
  final StreamController<Map<String, ChatPresence>> _presenceController = StreamController.broadcast();

  EnhancedChatRepository(this._client, this._storageService) {
    _initializeRealtimeSubscriptions();
  }

  void _initializeRealtimeSubscriptions() {
    final user = _client.auth.currentUser;
    if (user == null) return;

    // Subscribe to messages
    _messagesChannel = _client
        .channel('messages')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'enhanced_messages',
          callback: (payload) {
            print('New message received: ${payload.newRecord}');
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'enhanced_messages',
          callback: (payload) {
            print('Message updated: ${payload.newRecord}');
          },
        )
        .subscribe();

    // Subscribe to typing indicators
    _typingChannel = _client
        .channel('typing')
        .onPresenceSync((payload) {
          // Handle typing sync - simplified for current Supabase version
          _typingController.add([]);
        })
        .onPresenceJoin((payload) {
          // Handle typing join - simplified for current Supabase version
          _typingController.add([]);
        })
        .onPresenceLeave((payload) {
          // Handle typing leave - simplified for current Supabase version
          _typingController.add([]);
        })
        .subscribe();

    // Subscribe to user presence
    _presenceChannel = _client
        .channel('presence')
        .onPresenceSync((payload) {
          // Handle presence sync - simplified for current Supabase version
          _presenceController.add({});
        })
        .onPresenceJoin((payload) {
          // Handle presence join - simplified for current Supabase version
          _presenceController.add({});
        })
        .onPresenceLeave((payload) {
          // Handle presence leave - simplified for current Supabase version
          _presenceController.add({});
        })
        .subscribe();
  }

  // MARK: - Message Operations

  /// Send a text message
  Future<EnhancedChatMessageModel> sendTextMessage(
    String receiverId,
    String message, {
    String? replyToMessageId,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final messageId = _uuid.v4();
    final now = DateTime.now();

    final messageModel = EnhancedChatMessageModel(
      id: messageId,
      senderId: user.id,
      receiverId: receiverId,
      message: message,
      messageType: MessageType.text,
      replyToMessageId: replyToMessageId,
      status: MessageStatus.sending,
      createdAt: now,
    );

    try {
      // Insert message into database
      await _client.from('enhanced_messages').insert({
        'id': messageId,
        'sender_id': user.id,
        'receiver_id': receiverId,
        'message': message,
        'message_type': MessageType.text.value,
        'reply_to_message_id': replyToMessageId,
        'status': MessageStatus.sent.index,
        'created_at': now.toIso8601String(),
      });

      // Update conversation
      await _updateConversation(receiverId, message, MessageType.text);

      return messageModel.copyWith(status: MessageStatus.sent);
    } catch (e) {
      print('Error sending message: $e');
      return messageModel.copyWith(status: MessageStatus.failed);
    }
  }

  /// Send an image message
  Future<EnhancedChatMessageModel> sendImageMessage(
    String receiverId,
    XFile imageFile, {
    String? caption,
    String? replyToMessageId,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final messageId = _uuid.v4();
    final now = DateTime.now();

    try {
      // Upload image to storage
      final fileName = '${messageId}_${imageFile.name}';
      final imagePath = 'chat_media/images/$fileName';
      
      Uint8List imageBytes;
      if (kIsWeb) {
        imageBytes = await imageFile.readAsBytes();
      } else {
        imageBytes = await File(imageFile.path).readAsBytes();
      }

      final imageUrl = await _storageService.uploadFile(
        path: imagePath,
        data: imageBytes,
        contentType: 'image/${imageFile.name.split('.').last}',
      );

      // Create media attachment
      final mediaAttachment = MediaAttachment(
        url: imageUrl,
        fileName: imageFile.name,
        fileSize: imageBytes.length,
        mimeType: 'image/${imageFile.name.split('.').last}',
      );

      // Insert message into database
      await _client.from('enhanced_messages').insert({
        'id': messageId,
        'sender_id': user.id,
        'receiver_id': receiverId,
        'message': caption,
        'message_type': MessageType.image.value,
        'media_attachment': mediaAttachment.toJson(),
        'reply_to_message_id': replyToMessageId,
        'status': MessageStatus.sent.index,
        'created_at': now.toIso8601String(),
      });

      // Update conversation
      await _updateConversation(receiverId, '📷 Photo', MessageType.image);

      return EnhancedChatMessageModel(
        id: messageId,
        senderId: user.id,
        receiverId: receiverId,
        message: caption,
        messageType: MessageType.image,
        mediaAttachment: mediaAttachment,
        replyToMessageId: replyToMessageId,
        status: MessageStatus.sent,
        createdAt: now,
      );
    } catch (e) {
      print('Error sending image: $e');
      throw Exception('Failed to send image: $e');
    }
  }

  /// Send a video message
  Future<EnhancedChatMessageModel> sendVideoMessage(
    String receiverId,
    XFile videoFile, {
    String? caption,
    String? replyToMessageId,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final messageId = _uuid.v4();
    final now = DateTime.now();

    try {
      // Upload video to storage
      final fileName = '${messageId}_${videoFile.name}';
      final videoPath = 'chat_media/videos/$fileName';
      
      Uint8List videoBytes;
      if (kIsWeb) {
        videoBytes = await videoFile.readAsBytes();
      } else {
        videoBytes = await File(videoFile.path).readAsBytes();
      }

      final videoUrl = await _storageService.uploadFile(
        path: videoPath,
        data: videoBytes,
        contentType: 'video/${videoFile.name.split('.').last}',
      );

      // Create media attachment
      final mediaAttachment = MediaAttachment(
        url: videoUrl,
        fileName: videoFile.name,
        fileSize: videoBytes.length,
        mimeType: 'video/${videoFile.name.split('.').last}',
      );

      // Insert message into database
      await _client.from('enhanced_messages').insert({
        'id': messageId,
        'sender_id': user.id,
        'receiver_id': receiverId,
        'message': caption,
        'message_type': MessageType.video.value,
        'media_attachment': mediaAttachment.toJson(),
        'reply_to_message_id': replyToMessageId,
        'status': MessageStatus.sent.index,
        'created_at': now.toIso8601String(),
      });

      // Update conversation
      await _updateConversation(receiverId, '🎥 Video', MessageType.video);

      return EnhancedChatMessageModel(
        id: messageId,
        senderId: user.id,
        receiverId: receiverId,
        message: caption,
        messageType: MessageType.video,
        mediaAttachment: mediaAttachment,
        replyToMessageId: replyToMessageId,
        status: MessageStatus.sent,
        createdAt: now,
      );
    } catch (e) {
      print('Error sending video: $e');
      throw Exception('Failed to send video: $e');
    }
  }

  /// Send a file message
  Future<EnhancedChatMessageModel> sendFileMessage(
    String receiverId,
    PlatformFile file, {
    String? caption,
    String? replyToMessageId,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final messageId = _uuid.v4();
    final now = DateTime.now();

    try {
      // Upload file to storage
      final fileName = '${messageId}_${file.name}';
      final filePath = 'chat_media/files/$fileName';
      
      Uint8List fileBytes;
      if (file.bytes != null) {
        fileBytes = file.bytes!;
      } else if (file.path != null) {
        fileBytes = await File(file.path!).readAsBytes();
      } else {
        throw Exception('File data not available');
      }

      final fileUrl = await _storageService.uploadFile(
        path: filePath,
        data: fileBytes,
        contentType: _getMimeType(file.extension ?? ''),
      );

      // Create media attachment
      final mediaAttachment = MediaAttachment(
        url: fileUrl,
        fileName: file.name,
        fileSize: file.size,
        mimeType: _getMimeType(file.extension ?? ''),
      );

      // Insert message into database
      await _client.from('enhanced_messages').insert({
        'id': messageId,
        'sender_id': user.id,
        'receiver_id': receiverId,
        'message': caption,
        'message_type': MessageType.file.value,
        'media_attachment': mediaAttachment.toJson(),
        'reply_to_message_id': replyToMessageId,
        'status': MessageStatus.sent.index,
        'created_at': now.toIso8601String(),
      });

      // Update conversation
      await _updateConversation(receiverId, '📎 ${file.name}', MessageType.file);

      return EnhancedChatMessageModel(
        id: messageId,
        senderId: user.id,
        receiverId: receiverId,
        message: caption,
        messageType: MessageType.file,
        mediaAttachment: mediaAttachment,
        replyToMessageId: replyToMessageId,
        status: MessageStatus.sent,
        createdAt: now,
      );
    } catch (e) {
      print('Error sending file: $e');
      throw Exception('Failed to send file: $e');
    }
  }

  // MARK: - Message Reactions

  /// Add reaction to a message
  Future<void> addReaction(String messageId, ReactionType reaction) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Get current message
      final response = await _client
          .from('enhanced_messages')
          .select()
          .eq('id', messageId)
          .single();

      final message = EnhancedChatMessageModel.fromJson(response);
      
      // Check if user already reacted
      final existingReactions = message.reactions.where((r) => r.userId != user.id).toList();
      
      // Add new reaction
      final newReaction = MessageReaction(
        userId: user.id,
        userName: user.userMetadata?['full_name'] ?? 'User',
        userAvatar: user.userMetadata?['avatar_url'],
        reaction: reaction,
        createdAt: DateTime.now(),
      );
      
      existingReactions.add(newReaction);

      // Update message
      await _client
          .from('enhanced_messages')
          .update({
            'reactions': existingReactions.map((r) => r.toJson()).toList(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', messageId);
    } catch (e) {
      print('Error adding reaction: $e');
      throw Exception('Failed to add reaction: $e');
    }
  }

  /// Remove reaction from a message
  Future<void> removeReaction(String messageId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Get current message
      final response = await _client
          .from('enhanced_messages')
          .select()
          .eq('id', messageId)
          .single();

      final message = EnhancedChatMessageModel.fromJson(response);
      
      // Remove user's reaction
      final updatedReactions = message.reactions.where((r) => r.userId != user.id).toList();

      // Update message
      await _client
          .from('enhanced_messages')
          .update({
            'reactions': updatedReactions.map((r) => r.toJson()).toList(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', messageId);
    } catch (e) {
      print('Error removing reaction: $e');
      throw Exception('Failed to remove reaction: $e');
    }
  }

  // MARK: - Typing Indicators

  /// Start typing indicator
  Future<void> startTyping(String conversationId) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    await _typingChannel?.track({
      'user_id': user.id,
      'user_name': user.userMetadata?['full_name'] ?? 'User',
      'user_avatar': user.userMetadata?['avatar_url'],
      'conversation_id': conversationId,
      'started_at': DateTime.now().toIso8601String(),
    });
  }

  /// Stop typing indicator
  Future<void> stopTyping() async {
    await _typingChannel?.untrack();
  }

  /// Get typing indicators stream
  Stream<List<TypingIndicator>> getTypingIndicators() {
    return _typingController.stream;
  }

  // MARK: - Presence

  /// Update user presence
  Future<void> updatePresence({bool isOnline = true, String? status}) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    await _presenceChannel?.track({
      'user_id': user.id,
      'is_online': isOnline,
      'last_seen': DateTime.now().toIso8601String(),
      'status': status,
    });
  }

  /// Get presence stream
  Stream<Map<String, ChatPresence>> getPresenceStream() {
    return _presenceController.stream;
  }

  // MARK: - Message Queries

  /// Get messages for a conversation with real-time updates
  Stream<List<EnhancedChatMessageModel>> getMessagesStream(String otherUserId) {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    return _client
        .from('enhanced_messages')
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((data) {
          return data
              .where((msg) {
                final senderId = msg['sender_id'] as String;
                final receiverId = msg['receiver_id'] as String;
                return (senderId == user.id && receiverId == otherUserId) ||
                       (senderId == otherUserId && receiverId == user.id);
              })
              .map((msg) => EnhancedChatMessageModel.fromJson(msg))
              .toList();
        });
  }

  /// Search messages
  Future<List<EnhancedChatMessageModel>> searchMessages(
    String query, {
    String? otherUserId,
    MessageType? messageType,
    int limit = 50,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Simplified query for current Supabase version
    final response = await _client
        .from('enhanced_messages')
        .select()
        .or('sender_id.eq.${user.id},receiver_id.eq.${user.id}')
        .ilike('message', '%$query%')
        .order('created_at', ascending: false)
        .limit(limit);
    return response.map((msg) => EnhancedChatMessageModel.fromJson(msg)).toList();
  }

  // MARK: - Helper Methods

  Future<void> _updateConversation(String otherUserId, String lastMessage, MessageType messageType) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      // Check if conversation exists
      final existingConversations = await _client
          .from('conversations')
          .select()
          .or('and(user_id.eq.${user.id},other_user_id.eq.$otherUserId),'
              'and(user_id.eq.$otherUserId,other_user_id.eq.${user.id})');

      if (existingConversations.isNotEmpty) {
        // Update existing conversations
        for (final conv in existingConversations) {
          final isMyConversation = conv['user_id'] == user.id;
          await _client
              .from('conversations')
              .update({
                'last_message': lastMessage,
                'last_message_time': DateTime.now().toIso8601String(),
                'unread_count': isMyConversation ? 0 : (conv['unread_count'] ?? 0) + 1,
              })
              .eq('id', conv['id']);
        }
      } else {
        // Create new conversations
        final timestamp = DateTime.now().toIso8601String();
        
        await _client.from('conversations').insert([
          {
            'user_id': user.id,
            'other_user_id': otherUserId,
            'other_user_name': 'User',
            'last_message': lastMessage,
            'last_message_time': timestamp,
            'unread_count': 0,
          },
          {
            'user_id': otherUserId,
            'other_user_id': user.id,
            'other_user_name': user.userMetadata?['full_name'] ?? 'User',
            'last_message': lastMessage,
            'last_message_time': timestamp,
            'unread_count': 1,
          },
        ]);
      }
    } catch (e) {
      print('Error updating conversation: $e');
    }
  }

  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
      case 'docx':
        return 'application/msword';
      case 'xls':
      case 'xlsx':
        return 'application/vnd.ms-excel';
      case 'ppt':
      case 'pptx':
        return 'application/vnd.ms-powerpoint';
      case 'txt':
        return 'text/plain';
      case 'zip':
        return 'application/zip';
      case 'rar':
        return 'application/x-rar-compressed';
      default:
        return 'application/octet-stream';
    }
  }

  // MARK: - Real-time Event Handlers

  // Simplified handlers for current Supabase version
  // Real-time features will be implemented in a future update

  // MARK: - Cleanup

  void dispose() {
    _messagesChannel?.unsubscribe();
    _typingChannel?.unsubscribe();
    _presenceChannel?.unsubscribe();
    _typingController.close();
    _presenceController.close();
  }
}