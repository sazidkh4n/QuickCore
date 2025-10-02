import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quickcore/features/notifications/data/chat_message_model.dart';
import 'package:quickcore/features/notifications/data/chat_conversation_model.dart';
import 'package:quickcore/features/notifications/data/notifications_repository.dart';
import 'package:quickcore/features/auth/data/user_model.dart';

class ConversationsNotifier extends StateNotifier<AsyncValue<List<ChatConversationModel>>> {
  final NotificationsRepository _repository;
  
  ConversationsNotifier(this._repository) : super(const AsyncValue.loading()) {
    getConversations();
    _listenToNewMessages();
  }

  Future<void> getConversations() async {
    state = const AsyncValue.loading();
    try {
      final conversations = await _repository.getConversations();
      state = AsyncValue.data(conversations);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refreshConversations() async {
    try {
      final conversations = await _repository.getConversations();
      state = AsyncValue.data(conversations);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> forceRefreshConversations() async {
    try {
      state = const AsyncValue.loading();
      // This will trigger the sync process
      final conversations = await _repository.getConversations();
      state = AsyncValue.data(conversations);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> mergeConversations() async {
    try {
      await _repository.mergeConversations();
      // Refresh after merging
      await getConversations();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> forceCleanup() async {
    try {
      state = const AsyncValue.loading();
      await _repository.forceCleanupConversations();
      // Refresh after cleanup
      await getConversations();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void _listenToNewMessages() {
    _repository.listenToNewMessages().listen((newMessage) {
      // Refresh conversations when a new message is received
      getConversations();
    });
  }

  int get unreadCount {
    if (!state.hasValue) return 0;
    return state.value!.fold(0, (sum, conversation) => sum + conversation.unreadCount);
  }

  Future<void> markConversationAsRead(String otherUserId) async {
    try {
      await _repository.markConversationAsRead(otherUserId);
      
      // Update the state to mark the conversation as read
      if (state.hasValue) {
        final updatedConversations = state.value!.map((conversation) {
          if (conversation.otherUserId == otherUserId) {
            return conversation.copyWith(unreadCount: 0);
          }
          return conversation;
        }).toList();
        
        state = AsyncValue.data(updatedConversations);
      }
    } catch (e) {
      print('Error marking conversation as read: $e');
    }
  }

  Future<void> removeConversation(String otherUserId) async {
    try {
      await _repository.removeConversation(otherUserId);
      
      // Remove the conversation from the state
      if (state.hasValue) {
        final updatedConversations = state.value!.where((conversation) {
          return conversation.otherUserId != otherUserId;
        }).toList();
        
        state = AsyncValue.data(updatedConversations);
      }
    } catch (e) {
      print('Error removing conversation: $e');
      // Even if removal fails, refresh to show current state
      await getConversations();
    }
  }
}

class ChatMessagesNotifier extends StateNotifier<AsyncValue<List<ChatMessageModel>>> {
  final NotificationsRepository _repository;
  final String otherUserId;
  StreamSubscription? _messageSubscription;
  
  ChatMessagesNotifier(this._repository, this.otherUserId) : super(const AsyncValue.loading()) {
    _loadInitialMessages();
    _listenToConversationMessages();
  }
  
  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialMessages() async {
    state = const AsyncValue.loading();
    try {
      // Initial load of messages
      final messages = await _repository.getMessagesWithUser(otherUserId).first;
      
      if (messages.isEmpty) {
        state = const AsyncValue.data([]);
        return;
      }
      
      final chatMessages = messages.map((msg) => ChatMessageModel.fromJson(msg)).toList();
      state = AsyncValue.data(chatMessages);
    } catch (e, st) {
      print('Error loading initial messages: $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> sendMessage(String message, {String? imageUrl}) async {
    if (message.trim().isEmpty) return;
    
    try {
      await _repository.sendMessage(otherUserId, message);
      
      // Add optimistic update for better UX
      if (state.hasValue) {
        final currentUser = _repository.getCurrentUser();
        if (currentUser != null) {
          final optimisticMessage = ChatMessageModel(
            id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
            senderId: currentUser.id,
            receiverId: otherUserId,
            message: message,
            status: MessageStatus.sending,
            createdAt: DateTime.now(),
          );
          
          state = AsyncValue.data([...state.value ?? [], optimisticMessage]);
        }
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  void _listenToConversationMessages() {
    _messageSubscription?.cancel();
    _messageSubscription = _repository.getMessagesWithUser(otherUserId).listen(
      (messages) {
        if (messages.isEmpty) return;
        
        final chatMessages = messages.map((msg) => ChatMessageModel.fromJson(msg)).toList();
        
        // Sort messages by timestamp
        chatMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        
        // Don't replace state if we're still loading
        if (state is AsyncLoading) return;
        
        // Prevent unnecessary rebuilds
        if (state.hasValue && state.value!.length == chatMessages.length &&
            state.value!.isNotEmpty && chatMessages.isNotEmpty &&
            state.value!.last.id == chatMessages.last.id) {
          return;
        }
        
        state = AsyncValue.data(chatMessages);
      },
      onError: (e) {
        print('Error in message stream: $e');
        // Don't update state on error to preserve existing messages
      },
    );
  }
}

class FollowedUsersNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  final NotificationsRepository _repository;
  
  FollowedUsersNotifier(this._repository) : super(const AsyncValue.loading()) {
    getFollowedUsers();
  }

  Future<void> getFollowedUsers() async {
    state = const AsyncValue.loading();
    try {
      final users = await _repository.getFollowedUsers();
      state = AsyncValue.data(users);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  return NotificationsRepository(Supabase.instance.client);
});

final conversationsProvider = StateNotifierProvider<ConversationsNotifier, AsyncValue<List<ChatConversationModel>>>((ref) {
  final repository = ref.watch(notificationsRepositoryProvider);
  return ConversationsNotifier(repository);
});

final followedUsersProvider = StateNotifierProvider<FollowedUsersNotifier, AsyncValue<List<UserModel>>>((ref) {
  final repository = ref.watch(notificationsRepositoryProvider);
  return FollowedUsersNotifier(repository);
});

final unreadConversationsCountProvider = Provider<int>((ref) {
  final conversationsState = ref.watch(conversationsProvider);
  if (!conversationsState.hasValue) return 0;
  return conversationsState.value!.fold(0, (sum, conversation) => sum + conversation.unreadCount);
});

final chatMessagesProvider = StateNotifierProviderFamily<ChatMessagesNotifier, AsyncValue<List<ChatMessageModel>>, String>((ref, otherUserId) {
  final repository = ref.watch(notificationsRepositoryProvider);
  return ChatMessagesNotifier(repository, otherUserId);
}); 