import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'enhanced_chat_message_model.freezed.dart';
part 'enhanced_chat_message_model.g.dart';

@JsonEnum(valueField: 'index')
enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed
}

@JsonEnum(valueField: 'value')
enum MessageType {
  text('text'),
  image('image'),
  video('video'),
  audio('audio'),
  file('file'),
  location('location'),
  contact('contact'),
  sticker('sticker'),
  gif('gif');

  const MessageType(this.value);
  final String value;
}

@JsonEnum(valueField: 'value')
enum ReactionType {
  like('👍'),
  love('❤️'),
  laugh('😂'),
  wow('😮'),
  sad('😢'),
  angry('😠'),
  fire('🔥'),
  clap('👏');

  const ReactionType(this.value);
  final String value;
}

@freezed
class MessageReaction with _$MessageReaction {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MessageReaction({
    required String userId,
    required String userName,
    String? userAvatar,
    required ReactionType reaction,
    required DateTime createdAt,
  }) = _MessageReaction;

  factory MessageReaction.fromJson(Map<String, dynamic> json) => _$MessageReactionFromJson(json);
}

@freezed
class MediaAttachment with _$MediaAttachment {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory MediaAttachment({
    required String url,
    required String fileName,
    required int fileSize,
    String? mimeType,
    String? thumbnailUrl,
    int? width,
    int? height,
    int? duration, // For video/audio files
  }) = _MediaAttachment;

  factory MediaAttachment.fromJson(Map<String, dynamic> json) => _$MediaAttachmentFromJson(json);
}

@freezed
class EnhancedChatMessageModel with _$EnhancedChatMessageModel {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory EnhancedChatMessageModel({
    required String id,
    required String senderId,
    required String receiverId,
    String? message,
    @Default(MessageType.text) MessageType messageType,
    MediaAttachment? mediaAttachment,
    String? replyToMessageId,
    @Default([]) List<MessageReaction> reactions,
    @Default(MessageStatus.sent) MessageStatus status,
    required DateTime createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? isEdited,
    bool? isForwarded,
    String? forwardedFromUserId,
    Map<String, dynamic>? metadata, // For extensibility
  }) = _EnhancedChatMessageModel;

  factory EnhancedChatMessageModel.fromJson(Map<String, dynamic> json) => _$EnhancedChatMessageModelFromJson(json);
}

@freezed
class TypingIndicator with _$TypingIndicator {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory TypingIndicator({
    required String userId,
    required String userName,
    String? userAvatar,
    required DateTime startedAt,
  }) = _TypingIndicator;

  factory TypingIndicator.fromJson(Map<String, dynamic> json) => _$TypingIndicatorFromJson(json);
}

@freezed
class ChatPresence with _$ChatPresence {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ChatPresence({
    required String userId,
    required bool isOnline,
    DateTime? lastSeen,
    String? status, // custom status message
  }) = _ChatPresence;

  factory ChatPresence.fromJson(Map<String, dynamic> json) => _$ChatPresenceFromJson(json);
}