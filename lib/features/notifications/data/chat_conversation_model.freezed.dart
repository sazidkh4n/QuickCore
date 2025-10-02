// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_conversation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ChatConversationModel _$ChatConversationModelFromJson(
  Map<String, dynamic> json,
) {
  return _ChatConversationModel.fromJson(json);
}

/// @nodoc
mixin _$ChatConversationModel {
  @JsonKey(name: 'id')
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'other_user_id')
  String get otherUserId => throw _privateConstructorUsedError;
  @JsonKey(name: 'other_user_name')
  String get otherUserName => throw _privateConstructorUsedError;
  @JsonKey(name: 'other_user_avatar')
  String? get otherUserAvatar => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_message')
  String? get lastMessage => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_message_time')
  DateTime get lastMessageTime => throw _privateConstructorUsedError;
  @JsonKey(name: 'unread_count')
  int get unreadCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_online')
  bool get isOnline => throw _privateConstructorUsedError;

  /// Serializes this ChatConversationModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatConversationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatConversationModelCopyWith<ChatConversationModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatConversationModelCopyWith<$Res> {
  factory $ChatConversationModelCopyWith(
    ChatConversationModel value,
    $Res Function(ChatConversationModel) then,
  ) = _$ChatConversationModelCopyWithImpl<$Res, ChatConversationModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'id') String id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'other_user_id') String otherUserId,
    @JsonKey(name: 'other_user_name') String otherUserName,
    @JsonKey(name: 'other_user_avatar') String? otherUserAvatar,
    @JsonKey(name: 'last_message') String? lastMessage,
    @JsonKey(name: 'last_message_time') DateTime lastMessageTime,
    @JsonKey(name: 'unread_count') int unreadCount,
    @JsonKey(name: 'is_online') bool isOnline,
  });
}

/// @nodoc
class _$ChatConversationModelCopyWithImpl<
  $Res,
  $Val extends ChatConversationModel
>
    implements $ChatConversationModelCopyWith<$Res> {
  _$ChatConversationModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatConversationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? otherUserId = null,
    Object? otherUserName = null,
    Object? otherUserAvatar = freezed,
    Object? lastMessage = freezed,
    Object? lastMessageTime = null,
    Object? unreadCount = null,
    Object? isOnline = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            otherUserId: null == otherUserId
                ? _value.otherUserId
                : otherUserId // ignore: cast_nullable_to_non_nullable
                      as String,
            otherUserName: null == otherUserName
                ? _value.otherUserName
                : otherUserName // ignore: cast_nullable_to_non_nullable
                      as String,
            otherUserAvatar: freezed == otherUserAvatar
                ? _value.otherUserAvatar
                : otherUserAvatar // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastMessage: freezed == lastMessage
                ? _value.lastMessage
                : lastMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastMessageTime: null == lastMessageTime
                ? _value.lastMessageTime
                : lastMessageTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            unreadCount: null == unreadCount
                ? _value.unreadCount
                : unreadCount // ignore: cast_nullable_to_non_nullable
                      as int,
            isOnline: null == isOnline
                ? _value.isOnline
                : isOnline // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatConversationModelImplCopyWith<$Res>
    implements $ChatConversationModelCopyWith<$Res> {
  factory _$$ChatConversationModelImplCopyWith(
    _$ChatConversationModelImpl value,
    $Res Function(_$ChatConversationModelImpl) then,
  ) = __$$ChatConversationModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'id') String id,
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'other_user_id') String otherUserId,
    @JsonKey(name: 'other_user_name') String otherUserName,
    @JsonKey(name: 'other_user_avatar') String? otherUserAvatar,
    @JsonKey(name: 'last_message') String? lastMessage,
    @JsonKey(name: 'last_message_time') DateTime lastMessageTime,
    @JsonKey(name: 'unread_count') int unreadCount,
    @JsonKey(name: 'is_online') bool isOnline,
  });
}

/// @nodoc
class __$$ChatConversationModelImplCopyWithImpl<$Res>
    extends
        _$ChatConversationModelCopyWithImpl<$Res, _$ChatConversationModelImpl>
    implements _$$ChatConversationModelImplCopyWith<$Res> {
  __$$ChatConversationModelImplCopyWithImpl(
    _$ChatConversationModelImpl _value,
    $Res Function(_$ChatConversationModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatConversationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? otherUserId = null,
    Object? otherUserName = null,
    Object? otherUserAvatar = freezed,
    Object? lastMessage = freezed,
    Object? lastMessageTime = null,
    Object? unreadCount = null,
    Object? isOnline = null,
  }) {
    return _then(
      _$ChatConversationModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        otherUserId: null == otherUserId
            ? _value.otherUserId
            : otherUserId // ignore: cast_nullable_to_non_nullable
                  as String,
        otherUserName: null == otherUserName
            ? _value.otherUserName
            : otherUserName // ignore: cast_nullable_to_non_nullable
                  as String,
        otherUserAvatar: freezed == otherUserAvatar
            ? _value.otherUserAvatar
            : otherUserAvatar // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastMessage: freezed == lastMessage
            ? _value.lastMessage
            : lastMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastMessageTime: null == lastMessageTime
            ? _value.lastMessageTime
            : lastMessageTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        unreadCount: null == unreadCount
            ? _value.unreadCount
            : unreadCount // ignore: cast_nullable_to_non_nullable
                  as int,
        isOnline: null == isOnline
            ? _value.isOnline
            : isOnline // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatConversationModelImpl
    with DiagnosticableTreeMixin
    implements _ChatConversationModel {
  const _$ChatConversationModelImpl({
    @JsonKey(name: 'id') required this.id,
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'other_user_id') required this.otherUserId,
    @JsonKey(name: 'other_user_name') required this.otherUserName,
    @JsonKey(name: 'other_user_avatar') this.otherUserAvatar,
    @JsonKey(name: 'last_message') this.lastMessage,
    @JsonKey(name: 'last_message_time') required this.lastMessageTime,
    @JsonKey(name: 'unread_count') this.unreadCount = 0,
    @JsonKey(name: 'is_online') this.isOnline = false,
  });

  factory _$ChatConversationModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatConversationModelImplFromJson(json);

  @override
  @JsonKey(name: 'id')
  final String id;
  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'other_user_id')
  final String otherUserId;
  @override
  @JsonKey(name: 'other_user_name')
  final String otherUserName;
  @override
  @JsonKey(name: 'other_user_avatar')
  final String? otherUserAvatar;
  @override
  @JsonKey(name: 'last_message')
  final String? lastMessage;
  @override
  @JsonKey(name: 'last_message_time')
  final DateTime lastMessageTime;
  @override
  @JsonKey(name: 'unread_count')
  final int unreadCount;
  @override
  @JsonKey(name: 'is_online')
  final bool isOnline;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ChatConversationModel(id: $id, userId: $userId, otherUserId: $otherUserId, otherUserName: $otherUserName, otherUserAvatar: $otherUserAvatar, lastMessage: $lastMessage, lastMessageTime: $lastMessageTime, unreadCount: $unreadCount, isOnline: $isOnline)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ChatConversationModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty('otherUserId', otherUserId))
      ..add(DiagnosticsProperty('otherUserName', otherUserName))
      ..add(DiagnosticsProperty('otherUserAvatar', otherUserAvatar))
      ..add(DiagnosticsProperty('lastMessage', lastMessage))
      ..add(DiagnosticsProperty('lastMessageTime', lastMessageTime))
      ..add(DiagnosticsProperty('unreadCount', unreadCount))
      ..add(DiagnosticsProperty('isOnline', isOnline));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatConversationModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.otherUserId, otherUserId) ||
                other.otherUserId == otherUserId) &&
            (identical(other.otherUserName, otherUserName) ||
                other.otherUserName == otherUserName) &&
            (identical(other.otherUserAvatar, otherUserAvatar) ||
                other.otherUserAvatar == otherUserAvatar) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            (identical(other.lastMessageTime, lastMessageTime) ||
                other.lastMessageTime == lastMessageTime) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    otherUserId,
    otherUserName,
    otherUserAvatar,
    lastMessage,
    lastMessageTime,
    unreadCount,
    isOnline,
  );

  /// Create a copy of ChatConversationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatConversationModelImplCopyWith<_$ChatConversationModelImpl>
  get copyWith =>
      __$$ChatConversationModelImplCopyWithImpl<_$ChatConversationModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatConversationModelImplToJson(this);
  }
}

abstract class _ChatConversationModel implements ChatConversationModel {
  const factory _ChatConversationModel({
    @JsonKey(name: 'id') required final String id,
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'other_user_id') required final String otherUserId,
    @JsonKey(name: 'other_user_name') required final String otherUserName,
    @JsonKey(name: 'other_user_avatar') final String? otherUserAvatar,
    @JsonKey(name: 'last_message') final String? lastMessage,
    @JsonKey(name: 'last_message_time') required final DateTime lastMessageTime,
    @JsonKey(name: 'unread_count') final int unreadCount,
    @JsonKey(name: 'is_online') final bool isOnline,
  }) = _$ChatConversationModelImpl;

  factory _ChatConversationModel.fromJson(Map<String, dynamic> json) =
      _$ChatConversationModelImpl.fromJson;

  @override
  @JsonKey(name: 'id')
  String get id;
  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'other_user_id')
  String get otherUserId;
  @override
  @JsonKey(name: 'other_user_name')
  String get otherUserName;
  @override
  @JsonKey(name: 'other_user_avatar')
  String? get otherUserAvatar;
  @override
  @JsonKey(name: 'last_message')
  String? get lastMessage;
  @override
  @JsonKey(name: 'last_message_time')
  DateTime get lastMessageTime;
  @override
  @JsonKey(name: 'unread_count')
  int get unreadCount;
  @override
  @JsonKey(name: 'is_online')
  bool get isOnline;

  /// Create a copy of ChatConversationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatConversationModelImplCopyWith<_$ChatConversationModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}
