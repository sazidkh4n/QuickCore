// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatMessageModelImpl _$$ChatMessageModelImplFromJson(
  Map<String, dynamic> json,
) => _$ChatMessageModelImpl(
  id: json['id'] as String,
  senderId: json['sender_id'] as String,
  receiverId: json['receiver_id'] as String,
  message: json['message'] as String,
  imageUrl: json['image_url'] as String?,
  status:
      $enumDecodeNullable(_$MessageStatusEnumMap, json['status']) ??
      MessageStatus.sent,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$$ChatMessageModelImplToJson(
  _$ChatMessageModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'sender_id': instance.senderId,
  'receiver_id': instance.receiverId,
  'message': instance.message,
  'image_url': instance.imageUrl,
  'status': _$MessageStatusEnumMap[instance.status]!,
  'created_at': instance.createdAt.toIso8601String(),
};

const _$MessageStatusEnumMap = {
  MessageStatus.sending: 0,
  MessageStatus.sent: 1,
  MessageStatus.delivered: 2,
  MessageStatus.read: 3,
};
