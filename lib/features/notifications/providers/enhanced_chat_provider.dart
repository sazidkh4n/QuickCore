import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quickcore/features/notifications/data/simple_enhanced_chat_repository.dart';
import 'package:quickcore/features/notifications/data/enhanced_chat_message_model.dart' hide TypingIndicator, ChatPresence;
import 'package:quickcore/features/notifications/data/chat_conversation_model.dart';
import 'package:quickcore/core/providers/storage_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

// MARK: - Repository Provider
final enhancedChatRepositoryProvider = Provider<SimpleEnhancedChatRepository>((ref) {
  final client = Supabase.instance.client;
  final storageService = ref.watch(storageServiceProvider);
  return SimpleEnhancedChatRepository(client: client, storageService: storageService);
});

// MARK: - Chat Messages State
class EnhancedChatMessagesState {
  final List<EnhancedChatMessageModel> messages;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final List<TypingIndicator> typingIndicators;

  const EnhancedChatMessagesState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.typingIndicators = const [],
  });

  EnhancedChatMessagesState copyWith({
    List<EnhancedChatMessageModel>? messages,
    bool? isLoading,
    String? error,
    bool? hasMore,
    List<TypingIndicator>? typingIndicators,
  }) {
    return EnhancedChatMessagesState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
      typingIndicators: typingIndicators ?? this.typingIndicators,
    );
  }
}

// MARK: - Enhanced Chat Messages Notifier
class EnhancedChatMessagesNotifier extends StateNotifier<EnhancedChatMessagesState> {
  final SimpleEnhancedChatRepository _repository;
  final String otherUserId;
  
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _typingSubscription;
  Timer? _typingTimer;
  bool _isTyping = false;

  EnhancedChatMessagesNotifier(this._repository, this.otherUserId) 
      : super(const EnhancedChatMessagesState(isLoading: true)) {
    _initializeChat();
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _typingSubscription?.cancel();
    _typingTimer?.cancel();
    if (_isTyping) {
      _repository.stopTyping(otherUserId);
    }
    super.dispose();
  }

  void _initializeChat() {
    _listenToMessages();
    _listenToTypingIndicators();
  }

  void _listenToMessages() {
    _messagesSubscription?.cancel();
    _messagesSubscription = _repository.getMessagesWithUser(otherUserId).listen(
      (messages) {
        state = state.copyWith(
          messages: messages,
          isLoading: false,
          error: null,
        );
      },
      onError: (error) {
        print('Error in messages stream: $error');
        state = state.copyWith(
          isLoading: false,
          error: error.toString(),
        );
      },
    );
  }

  void _listenToTypingIndicators() {
    _typingSubscription?.cancel();
    _typingSubscription = _repository.typingIndicatorsStream.listen(
      (indicators) {
        // Filter out current user's typing indicator
        final filteredIndicators = indicators
            .where((indicator) => indicator.userId != Supabase.instance.client.auth.currentUser?.id)
            .toList();
        
        state = state.copyWith(typingIndicators: filteredIndicators);
      },
    );
  }

  // MARK: - Message Sending

  Future<void> sendTextMessage(String message, {String? replyToMessageId}) async {
    if (message.trim().isEmpty) return;

    try {
      // Stop typing indicator
      if (_isTyping) {
        await stopTyping();
      }

      // Add optimistic message
      final optimisticMessage = EnhancedChatMessageModel(
        id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
        senderId: Supabase.instance.client.auth.currentUser!.id,
        receiverId: otherUserId,
        message: message,
        messageType: MessageType.text,
        replyToMessageId: replyToMessageId,
        status: MessageStatus.sending,
        createdAt: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, optimisticMessage],
      );

      // Send actual message
      await _repository.sendTextMessage(
        otherUserId,
        message,
        replyToMessageId: replyToMessageId,
      );
    } catch (e) {
      print('Error sending text message: $e');
      // Remove optimistic message and show error
      final updatedMessages = state.messages
          .where((msg) => !msg.id.startsWith('temp-'))
          .toList();
      
      state = state.copyWith(
        messages: updatedMessages,
        error: 'Failed to send message: $e',
      );
    }
  }

  Future<void> sendImageMessage(XFile imageFile, {String? caption, String? replyToMessageId}) async {
    try {
      // Stop typing indicator
      if (_isTyping) {
        await stopTyping();
      }

      // Add optimistic message
      final optimisticMessage = EnhancedChatMessageModel(
        id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
        senderId: Supabase.instance.client.auth.currentUser!.id,
        receiverId: otherUserId,
        message: caption,
        messageType: MessageType.image,
        replyToMessageId: replyToMessageId,
        status: MessageStatus.sending,
        createdAt: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, optimisticMessage],
      );

      // Send actual message
      await _repository.sendImageMessage(
        otherUserId,
        imageFile,
        caption: caption,
        replyToMessageId: replyToMessageId,
      );
    } catch (e) {
      print('Error sending image message: $e');
      // Remove optimistic message and show error
      final updatedMessages = state.messages
          .where((msg) => !msg.id.startsWith('temp-'))
          .toList();
      
      state = state.copyWith(
        messages: updatedMessages,
        error: 'Failed to send image: $e',
      );
    }
  }

  Future<void> sendVideoMessage(XFile videoFile, {String? caption, String? replyToMessageId}) async {
    try {
      // Stop typing indicator
      if (_isTyping) {
        await stopTyping();
      }

      // Add optimistic message
      final optimisticMessage = EnhancedChatMessageModel(
        id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
        senderId: Supabase.instance.client.auth.currentUser!.id,
        receiverId: otherUserId,
        message: caption,
        messageType: MessageType.video,
        replyToMessageId: replyToMessageId,
        status: MessageStatus.sending,
        createdAt: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, optimisticMessage],
      );

      // Send actual message
      // Video messages not implemented in simplified version
      throw Exception('Video messages not yet implemented');
    } catch (e) {
      print('Error sending video message: $e');
      // Remove optimistic message and show error
      final updatedMessages = state.messages
          .where((msg) => !msg.id.startsWith('temp-'))
          .toList();
      
      state = state.copyWith(
        messages: updatedMessages,
        error: 'Failed to send video: $e',
      );
    }
  }

  Future<void> sendFileMessage(PlatformFile file, {String? caption, String? replyToMessageId}) async {
    try {
      // Stop typing indicator
      if (_isTyping) {
        await stopTyping();
      }

      // Add optimistic message
      final optimisticMessage = EnhancedChatMessageModel(
        id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
        senderId: Supabase.instance.client.auth.currentUser!.id,
        receiverId: otherUserId,
        message: caption,
        messageType: MessageType.file,
        replyToMessageId: replyToMessageId,
        status: MessageStatus.sending,
        createdAt: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, optimisticMessage],
      );

      // Send actual message
      // File messages not implemented in simplified version
      throw Exception('File messages not yet implemented');
    } catch (e) {
      print('Error sending file message: $e');
      // Remove optimistic message and show error
      final updatedMessages = state.messages
          .where((msg) => !msg.id.startsWith('temp-'))
          .toList();
      
      state = state.copyWith(
        messages: updatedMessages,
        error: 'Failed to send file: $e',
      );
    }
  }

  // MARK: - Message Reactions

  Future<void> addReaction(String messageId, ReactionType reaction) async {
    try {
      await _repository.addReaction(messageId, reaction.value);
    } catch (e) {
      print('Error adding reaction: $e');
      state = state.copyWith(error: 'Failed to add reaction: $e');
    }
  }

  Future<void> removeReaction(String messageId, ReactionType reaction) async {
    try {
      await _repository.removeReaction(messageId, reaction.value);
    } catch (e) {
      print('Error removing reaction: $e');
      state = state.copyWith(error: 'Failed to remove reaction: $e');
    }
  }

  // MARK: - Typing Indicators

  Future<void> startTyping() async {
    if (_isTyping) return;
    
    _isTyping = true;
    await _repository.startTyping(otherUserId);
    
    // Auto-stop typing after 3 seconds of inactivity
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 3), () {
      stopTyping();
    });
  }

  Future<void> stopTyping() async {
    if (!_isTyping) return;
    
    _isTyping = false;
    _typingTimer?.cancel();
    await _repository.stopTyping(otherUserId);
  }

  void onTextChanged(String text) {
    if (text.trim().isNotEmpty && !_isTyping) {
      startTyping();
    } else if (text.trim().isEmpty && _isTyping) {
      stopTyping();
    } else if (_isTyping) {
      // Reset typing timer
      _typingTimer?.cancel();
      _typingTimer = Timer(const Duration(seconds: 3), () {
        stopTyping();
      });
    }
  }

  // MARK: - Utility Methods

  void clearError() {
    state = state.copyWith(error: null);
  }

  void retryFailedMessage(String tempMessageId) {
    final failedMessage = state.messages.firstWhere(
      (msg) => msg.id == tempMessageId,
      orElse: () => throw Exception('Message not found'),
    );

    switch (failedMessage.messageType) {
      case MessageType.text:
        sendTextMessage(
          failedMessage.message ?? '',
          replyToMessageId: failedMessage.replyToMessageId,
        );
        break;
      // Add other message types as needed
      default:
        break;
    }
  }
}

// MARK: - Presence State
class ChatPresenceState {
  final Map<String, ChatPresence> presenceMap;
  final bool isLoading;
  final String? error;

  const ChatPresenceState({
    this.presenceMap = const <String, ChatPresence>{},
    this.isLoading = false,
    this.error,
  });

  ChatPresenceState copyWith({
    Map<String, ChatPresence>? presenceMap,
    bool? isLoading,
    String? error,
  }) {
    return ChatPresenceState(
      presenceMap: presenceMap ?? this.presenceMap,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool isUserOnline(String userId) {
    return presenceMap[userId]?.isOnline ?? false;
  }

  DateTime? getUserLastSeen(String userId) {
    return presenceMap[userId]?.lastSeen;
  }

  String? getUserStatus(String userId) {
    return presenceMap[userId]?.isOnline == true ? 'online' : 'offline';
  }
}

// MARK: - Chat Presence Notifier
class ChatPresenceNotifier extends StateNotifier<ChatPresenceState> {
  final SimpleEnhancedChatRepository _repository;
  StreamSubscription? _presenceSubscription;

  ChatPresenceNotifier(this._repository) : super(const ChatPresenceState()) {
    _initializePresence();
  }

  @override
  void dispose() {
    _presenceSubscription?.cancel();
    super.dispose();
  }

  void _initializePresence() {
    _presenceSubscription = _repository.presenceStream.listen(
      (presenceMap) {
        state = state.copyWith(presenceMap: presenceMap);
      },
      onError: (error) {
        print('Error in presence stream: $error');
        state = state.copyWith(error: error.toString());
      },
    );

    // Update own presence
    _repository.updatePresence(true);
  }

  Future<void> updateStatus(String status) async {
    try {
      await _repository.updatePresence(true);
    } catch (e) {
      print('Error updating status: $e');
      state = state.copyWith(error: 'Failed to update status: $e');
    }
  }

  Future<void> goOffline() async {
    try {
      await _repository.updatePresence(false);
    } catch (e) {
      print('Error going offline: $e');
    }
  }
}

// MARK: - Providers

final enhancedChatMessagesProvider = StateNotifierProviderFamily<
    EnhancedChatMessagesNotifier, 
    EnhancedChatMessagesState, 
    String>((ref, otherUserId) {
  final repository = ref.watch(enhancedChatRepositoryProvider);
  return EnhancedChatMessagesNotifier(repository, otherUserId);
});

final chatPresenceProvider = StateNotifierProvider<ChatPresenceNotifier, ChatPresenceState>((ref) {
  final repository = ref.watch(enhancedChatRepositoryProvider);
  return ChatPresenceNotifier(repository);
});

// MARK: - Utility Providers

final isUserOnlineProvider = Provider.family<bool, String>((ref, userId) {
  final presenceState = ref.watch(chatPresenceProvider);
  return presenceState.isUserOnline(userId);
});

final userLastSeenProvider = Provider.family<DateTime?, String>((ref, userId) {
  final presenceState = ref.watch(chatPresenceProvider);
  return presenceState.getUserLastSeen(userId);
});

final userStatusProvider = Provider.family<String?, String>((ref, userId) {
  final presenceState = ref.watch(chatPresenceProvider);
  return presenceState.getUserStatus(userId);
});