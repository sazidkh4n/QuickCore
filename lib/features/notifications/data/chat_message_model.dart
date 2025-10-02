import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'chat_message_model.freezed.dart';
part 'chat_message_model.g.dart';

@JsonEnum(valueField: 'index')
enum MessageStatus {
  sending,
  sent,
  delivered,
  read
}

@freezed
class ChatMessageModel with _$ChatMessageModel {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory ChatMessageModel({
    required String id,
    required String senderId,
    required String receiverId,
    required String message,
    String? imageUrl,
    @Default(MessageStatus.sent) MessageStatus status,
    required DateTime createdAt,
  }) = _ChatMessageModel;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) => _$ChatMessageModelFromJson(json);
} 