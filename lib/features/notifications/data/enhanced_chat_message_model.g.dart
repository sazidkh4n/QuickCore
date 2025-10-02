// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enhanced_chat_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageReactionImpl _$$MessageReactionImplFromJson(
  Map<String, dynamic> json,
) => _$MessageReactionImpl(
  userId: json['user_id'] as String,
  userName: json['user_name'] as String,
  userAvatar: json['user_avatar'] as String?,
  reaction: $enumDecode(_$ReactionTypeEnumMap, json['reaction']),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$MessageReactionImplToJson(
  _$MessageReactionImpl instance,
) => <String, dynamic>{
  'user_id': instance.userId,
  'user_name': instance.userName,
  'user_avatar': instance.userAvatar,
  'reaction': _$ReactionTypeEnumMap[instance.reaction]!,
  'created_at': instance.createdAt.toIso8601String(),
};

const _$ReactionTypeEnumMap = {
  ReactionType.like: '👍',
  ReactionType.love: '❤️',
  ReactionType.laugh: '😂',
  ReactionType.wow: '😮',
  ReactionType.sad: '😢',
  ReactionType.angry: '😠',
  ReactionType.fire: '🔥',
  ReactionType.clap: '👏',
};

_$MediaAttachmentImpl _$$MediaAttachmentImplFromJson(
  Map<String, dynamic> json,
) => _$MediaAttachmentImpl(
  url: json['url'] as String,
  fileName: json['file_name'] as String,
  fileSize: (json['file_size'] as num).toInt(),
  mimeType: json['mime_type'] as String?,
  thumbnailUrl: json['thumbnail_url'] as String?,
  width: (json['width'] as num?)?.toInt(),
  height: (json['height'] as num?)?.toInt(),
  duration: (json['duration'] as num?)?.toInt(),
);

Map<String, dynamic> _$$MediaAttachmentImplToJson(
  _$MediaAttachmentImpl instance,
) => <String, dynamic>{
  'url': instance.url,
  'file_name': instance.fileName,
  'file_size': instance.fileSize,
  'mime_type': instance.mimeType,
  'thumbnail_url': instance.thumbnailUrl,
  'width': instance.width,
  'height': instance.height,
  'duration': instance.duration,
};

_$EnhancedChatMessageModelImpl _$$EnhancedChatMessageModelImplFromJson(
  Map<String, dynamic> json,
) => _$EnhancedChatMessageModelImpl(
  id: json['id'] as String,
  senderId: json['sender_id'] as String,
  receiverId: json['receiver_id'] as String,
  message: json['message'] as String?,
  messageType:
      $enumDecodeNullable(_$MessageTypeEnumMap, json['message_type']) ??
      MessageType.text,
  mediaAttachment: json['media_attachment'] == null
      ? null
      : MediaAttachment.fromJson(
          json['media_attachment'] as Map<String, dynamic>,
        ),
  replyToMessageId: json['reply_to_message_id'] as String?,
  reactions:
      (json['reactions'] as List<dynamic>?)
          ?.map((e) => MessageReaction.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  status:
      $enumDecodeNullable(_$MessageStatusEnumMap, json['status']) ??
      MessageStatus.sent,
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  deletedAt: json['deleted_at'] == null
      ? null
      : DateTime.parse(json['deleted_at'] as String),
  isEdited: json['is_edited'] as bool?,
  isForwarded: json['is_forwarded'] as bool?,
  forwardedFromUserId: json['forwarded_from_user_id'] as String?,
  metadata: json['metadata'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$$EnhancedChatMessageModelImplToJson(
  _$EnhancedChatMessageModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'sender_id': instance.senderId,
  'receiver_id': instance.receiverId,
  'message': instance.message,
  'message_type': _$MessageTypeEnumMap[instance.messageType]!,
  'media_attachment': instance.mediaAttachment,
  'reply_to_message_id': instance.replyToMessageId,
  'reactions': instance.reactions,
  'status': _$MessageStatusEnumMap[instance.status]!,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'deleted_at': instance.deletedAt?.toIso8601String(),
  'is_edited': instance.isEdited,
  'is_forwarded': instance.isForwarded,
  'forwarded_from_user_id': instance.forwardedFromUserId,
  'metadata': instance.metadata,
};

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.image: 'image',
  MessageType.video: 'video',
  MessageType.audio: 'audio',
  MessageType.file: 'file',
  MessageType.location: 'location',
  MessageType.contact: 'contact',
  MessageType.sticker: 'sticker',
  MessageType.gif: 'gif',
};

const _$MessageStatusEnumMap = {
  MessageStatus.sending: 0,
  MessageStatus.sent: 1,
  MessageStatus.delivered: 2,
  MessageStatus.read: 3,
  MessageStatus.failed: 4,
};

_$TypingIndicatorImpl _$$TypingIndicatorImplFromJson(
  Map<String, dynamic> json,
) => _$TypingIndicatorImpl(
  userId: json['user_id'] as String,
  userName: json['user_name'] as String,
  userAvatar: json['user_avatar'] as String?,
  startedAt: DateTime.parse(json['started_at'] as String),
);

Map<String, dynamic> _$$TypingIndicatorImplToJson(
  _$TypingIndicatorImpl instance,
) => <String, dynamic>{
  'user_id': instance.userId,
  'user_name': instance.userName,
  'user_avatar': instance.userAvatar,
  'started_at': instance.startedAt.toIso8601String(),
};

_$ChatPresenceImpl _$$ChatPresenceImplFromJson(Map<String, dynamic> json) =>
    _$ChatPresenceImpl(
      userId: json['user_id'] as String,
      isOnline: json['is_online'] as bool,
      lastSeen: json['last_seen'] == null
          ? null
          : DateTime.parse(json['last_seen'] as String),
      status: json['status'] as String?,
    );

Map<String, dynamic> _$$ChatPresenceImplToJson(_$ChatPresenceImpl instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'is_online': instance.isOnline,
      'last_seen': instance.lastSeen?.toIso8601String(),
      'status': instance.status,
    };
