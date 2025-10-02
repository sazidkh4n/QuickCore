import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'chat_conversation_model.freezed.dart';
part 'chat_conversation_model.g.dart';

@freezed
class ChatConversationModel with _$ChatConversationModel {
  const factory ChatConversationModel({
    @JsonKey(name: 'id') required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'other_user_id') required String otherUserId,
    @JsonKey(name: 'other_user_name') required String otherUserName,
    @JsonKey(name: 'other_user_avatar') String? otherUserAvatar,
    @JsonKey(name: 'last_message') String? lastMessage,
    @JsonKey(name: 'last_message_time') required DateTime lastMessageTime,
    @JsonKey(name: 'unread_count') @Default(0) int unreadCount,
    @JsonKey(name: 'is_online') @Default(false) bool isOnline,
  }) = _ChatConversationModel;

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) => 
      _$ChatConversationModelFromJson(json);
} 