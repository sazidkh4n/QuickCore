// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_conversation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatConversationModelImpl _$$ChatConversationModelImplFromJson(
  Map<String, dynamic> json,
) => _$ChatConversationModelImpl(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  otherUserId: json['other_user_id'] as String,
  otherUserName: json['other_user_name'] as String,
  otherUserAvatar: json['other_user_avatar'] as String?,
  lastMessage: json['last_message'] as String?,
  lastMessageTime: DateTime.parse(json['last_message_time'] as String),
  unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
  isOnline: json['is_online'] as bool? ?? false,
);

Map<String, dynamic> _$$ChatConversationModelImplToJson(
  _$ChatConversationModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'other_user_id': instance.otherUserId,
  'other_user_name': instance.otherUserName,
  'other_user_avatar': instance.otherUserAvatar,
  'last_message': instance.lastMessage,
  'last_message_time': instance.lastMessageTime.toIso8601String(),
  'unread_count': instance.unreadCount,
  'is_online': instance.isOnline,
};
