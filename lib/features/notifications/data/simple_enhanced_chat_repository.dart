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
import 'dart:typed_data';

class SimpleEnhancedChatRepository {
  final SupabaseClient _client;
  final StorageService _storageService;
  final Uuid _uuid = const Uuid();

  // Stream controllers for real-time updates
  final StreamController<List<EnhancedChatMessageModel>> _messagesController = 
      StreamController<List<EnhancedChatMessageModel>>.broadcast();
  final StreamController<List<TypingIndicator>> _typingController = 
      StreamController<List<TypingIndicator>>.broadcast();
  final StreamController<Map<String, ChatPresence>> _presenceController = 
      StreamController<Map<String, ChatPresence>>.broadcast();

  // Cache for messages and presence
  final Map<String, List<EnhancedChatMessageModel>> _messagesCache = {};
  final Map<String, TypingIndicator> _typingIndicators = {};
  final Map<String, ChatPresence> _presenceCache = {};

  // Realtime subscriptions
  RealtimeChannel? _messagesChannel;

  SimpleEnhancedChatRepository({
    required SupabaseClient client,
    required StorageService storageService,
  }) : _client = client, _storageService = storageService;

  // MARK: - Streams

  Stream<List<EnhancedChatMessageModel>> get messagesStream => _messagesController.stream;
  Stream<List<TypingIndicator>> get typingIndicatorsStream => _typingController.stream;
  Stream<Map<String, ChatPresence>> get presenceStream => _presenceController.stream;

  // MARK: - Message Operations

  /// Get messages between current user and another user
  Stream<List<EnhancedChatMessageModel>> getMessagesWithUser(String otherUserId) {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Simplified stream - get all messages and filter in memory for now
    return _client
        .from('enhanced_messages')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: true)
        .map((data) => data
            .where((msg) => 
                (msg['sender_id'] == user.id && msg['receiver_id'] == otherUserId) ||
                (msg['sender_id'] == otherUserId && msg['receiver_id'] == user.id))
            .map((msg) => EnhancedChatMessageModel.fromJson(msg))
            .toList());
  }

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

    final messageData = {
      'id': messageId,
      'sender_id': user.id,
      'receiver_id': receiverId,
      'message': message,
      'message_type': MessageType.text.value,
      'reply_to_message_id': replyToMessageId,
      'status': MessageStatus.sent.index,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    await _client.from('enhanced_messages').insert(messageData);

    return EnhancedChatMessageModel(
      id: messageId,
      senderId: user.id,
      receiverId: receiverId,
      message: message,
      messageType: MessageType.text,
      replyToMessageId: replyToMessageId,
      status: MessageStatus.sent,
      createdAt: now,
      updatedAt: now,
    );
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
      final messageData = {
        'id': messageId,
        'sender_id': user.id,
        'receiver_id': receiverId,
        'message': caption,
        'message_type': MessageType.image.value,
        'media_attachment': mediaAttachment.toJson(),
        'reply_to_message_id': replyToMessageId,
        'status': MessageStatus.sent.index,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      };

      await _client.from('enhanced_messages').insert(messageData);

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
        updatedAt: now,
      );
    } catch (e) {
      print('Error sending image: $e');
      throw Exception('Failed to send image: $e');
    }
  }

  /// Add reaction to a message
  Future<void> addReaction(String messageId, String emoji) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Get current message
      final response = await _client
          .from('enhanced_messages')
          .select('reactions')
          .eq('id', messageId)
          .single();

      final currentReactions = response['reactions'] as List<dynamic>? ?? [];
      final reactions = currentReactions.map((r) => MessageReaction.fromJson(r)).toList();

      // Convert emoji to ReactionType
      final reactionType = _getReactionTypeFromEmoji(emoji);
      if (reactionType == null) return;

      // Remove existing reaction from this user for this emoji
      reactions.removeWhere((r) => r.userId == user.id && r.reaction == reactionType);

      // Add new reaction
      reactions.add(MessageReaction(
        userId: user.id,
        userName: 'User', // TODO: Get actual username
        reaction: reactionType,
        createdAt: DateTime.now(),
      ));

      // Update message
      await _client
          .from('enhanced_messages')
          .update({'reactions': reactions.map((r) => r.toJson()).toList()})
          .eq('id', messageId);
    } catch (e) {
      print('Error adding reaction: $e');
      throw Exception('Failed to add reaction: $e');
    }
  }

  /// Remove reaction from a message
  Future<void> removeReaction(String messageId, String emoji) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      // Get current message
      final response = await _client
          .from('enhanced_messages')
          .select('reactions')
          .eq('id', messageId)
          .single();

      final currentReactions = response['reactions'] as List<dynamic>? ?? [];
      final reactions = currentReactions.map((r) => MessageReaction.fromJson(r)).toList();

      // Convert emoji to ReactionType
      final reactionType = _getReactionTypeFromEmoji(emoji);
      if (reactionType == null) return;

      // Remove reaction from this user for this emoji
      reactions.removeWhere((r) => r.userId == user.id && r.reaction == reactionType);

      // Update message
      await _client
          .from('enhanced_messages')
          .update({'reactions': reactions.map((r) => r.toJson()).toList()})
          .eq('id', messageId);
    } catch (e) {
      print('Error removing reaction: $e');
      throw Exception('Failed to remove reaction: $e');
    }
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

    try {
      final response = await _client
          .from('enhanced_messages')
          .select()
          .or('sender_id.eq.${user.id},receiver_id.eq.${user.id}')
          .ilike('message', '%$query%')
          .order('created_at', ascending: false)
          .limit(limit);

      return response.map((msg) => EnhancedChatMessageModel.fromJson(msg)).toList();
    } catch (e) {
      print('Error searching messages: $e');
      return [];
    }
  }

  // MARK: - Typing Indicators (Simplified)

  /// Start typing indicator
  Future<void> startTyping(String receiverId) async {
    // Simplified - just emit empty list for now
    _typingController.add([]);
  }

  /// Stop typing indicator
  Future<void> stopTyping(String receiverId) async {
    // Simplified - just emit empty list for now
    _typingController.add([]);
  }

  // MARK: - Presence (Simplified)

  /// Update user presence
  Future<void> updatePresence(bool isOnline) async {
    // Simplified - just emit empty map for now
    _presenceController.add({});
  }

  /// Get user presence
  Future<ChatPresence?> getUserPresence(String userId) async {
    // Simplified - return null for now
    return null;
  }

  // MARK: - Helper Methods

  ReactionType? _getReactionTypeFromEmoji(String emoji) {
    switch (emoji) {
      case '👍':
        return ReactionType.like;
      case '❤️':
        return ReactionType.love;
      case '😂':
        return ReactionType.laugh;
      case '😮':
        return ReactionType.wow;
      case '😢':
        return ReactionType.sad;
      case '😠':
        return ReactionType.angry;
      case '🔥':
        return ReactionType.fire;
      case '👏':
        return ReactionType.clap;
      default:
        return null;
    }
  }

  // MARK: - Cleanup

  void dispose() {
    _messagesChannel?.unsubscribe();
    _messagesController.close();
    _typingController.close();
    _presenceController.close();
  }
}

// Simple data classes for typing and presence
class TypingIndicator {
  final String userId;
  final String userName;
  final DateTime timestamp;

  TypingIndicator({
    required this.userId,
    required this.userName,
    required this.timestamp,
  });

  factory TypingIndicator.fromJson(Map<String, dynamic> json) {
    return TypingIndicator(
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'user_name': userName,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class ChatPresence {
  final String userId;
  final bool isOnline;
  final DateTime lastSeen;

  ChatPresence({
    required this.userId,
    required this.isOnline,
    required this.lastSeen,
  });

  factory ChatPresence.fromJson(Map<String, dynamic> json) {
    return ChatPresence(
      userId: json['user_id'] as String,
      isOnline: json['is_online'] as bool,
      lastSeen: DateTime.parse(json['last_seen'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'is_online': isOnline,
      'last_seen': lastSeen.toIso8601String(),
    };
  }
}