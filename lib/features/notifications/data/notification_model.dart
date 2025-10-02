import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

enum NotificationType {
  like,
  comment,
  follow,
  upload,
  mention,
  system
}

@freezed
class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required String id,
    required String userId,
    required String type,
    required Map<String, dynamic> data,
    required bool isRead,
    required DateTime createdAt,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) => 
      _$NotificationModelFromJson(json);
}

extension NotificationModelExtension on NotificationModel {
  String get title {
    if (type == 'new_comment' && data['action_type'] == 'like') {
      return 'New Like';
    }
    
    switch (type) {
      case 'new_comment':
        return 'New Comment';
      case 'new_follower':
        return 'New Follower';
      case 'reply':
        return 'New Reply';
      case 'trending_skill':
        return 'Trending Skill';
      case 'like':
        return 'New Like';
      case 'comment':
        return 'New Comment';
      case 'follow':
        return 'New Follower';
      case 'upload':
        return 'New Upload';
      case 'mention':
        return 'New Mention';
      default:
        return 'Notification';
    }
  }

  String get message {
    return data['message'] as String? ?? 'You have a new notification';
  }

  String? get skillId {
    return data['skill_id'] as String?;
  }

  String? get actionUserId {
    return data['action_user_id'] as String?;
  }

  String? get actionUserName {
    return data['action_user_name'] as String?;
  }

  String? get actionUserAvatar {
    return data['action_user_avatar'] as String?;
  }

  String? get imageUrl {
    return data['image_url'] as String?;
  }

  NotificationType get notificationType {
    // Handle the special case for likes
    if (type == 'new_comment' && data['action_type'] == 'like') {
      return NotificationType.like;
    }
    
    switch (type) {
      case 'new_comment':
        return NotificationType.comment;
      case 'new_follower':
        return NotificationType.follow;
      case 'like':
        return NotificationType.like;
      case 'comment':
        return NotificationType.comment;
      case 'follow':
        return NotificationType.follow;
      case 'upload':
        return NotificationType.upload;
      case 'mention':
        return NotificationType.mention;
      case 'reply':
        return NotificationType.comment;
      case 'trending_skill':
        return NotificationType.system;
      default:
        return NotificationType.system;
    }
  }
} 