// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'enhanced_chat_message_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MessageReaction _$MessageReactionFromJson(Map<String, dynamic> json) {
  return _MessageReaction.fromJson(json);
}

/// @nodoc
mixin _$MessageReaction {
  String get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String? get userAvatar => throw _privateConstructorUsedError;
  ReactionType get reaction => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this MessageReaction to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MessageReaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageReactionCopyWith<MessageReaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageReactionCopyWith<$Res> {
  factory $MessageReactionCopyWith(
    MessageReaction value,
    $Res Function(MessageReaction) then,
  ) = _$MessageReactionCopyWithImpl<$Res, MessageReaction>;
  @useResult
  $Res call({
    String userId,
    String userName,
    String? userAvatar,
    ReactionType reaction,
    DateTime createdAt,
  });
}

/// @nodoc
class _$MessageReactionCopyWithImpl<$Res, $Val extends MessageReaction>
    implements $MessageReactionCopyWith<$Res> {
  _$MessageReactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageReaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? userAvatar = freezed,
    Object? reaction = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            userAvatar: freezed == userAvatar
                ? _value.userAvatar
                : userAvatar // ignore: cast_nullable_to_non_nullable
                      as String?,
            reaction: null == reaction
                ? _value.reaction
                : reaction // ignore: cast_nullable_to_non_nullable
                      as ReactionType,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MessageReactionImplCopyWith<$Res>
    implements $MessageReactionCopyWith<$Res> {
  factory _$$MessageReactionImplCopyWith(
    _$MessageReactionImpl value,
    $Res Function(_$MessageReactionImpl) then,
  ) = __$$MessageReactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String userName,
    String? userAvatar,
    ReactionType reaction,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$MessageReactionImplCopyWithImpl<$Res>
    extends _$MessageReactionCopyWithImpl<$Res, _$MessageReactionImpl>
    implements _$$MessageReactionImplCopyWith<$Res> {
  __$$MessageReactionImplCopyWithImpl(
    _$MessageReactionImpl _value,
    $Res Function(_$MessageReactionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MessageReaction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? userAvatar = freezed,
    Object? reaction = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$MessageReactionImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        userAvatar: freezed == userAvatar
            ? _value.userAvatar
            : userAvatar // ignore: cast_nullable_to_non_nullable
                  as String?,
        reaction: null == reaction
            ? _value.reaction
            : reaction // ignore: cast_nullable_to_non_nullable
                  as ReactionType,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$MessageReactionImpl
    with DiagnosticableTreeMixin
    implements _MessageReaction {
  const _$MessageReactionImpl({
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.reaction,
    required this.createdAt,
  });

  factory _$MessageReactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageReactionImplFromJson(json);

  @override
  final String userId;
  @override
  final String userName;
  @override
  final String? userAvatar;
  @override
  final ReactionType reaction;
  @override
  final DateTime createdAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MessageReaction(userId: $userId, userName: $userName, userAvatar: $userAvatar, reaction: $reaction, createdAt: $createdAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MessageReaction'))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty('userName', userName))
      ..add(DiagnosticsProperty('userAvatar', userAvatar))
      ..add(DiagnosticsProperty('reaction', reaction))
      ..add(DiagnosticsProperty('createdAt', createdAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageReactionImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.userAvatar, userAvatar) ||
                other.userAvatar == userAvatar) &&
            (identical(other.reaction, reaction) ||
                other.reaction == reaction) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    userId,
    userName,
    userAvatar,
    reaction,
    createdAt,
  );

  /// Create a copy of MessageReaction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageReactionImplCopyWith<_$MessageReactionImpl> get copyWith =>
      __$$MessageReactionImplCopyWithImpl<_$MessageReactionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageReactionImplToJson(this);
  }
}

abstract class _MessageReaction implements MessageReaction {
  const factory _MessageReaction({
    required final String userId,
    required final String userName,
    final String? userAvatar,
    required final ReactionType reaction,
    required final DateTime createdAt,
  }) = _$MessageReactionImpl;

  factory _MessageReaction.fromJson(Map<String, dynamic> json) =
      _$MessageReactionImpl.fromJson;

  @override
  String get userId;
  @override
  String get userName;
  @override
  String? get userAvatar;
  @override
  ReactionType get reaction;
  @override
  DateTime get createdAt;

  /// Create a copy of MessageReaction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageReactionImplCopyWith<_$MessageReactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MediaAttachment _$MediaAttachmentFromJson(Map<String, dynamic> json) {
  return _MediaAttachment.fromJson(json);
}

/// @nodoc
mixin _$MediaAttachment {
  String get url => throw _privateConstructorUsedError;
  String get fileName => throw _privateConstructorUsedError;
  int get fileSize => throw _privateConstructorUsedError;
  String? get mimeType => throw _privateConstructorUsedError;
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  int? get width => throw _privateConstructorUsedError;
  int? get height => throw _privateConstructorUsedError;
  int? get duration => throw _privateConstructorUsedError;

  /// Serializes this MediaAttachment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MediaAttachment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MediaAttachmentCopyWith<MediaAttachment> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MediaAttachmentCopyWith<$Res> {
  factory $MediaAttachmentCopyWith(
    MediaAttachment value,
    $Res Function(MediaAttachment) then,
  ) = _$MediaAttachmentCopyWithImpl<$Res, MediaAttachment>;
  @useResult
  $Res call({
    String url,
    String fileName,
    int fileSize,
    String? mimeType,
    String? thumbnailUrl,
    int? width,
    int? height,
    int? duration,
  });
}

/// @nodoc
class _$MediaAttachmentCopyWithImpl<$Res, $Val extends MediaAttachment>
    implements $MediaAttachmentCopyWith<$Res> {
  _$MediaAttachmentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MediaAttachment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? fileName = null,
    Object? fileSize = null,
    Object? mimeType = freezed,
    Object? thumbnailUrl = freezed,
    Object? width = freezed,
    Object? height = freezed,
    Object? duration = freezed,
  }) {
    return _then(
      _value.copyWith(
            url: null == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String,
            fileName: null == fileName
                ? _value.fileName
                : fileName // ignore: cast_nullable_to_non_nullable
                      as String,
            fileSize: null == fileSize
                ? _value.fileSize
                : fileSize // ignore: cast_nullable_to_non_nullable
                      as int,
            mimeType: freezed == mimeType
                ? _value.mimeType
                : mimeType // ignore: cast_nullable_to_non_nullable
                      as String?,
            thumbnailUrl: freezed == thumbnailUrl
                ? _value.thumbnailUrl
                : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            width: freezed == width
                ? _value.width
                : width // ignore: cast_nullable_to_non_nullable
                      as int?,
            height: freezed == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                      as int?,
            duration: freezed == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MediaAttachmentImplCopyWith<$Res>
    implements $MediaAttachmentCopyWith<$Res> {
  factory _$$MediaAttachmentImplCopyWith(
    _$MediaAttachmentImpl value,
    $Res Function(_$MediaAttachmentImpl) then,
  ) = __$$MediaAttachmentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String url,
    String fileName,
    int fileSize,
    String? mimeType,
    String? thumbnailUrl,
    int? width,
    int? height,
    int? duration,
  });
}

/// @nodoc
class __$$MediaAttachmentImplCopyWithImpl<$Res>
    extends _$MediaAttachmentCopyWithImpl<$Res, _$MediaAttachmentImpl>
    implements _$$MediaAttachmentImplCopyWith<$Res> {
  __$$MediaAttachmentImplCopyWithImpl(
    _$MediaAttachmentImpl _value,
    $Res Function(_$MediaAttachmentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MediaAttachment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? fileName = null,
    Object? fileSize = null,
    Object? mimeType = freezed,
    Object? thumbnailUrl = freezed,
    Object? width = freezed,
    Object? height = freezed,
    Object? duration = freezed,
  }) {
    return _then(
      _$MediaAttachmentImpl(
        url: null == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String,
        fileName: null == fileName
            ? _value.fileName
            : fileName // ignore: cast_nullable_to_non_nullable
                  as String,
        fileSize: null == fileSize
            ? _value.fileSize
            : fileSize // ignore: cast_nullable_to_non_nullable
                  as int,
        mimeType: freezed == mimeType
            ? _value.mimeType
            : mimeType // ignore: cast_nullable_to_non_nullable
                  as String?,
        thumbnailUrl: freezed == thumbnailUrl
            ? _value.thumbnailUrl
            : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        width: freezed == width
            ? _value.width
            : width // ignore: cast_nullable_to_non_nullable
                  as int?,
        height: freezed == height
            ? _value.height
            : height // ignore: cast_nullable_to_non_nullable
                  as int?,
        duration: freezed == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$MediaAttachmentImpl
    with DiagnosticableTreeMixin
    implements _MediaAttachment {
  const _$MediaAttachmentImpl({
    required this.url,
    required this.fileName,
    required this.fileSize,
    this.mimeType,
    this.thumbnailUrl,
    this.width,
    this.height,
    this.duration,
  });

  factory _$MediaAttachmentImpl.fromJson(Map<String, dynamic> json) =>
      _$$MediaAttachmentImplFromJson(json);

  @override
  final String url;
  @override
  final String fileName;
  @override
  final int fileSize;
  @override
  final String? mimeType;
  @override
  final String? thumbnailUrl;
  @override
  final int? width;
  @override
  final int? height;
  @override
  final int? duration;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'MediaAttachment(url: $url, fileName: $fileName, fileSize: $fileSize, mimeType: $mimeType, thumbnailUrl: $thumbnailUrl, width: $width, height: $height, duration: $duration)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'MediaAttachment'))
      ..add(DiagnosticsProperty('url', url))
      ..add(DiagnosticsProperty('fileName', fileName))
      ..add(DiagnosticsProperty('fileSize', fileSize))
      ..add(DiagnosticsProperty('mimeType', mimeType))
      ..add(DiagnosticsProperty('thumbnailUrl', thumbnailUrl))
      ..add(DiagnosticsProperty('width', width))
      ..add(DiagnosticsProperty('height', height))
      ..add(DiagnosticsProperty('duration', duration));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MediaAttachmentImpl &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.mimeType, mimeType) ||
                other.mimeType == mimeType) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.duration, duration) ||
                other.duration == duration));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    url,
    fileName,
    fileSize,
    mimeType,
    thumbnailUrl,
    width,
    height,
    duration,
  );

  /// Create a copy of MediaAttachment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MediaAttachmentImplCopyWith<_$MediaAttachmentImpl> get copyWith =>
      __$$MediaAttachmentImplCopyWithImpl<_$MediaAttachmentImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MediaAttachmentImplToJson(this);
  }
}

abstract class _MediaAttachment implements MediaAttachment {
  const factory _MediaAttachment({
    required final String url,
    required final String fileName,
    required final int fileSize,
    final String? mimeType,
    final String? thumbnailUrl,
    final int? width,
    final int? height,
    final int? duration,
  }) = _$MediaAttachmentImpl;

  factory _MediaAttachment.fromJson(Map<String, dynamic> json) =
      _$MediaAttachmentImpl.fromJson;

  @override
  String get url;
  @override
  String get fileName;
  @override
  int get fileSize;
  @override
  String? get mimeType;
  @override
  String? get thumbnailUrl;
  @override
  int? get width;
  @override
  int? get height;
  @override
  int? get duration;

  /// Create a copy of MediaAttachment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MediaAttachmentImplCopyWith<_$MediaAttachmentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

EnhancedChatMessageModel _$EnhancedChatMessageModelFromJson(
  Map<String, dynamic> json,
) {
  return _EnhancedChatMessageModel.fromJson(json);
}

/// @nodoc
mixin _$EnhancedChatMessageModel {
  String get id => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  String get receiverId => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  MessageType get messageType => throw _privateConstructorUsedError;
  MediaAttachment? get mediaAttachment => throw _privateConstructorUsedError;
  String? get replyToMessageId => throw _privateConstructorUsedError;
  List<MessageReaction> get reactions => throw _privateConstructorUsedError;
  MessageStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  DateTime? get deletedAt => throw _privateConstructorUsedError;
  bool? get isEdited => throw _privateConstructorUsedError;
  bool? get isForwarded => throw _privateConstructorUsedError;
  String? get forwardedFromUserId => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this EnhancedChatMessageModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EnhancedChatMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EnhancedChatMessageModelCopyWith<EnhancedChatMessageModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EnhancedChatMessageModelCopyWith<$Res> {
  factory $EnhancedChatMessageModelCopyWith(
    EnhancedChatMessageModel value,
    $Res Function(EnhancedChatMessageModel) then,
  ) = _$EnhancedChatMessageModelCopyWithImpl<$Res, EnhancedChatMessageModel>;
  @useResult
  $Res call({
    String id,
    String senderId,
    String receiverId,
    String? message,
    MessageType messageType,
    MediaAttachment? mediaAttachment,
    String? replyToMessageId,
    List<MessageReaction> reactions,
    MessageStatus status,
    DateTime createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? isEdited,
    bool? isForwarded,
    String? forwardedFromUserId,
    Map<String, dynamic>? metadata,
  });

  $MediaAttachmentCopyWith<$Res>? get mediaAttachment;
}

/// @nodoc
class _$EnhancedChatMessageModelCopyWithImpl<
  $Res,
  $Val extends EnhancedChatMessageModel
>
    implements $EnhancedChatMessageModelCopyWith<$Res> {
  _$EnhancedChatMessageModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EnhancedChatMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? senderId = null,
    Object? receiverId = null,
    Object? message = freezed,
    Object? messageType = null,
    Object? mediaAttachment = freezed,
    Object? replyToMessageId = freezed,
    Object? reactions = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
    Object? isEdited = freezed,
    Object? isForwarded = freezed,
    Object? forwardedFromUserId = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            senderId: null == senderId
                ? _value.senderId
                : senderId // ignore: cast_nullable_to_non_nullable
                      as String,
            receiverId: null == receiverId
                ? _value.receiverId
                : receiverId // ignore: cast_nullable_to_non_nullable
                      as String,
            message: freezed == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String?,
            messageType: null == messageType
                ? _value.messageType
                : messageType // ignore: cast_nullable_to_non_nullable
                      as MessageType,
            mediaAttachment: freezed == mediaAttachment
                ? _value.mediaAttachment
                : mediaAttachment // ignore: cast_nullable_to_non_nullable
                      as MediaAttachment?,
            replyToMessageId: freezed == replyToMessageId
                ? _value.replyToMessageId
                : replyToMessageId // ignore: cast_nullable_to_non_nullable
                      as String?,
            reactions: null == reactions
                ? _value.reactions
                : reactions // ignore: cast_nullable_to_non_nullable
                      as List<MessageReaction>,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as MessageStatus,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            deletedAt: freezed == deletedAt
                ? _value.deletedAt
                : deletedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            isEdited: freezed == isEdited
                ? _value.isEdited
                : isEdited // ignore: cast_nullable_to_non_nullable
                      as bool?,
            isForwarded: freezed == isForwarded
                ? _value.isForwarded
                : isForwarded // ignore: cast_nullable_to_non_nullable
                      as bool?,
            forwardedFromUserId: freezed == forwardedFromUserId
                ? _value.forwardedFromUserId
                : forwardedFromUserId // ignore: cast_nullable_to_non_nullable
                      as String?,
            metadata: freezed == metadata
                ? _value.metadata
                : metadata // ignore: cast_nullable_to_non_nullable
                      as Map<String, dynamic>?,
          )
          as $Val,
    );
  }

  /// Create a copy of EnhancedChatMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MediaAttachmentCopyWith<$Res>? get mediaAttachment {
    if (_value.mediaAttachment == null) {
      return null;
    }

    return $MediaAttachmentCopyWith<$Res>(_value.mediaAttachment!, (value) {
      return _then(_value.copyWith(mediaAttachment: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$EnhancedChatMessageModelImplCopyWith<$Res>
    implements $EnhancedChatMessageModelCopyWith<$Res> {
  factory _$$EnhancedChatMessageModelImplCopyWith(
    _$EnhancedChatMessageModelImpl value,
    $Res Function(_$EnhancedChatMessageModelImpl) then,
  ) = __$$EnhancedChatMessageModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String senderId,
    String receiverId,
    String? message,
    MessageType messageType,
    MediaAttachment? mediaAttachment,
    String? replyToMessageId,
    List<MessageReaction> reactions,
    MessageStatus status,
    DateTime createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? isEdited,
    bool? isForwarded,
    String? forwardedFromUserId,
    Map<String, dynamic>? metadata,
  });

  @override
  $MediaAttachmentCopyWith<$Res>? get mediaAttachment;
}

/// @nodoc
class __$$EnhancedChatMessageModelImplCopyWithImpl<$Res>
    extends
        _$EnhancedChatMessageModelCopyWithImpl<
          $Res,
          _$EnhancedChatMessageModelImpl
        >
    implements _$$EnhancedChatMessageModelImplCopyWith<$Res> {
  __$$EnhancedChatMessageModelImplCopyWithImpl(
    _$EnhancedChatMessageModelImpl _value,
    $Res Function(_$EnhancedChatMessageModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of EnhancedChatMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? senderId = null,
    Object? receiverId = null,
    Object? message = freezed,
    Object? messageType = null,
    Object? mediaAttachment = freezed,
    Object? replyToMessageId = freezed,
    Object? reactions = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
    Object? deletedAt = freezed,
    Object? isEdited = freezed,
    Object? isForwarded = freezed,
    Object? forwardedFromUserId = freezed,
    Object? metadata = freezed,
  }) {
    return _then(
      _$EnhancedChatMessageModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        senderId: null == senderId
            ? _value.senderId
            : senderId // ignore: cast_nullable_to_non_nullable
                  as String,
        receiverId: null == receiverId
            ? _value.receiverId
            : receiverId // ignore: cast_nullable_to_non_nullable
                  as String,
        message: freezed == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String?,
        messageType: null == messageType
            ? _value.messageType
            : messageType // ignore: cast_nullable_to_non_nullable
                  as MessageType,
        mediaAttachment: freezed == mediaAttachment
            ? _value.mediaAttachment
            : mediaAttachment // ignore: cast_nullable_to_non_nullable
                  as MediaAttachment?,
        replyToMessageId: freezed == replyToMessageId
            ? _value.replyToMessageId
            : replyToMessageId // ignore: cast_nullable_to_non_nullable
                  as String?,
        reactions: null == reactions
            ? _value._reactions
            : reactions // ignore: cast_nullable_to_non_nullable
                  as List<MessageReaction>,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as MessageStatus,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        deletedAt: freezed == deletedAt
            ? _value.deletedAt
            : deletedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        isEdited: freezed == isEdited
            ? _value.isEdited
            : isEdited // ignore: cast_nullable_to_non_nullable
                  as bool?,
        isForwarded: freezed == isForwarded
            ? _value.isForwarded
            : isForwarded // ignore: cast_nullable_to_non_nullable
                  as bool?,
        forwardedFromUserId: freezed == forwardedFromUserId
            ? _value.forwardedFromUserId
            : forwardedFromUserId // ignore: cast_nullable_to_non_nullable
                  as String?,
        metadata: freezed == metadata
            ? _value._metadata
            : metadata // ignore: cast_nullable_to_non_nullable
                  as Map<String, dynamic>?,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$EnhancedChatMessageModelImpl
    with DiagnosticableTreeMixin
    implements _EnhancedChatMessageModel {
  const _$EnhancedChatMessageModelImpl({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.message,
    this.messageType = MessageType.text,
    this.mediaAttachment,
    this.replyToMessageId,
    final List<MessageReaction> reactions = const [],
    this.status = MessageStatus.sent,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.isEdited,
    this.isForwarded,
    this.forwardedFromUserId,
    final Map<String, dynamic>? metadata,
  }) : _reactions = reactions,
       _metadata = metadata;

  factory _$EnhancedChatMessageModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$EnhancedChatMessageModelImplFromJson(json);

  @override
  final String id;
  @override
  final String senderId;
  @override
  final String receiverId;
  @override
  final String? message;
  @override
  @JsonKey()
  final MessageType messageType;
  @override
  final MediaAttachment? mediaAttachment;
  @override
  final String? replyToMessageId;
  final List<MessageReaction> _reactions;
  @override
  @JsonKey()
  List<MessageReaction> get reactions {
    if (_reactions is EqualUnmodifiableListView) return _reactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reactions);
  }

  @override
  @JsonKey()
  final MessageStatus status;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final bool? isEdited;
  @override
  final bool? isForwarded;
  @override
  final String? forwardedFromUserId;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'EnhancedChatMessageModel(id: $id, senderId: $senderId, receiverId: $receiverId, message: $message, messageType: $messageType, mediaAttachment: $mediaAttachment, replyToMessageId: $replyToMessageId, reactions: $reactions, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt, isEdited: $isEdited, isForwarded: $isForwarded, forwardedFromUserId: $forwardedFromUserId, metadata: $metadata)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'EnhancedChatMessageModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('senderId', senderId))
      ..add(DiagnosticsProperty('receiverId', receiverId))
      ..add(DiagnosticsProperty('message', message))
      ..add(DiagnosticsProperty('messageType', messageType))
      ..add(DiagnosticsProperty('mediaAttachment', mediaAttachment))
      ..add(DiagnosticsProperty('replyToMessageId', replyToMessageId))
      ..add(DiagnosticsProperty('reactions', reactions))
      ..add(DiagnosticsProperty('status', status))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt))
      ..add(DiagnosticsProperty('deletedAt', deletedAt))
      ..add(DiagnosticsProperty('isEdited', isEdited))
      ..add(DiagnosticsProperty('isForwarded', isForwarded))
      ..add(DiagnosticsProperty('forwardedFromUserId', forwardedFromUserId))
      ..add(DiagnosticsProperty('metadata', metadata));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EnhancedChatMessageModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.receiverId, receiverId) ||
                other.receiverId == receiverId) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.messageType, messageType) ||
                other.messageType == messageType) &&
            (identical(other.mediaAttachment, mediaAttachment) ||
                other.mediaAttachment == mediaAttachment) &&
            (identical(other.replyToMessageId, replyToMessageId) ||
                other.replyToMessageId == replyToMessageId) &&
            const DeepCollectionEquality().equals(
              other._reactions,
              _reactions,
            ) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.isEdited, isEdited) ||
                other.isEdited == isEdited) &&
            (identical(other.isForwarded, isForwarded) ||
                other.isForwarded == isForwarded) &&
            (identical(other.forwardedFromUserId, forwardedFromUserId) ||
                other.forwardedFromUserId == forwardedFromUserId) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    senderId,
    receiverId,
    message,
    messageType,
    mediaAttachment,
    replyToMessageId,
    const DeepCollectionEquality().hash(_reactions),
    status,
    createdAt,
    updatedAt,
    deletedAt,
    isEdited,
    isForwarded,
    forwardedFromUserId,
    const DeepCollectionEquality().hash(_metadata),
  );

  /// Create a copy of EnhancedChatMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EnhancedChatMessageModelImplCopyWith<_$EnhancedChatMessageModelImpl>
  get copyWith =>
      __$$EnhancedChatMessageModelImplCopyWithImpl<
        _$EnhancedChatMessageModelImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EnhancedChatMessageModelImplToJson(this);
  }
}

abstract class _EnhancedChatMessageModel implements EnhancedChatMessageModel {
  const factory _EnhancedChatMessageModel({
    required final String id,
    required final String senderId,
    required final String receiverId,
    final String? message,
    final MessageType messageType,
    final MediaAttachment? mediaAttachment,
    final String? replyToMessageId,
    final List<MessageReaction> reactions,
    final MessageStatus status,
    required final DateTime createdAt,
    final DateTime? updatedAt,
    final DateTime? deletedAt,
    final bool? isEdited,
    final bool? isForwarded,
    final String? forwardedFromUserId,
    final Map<String, dynamic>? metadata,
  }) = _$EnhancedChatMessageModelImpl;

  factory _EnhancedChatMessageModel.fromJson(Map<String, dynamic> json) =
      _$EnhancedChatMessageModelImpl.fromJson;

  @override
  String get id;
  @override
  String get senderId;
  @override
  String get receiverId;
  @override
  String? get message;
  @override
  MessageType get messageType;
  @override
  MediaAttachment? get mediaAttachment;
  @override
  String? get replyToMessageId;
  @override
  List<MessageReaction> get reactions;
  @override
  MessageStatus get status;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  DateTime? get deletedAt;
  @override
  bool? get isEdited;
  @override
  bool? get isForwarded;
  @override
  String? get forwardedFromUserId;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of EnhancedChatMessageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EnhancedChatMessageModelImplCopyWith<_$EnhancedChatMessageModelImpl>
  get copyWith => throw _privateConstructorUsedError;
}

TypingIndicator _$TypingIndicatorFromJson(Map<String, dynamic> json) {
  return _TypingIndicator.fromJson(json);
}

/// @nodoc
mixin _$TypingIndicator {
  String get userId => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String? get userAvatar => throw _privateConstructorUsedError;
  DateTime get startedAt => throw _privateConstructorUsedError;

  /// Serializes this TypingIndicator to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TypingIndicator
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TypingIndicatorCopyWith<TypingIndicator> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TypingIndicatorCopyWith<$Res> {
  factory $TypingIndicatorCopyWith(
    TypingIndicator value,
    $Res Function(TypingIndicator) then,
  ) = _$TypingIndicatorCopyWithImpl<$Res, TypingIndicator>;
  @useResult
  $Res call({
    String userId,
    String userName,
    String? userAvatar,
    DateTime startedAt,
  });
}

/// @nodoc
class _$TypingIndicatorCopyWithImpl<$Res, $Val extends TypingIndicator>
    implements $TypingIndicatorCopyWith<$Res> {
  _$TypingIndicatorCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TypingIndicator
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? userAvatar = freezed,
    Object? startedAt = null,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            userName: null == userName
                ? _value.userName
                : userName // ignore: cast_nullable_to_non_nullable
                      as String,
            userAvatar: freezed == userAvatar
                ? _value.userAvatar
                : userAvatar // ignore: cast_nullable_to_non_nullable
                      as String?,
            startedAt: null == startedAt
                ? _value.startedAt
                : startedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TypingIndicatorImplCopyWith<$Res>
    implements $TypingIndicatorCopyWith<$Res> {
  factory _$$TypingIndicatorImplCopyWith(
    _$TypingIndicatorImpl value,
    $Res Function(_$TypingIndicatorImpl) then,
  ) = __$$TypingIndicatorImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String userId,
    String userName,
    String? userAvatar,
    DateTime startedAt,
  });
}

/// @nodoc
class __$$TypingIndicatorImplCopyWithImpl<$Res>
    extends _$TypingIndicatorCopyWithImpl<$Res, _$TypingIndicatorImpl>
    implements _$$TypingIndicatorImplCopyWith<$Res> {
  __$$TypingIndicatorImplCopyWithImpl(
    _$TypingIndicatorImpl _value,
    $Res Function(_$TypingIndicatorImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TypingIndicator
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? userName = null,
    Object? userAvatar = freezed,
    Object? startedAt = null,
  }) {
    return _then(
      _$TypingIndicatorImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        userName: null == userName
            ? _value.userName
            : userName // ignore: cast_nullable_to_non_nullable
                  as String,
        userAvatar: freezed == userAvatar
            ? _value.userAvatar
            : userAvatar // ignore: cast_nullable_to_non_nullable
                  as String?,
        startedAt: null == startedAt
            ? _value.startedAt
            : startedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$TypingIndicatorImpl
    with DiagnosticableTreeMixin
    implements _TypingIndicator {
  const _$TypingIndicatorImpl({
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.startedAt,
  });

  factory _$TypingIndicatorImpl.fromJson(Map<String, dynamic> json) =>
      _$$TypingIndicatorImplFromJson(json);

  @override
  final String userId;
  @override
  final String userName;
  @override
  final String? userAvatar;
  @override
  final DateTime startedAt;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TypingIndicator(userId: $userId, userName: $userName, userAvatar: $userAvatar, startedAt: $startedAt)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'TypingIndicator'))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty('userName', userName))
      ..add(DiagnosticsProperty('userAvatar', userAvatar))
      ..add(DiagnosticsProperty('startedAt', startedAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TypingIndicatorImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.userAvatar, userAvatar) ||
                other.userAvatar == userAvatar) &&
            (identical(other.startedAt, startedAt) ||
                other.startedAt == startedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, userName, userAvatar, startedAt);

  /// Create a copy of TypingIndicator
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TypingIndicatorImplCopyWith<_$TypingIndicatorImpl> get copyWith =>
      __$$TypingIndicatorImplCopyWithImpl<_$TypingIndicatorImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TypingIndicatorImplToJson(this);
  }
}

abstract class _TypingIndicator implements TypingIndicator {
  const factory _TypingIndicator({
    required final String userId,
    required final String userName,
    final String? userAvatar,
    required final DateTime startedAt,
  }) = _$TypingIndicatorImpl;

  factory _TypingIndicator.fromJson(Map<String, dynamic> json) =
      _$TypingIndicatorImpl.fromJson;

  @override
  String get userId;
  @override
  String get userName;
  @override
  String? get userAvatar;
  @override
  DateTime get startedAt;

  /// Create a copy of TypingIndicator
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TypingIndicatorImplCopyWith<_$TypingIndicatorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ChatPresence _$ChatPresenceFromJson(Map<String, dynamic> json) {
  return _ChatPresence.fromJson(json);
}

/// @nodoc
mixin _$ChatPresence {
  String get userId => throw _privateConstructorUsedError;
  bool get isOnline => throw _privateConstructorUsedError;
  DateTime? get lastSeen => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;

  /// Serializes this ChatPresence to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatPresence
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatPresenceCopyWith<ChatPresence> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatPresenceCopyWith<$Res> {
  factory $ChatPresenceCopyWith(
    ChatPresence value,
    $Res Function(ChatPresence) then,
  ) = _$ChatPresenceCopyWithImpl<$Res, ChatPresence>;
  @useResult
  $Res call({String userId, bool isOnline, DateTime? lastSeen, String? status});
}

/// @nodoc
class _$ChatPresenceCopyWithImpl<$Res, $Val extends ChatPresence>
    implements $ChatPresenceCopyWith<$Res> {
  _$ChatPresenceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatPresence
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? isOnline = null,
    Object? lastSeen = freezed,
    Object? status = freezed,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            isOnline: null == isOnline
                ? _value.isOnline
                : isOnline // ignore: cast_nullable_to_non_nullable
                      as bool,
            lastSeen: freezed == lastSeen
                ? _value.lastSeen
                : lastSeen // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ChatPresenceImplCopyWith<$Res>
    implements $ChatPresenceCopyWith<$Res> {
  factory _$$ChatPresenceImplCopyWith(
    _$ChatPresenceImpl value,
    $Res Function(_$ChatPresenceImpl) then,
  ) = __$$ChatPresenceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String userId, bool isOnline, DateTime? lastSeen, String? status});
}

/// @nodoc
class __$$ChatPresenceImplCopyWithImpl<$Res>
    extends _$ChatPresenceCopyWithImpl<$Res, _$ChatPresenceImpl>
    implements _$$ChatPresenceImplCopyWith<$Res> {
  __$$ChatPresenceImplCopyWithImpl(
    _$ChatPresenceImpl _value,
    $Res Function(_$ChatPresenceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ChatPresence
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? isOnline = null,
    Object? lastSeen = freezed,
    Object? status = freezed,
  }) {
    return _then(
      _$ChatPresenceImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        isOnline: null == isOnline
            ? _value.isOnline
            : isOnline // ignore: cast_nullable_to_non_nullable
                  as bool,
        lastSeen: freezed == lastSeen
            ? _value.lastSeen
            : lastSeen // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

@JsonSerializable(fieldRename: FieldRename.snake)
class _$ChatPresenceImpl with DiagnosticableTreeMixin implements _ChatPresence {
  const _$ChatPresenceImpl({
    required this.userId,
    required this.isOnline,
    this.lastSeen,
    this.status,
  });

  factory _$ChatPresenceImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatPresenceImplFromJson(json);

  @override
  final String userId;
  @override
  final bool isOnline;
  @override
  final DateTime? lastSeen;
  @override
  final String? status;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ChatPresence(userId: $userId, isOnline: $isOnline, lastSeen: $lastSeen, status: $status)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'ChatPresence'))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty('isOnline', isOnline))
      ..add(DiagnosticsProperty('lastSeen', lastSeen))
      ..add(DiagnosticsProperty('status', status));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatPresenceImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline) &&
            (identical(other.lastSeen, lastSeen) ||
                other.lastSeen == lastSeen) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, userId, isOnline, lastSeen, status);

  /// Create a copy of ChatPresence
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatPresenceImplCopyWith<_$ChatPresenceImpl> get copyWith =>
      __$$ChatPresenceImplCopyWithImpl<_$ChatPresenceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatPresenceImplToJson(this);
  }
}

abstract class _ChatPresence implements ChatPresence {
  const factory _ChatPresence({
    required final String userId,
    required final bool isOnline,
    final DateTime? lastSeen,
    final String? status,
  }) = _$ChatPresenceImpl;

  factory _ChatPresence.fromJson(Map<String, dynamic> json) =
      _$ChatPresenceImpl.fromJson;

  @override
  String get userId;
  @override
  bool get isOnline;
  @override
  DateTime? get lastSeen;
  @override
  String? get status;

  /// Create a copy of ChatPresence
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatPresenceImplCopyWith<_$ChatPresenceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
