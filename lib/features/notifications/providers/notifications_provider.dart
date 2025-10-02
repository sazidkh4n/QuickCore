import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickcore/features/notifications/data/notification_model.dart';
import 'package:quickcore/features/notifications/data/notifications_repository.dart';

class NotificationsNotifier extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final NotificationsRepository _repository;
  
  NotificationsNotifier(this._repository) : super(const AsyncValue.loading()) {
    getNotifications();
    _listenToNewNotifications();
  }

  Future<void> getNotifications() async {
    state = const AsyncValue.loading();
    try {
      final notifications = await _repository.getNotifications();
      state = AsyncValue.data(notifications);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _repository.markNotificationAsRead(notificationId);
      
      // Update the state to mark the notification as read
      if (state.hasValue) {
        final updatedNotifications = state.value!.map((notification) {
          if (notification.id == notificationId) {
            return notification.copyWith(isRead: true);
          }
          return notification;
        }).toList();
        
        state = AsyncValue.data(updatedNotifications);
      }
    } catch (e) {
      // Handle error silently or show a snackbar
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllNotificationsAsRead();
      
      // Update all notifications to be marked as read
      if (state.hasValue) {
        final updatedNotifications = state.value!.map((notification) {
          return notification.copyWith(isRead: true);
        }).toList();
        
        state = AsyncValue.data(updatedNotifications);
      }
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  void _listenToNewNotifications() {
    _repository.listenToNewNotifications().listen((newNotification) {
      if (state.hasValue) {
        // Add new notification to the top of the list
        final updatedNotifications = [newNotification, ...state.value!];
        state = AsyncValue.data(updatedNotifications);
      }
    });
  }

  int get unreadCount {
    if (!state.hasValue) return 0;
    return state.value!.where((notification) => !notification.isRead).length;
  }
}

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, AsyncValue<List<NotificationModel>>>((ref) {
  final repository = ref.watch(notificationsRepositoryProvider);
  return NotificationsNotifier(repository);
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notificationsState = ref.watch(notificationsProvider);
  if (!notificationsState.hasValue) return 0;
  return notificationsState.value!.where((notification) => !notification.isRead).length;
}); 