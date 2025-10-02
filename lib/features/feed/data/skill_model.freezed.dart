// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'skill_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SkillModel _$SkillModelFromJson(Map<String, dynamic> json) {
  return _SkillModel.fromJson(json);
}

/// @nodoc
mixin _$SkillModel {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'video_url')
  String get videoUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'thumbnail_url')
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  @JsonKey(name: 'creator_id')
  String? get creatorId => throw _privateConstructorUsedError;
  @JsonKey(name: 'creator_name')
  String? get creatorName => throw _privateConstructorUsedError;
  @JsonKey(name: 'creator_avatar_url')
  String? get creatorAvatarUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'view_count')
  int get viewCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  @JsonKey(name: 'like_count')
  int get likeCount => throw _privateConstructorUsedError;
  @JsonKey(name: 'duration')
  int? get duration => throw _privateConstructorUsedError;

  /// Serializes this SkillModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SkillModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SkillModelCopyWith<SkillModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SkillModelCopyWith<$Res> {
  factory $SkillModelCopyWith(
    SkillModel value,
    $Res Function(SkillModel) then,
  ) = _$SkillModelCopyWithImpl<$Res, SkillModel>;
  @useResult
  $Res call({
    String id,
    String title,
    String? description,
    @JsonKey(name: 'video_url') String videoUrl,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    String category,
    @JsonKey(name: 'creator_id') String? creatorId,
    @JsonKey(name: 'creator_name') String? creatorName,
    @JsonKey(name: 'creator_avatar_url') String? creatorAvatarUrl,
    @JsonKey(name: 'view_count') int viewCount,
    @JsonKey(name: 'created_at') DateTime createdAt,
    List<String> tags,
    @JsonKey(name: 'like_count') int likeCount,
    @JsonKey(name: 'duration') int? duration,
  });
}

/// @nodoc
class _$SkillModelCopyWithImpl<$Res, $Val extends SkillModel>
    implements $SkillModelCopyWith<$Res> {
  _$SkillModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SkillModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? videoUrl = null,
    Object? thumbnailUrl = freezed,
    Object? category = null,
    Object? creatorId = freezed,
    Object? creatorName = freezed,
    Object? creatorAvatarUrl = freezed,
    Object? viewCount = null,
    Object? createdAt = null,
    Object? tags = null,
    Object? likeCount = null,
    Object? duration = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            videoUrl: null == videoUrl
                ? _value.videoUrl
                : videoUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            thumbnailUrl: freezed == thumbnailUrl
                ? _value.thumbnailUrl
                : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            creatorId: freezed == creatorId
                ? _value.creatorId
                : creatorId // ignore: cast_nullable_to_non_nullable
                      as String?,
            creatorName: freezed == creatorName
                ? _value.creatorName
                : creatorName // ignore: cast_nullable_to_non_nullable
                      as String?,
            creatorAvatarUrl: freezed == creatorAvatarUrl
                ? _value.creatorAvatarUrl
                : creatorAvatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            viewCount: null == viewCount
                ? _value.viewCount
                : viewCount // ignore: cast_nullable_to_non_nullable
                      as int,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            likeCount: null == likeCount
                ? _value.likeCount
                : likeCount // ignore: cast_nullable_to_non_nullable
                      as int,
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
abstract class _$$SkillModelImplCopyWith<$Res>
    implements $SkillModelCopyWith<$Res> {
  factory _$$SkillModelImplCopyWith(
    _$SkillModelImpl value,
    $Res Function(_$SkillModelImpl) then,
  ) = __$$SkillModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String? description,
    @JsonKey(name: 'video_url') String videoUrl,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    String category,
    @JsonKey(name: 'creator_id') String? creatorId,
    @JsonKey(name: 'creator_name') String? creatorName,
    @JsonKey(name: 'creator_avatar_url') String? creatorAvatarUrl,
    @JsonKey(name: 'view_count') int viewCount,
    @JsonKey(name: 'created_at') DateTime createdAt,
    List<String> tags,
    @JsonKey(name: 'like_count') int likeCount,
    @JsonKey(name: 'duration') int? duration,
  });
}

/// @nodoc
class __$$SkillModelImplCopyWithImpl<$Res>
    extends _$SkillModelCopyWithImpl<$Res, _$SkillModelImpl>
    implements _$$SkillModelImplCopyWith<$Res> {
  __$$SkillModelImplCopyWithImpl(
    _$SkillModelImpl _value,
    $Res Function(_$SkillModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SkillModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? videoUrl = null,
    Object? thumbnailUrl = freezed,
    Object? category = null,
    Object? creatorId = freezed,
    Object? creatorName = freezed,
    Object? creatorAvatarUrl = freezed,
    Object? viewCount = null,
    Object? createdAt = null,
    Object? tags = null,
    Object? likeCount = null,
    Object? duration = freezed,
  }) {
    return _then(
      _$SkillModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        videoUrl: null == videoUrl
            ? _value.videoUrl
            : videoUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        thumbnailUrl: freezed == thumbnailUrl
            ? _value.thumbnailUrl
            : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        creatorId: freezed == creatorId
            ? _value.creatorId
            : creatorId // ignore: cast_nullable_to_non_nullable
                  as String?,
        creatorName: freezed == creatorName
            ? _value.creatorName
            : creatorName // ignore: cast_nullable_to_non_nullable
                  as String?,
        creatorAvatarUrl: freezed == creatorAvatarUrl
            ? _value.creatorAvatarUrl
            : creatorAvatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        viewCount: null == viewCount
            ? _value.viewCount
            : viewCount // ignore: cast_nullable_to_non_nullable
                  as int,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        likeCount: null == likeCount
            ? _value.likeCount
            : likeCount // ignore: cast_nullable_to_non_nullable
                  as int,
        duration: freezed == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SkillModelImpl implements _SkillModel {
  const _$SkillModelImpl({
    required this.id,
    required this.title,
    this.description,
    @JsonKey(name: 'video_url') required this.videoUrl,
    @JsonKey(name: 'thumbnail_url') this.thumbnailUrl,
    required this.category,
    @JsonKey(name: 'creator_id') this.creatorId,
    @JsonKey(name: 'creator_name') this.creatorName,
    @JsonKey(name: 'creator_avatar_url') this.creatorAvatarUrl,
    @JsonKey(name: 'view_count') this.viewCount = 0,
    @JsonKey(name: 'created_at') required this.createdAt,
    final List<String> tags = const [],
    @JsonKey(name: 'like_count') this.likeCount = 0,
    @JsonKey(name: 'duration') this.duration,
  }) : _tags = tags;

  factory _$SkillModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SkillModelImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String? description;
  @override
  @JsonKey(name: 'video_url')
  final String videoUrl;
  @override
  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;
  @override
  final String category;
  @override
  @JsonKey(name: 'creator_id')
  final String? creatorId;
  @override
  @JsonKey(name: 'creator_name')
  final String? creatorName;
  @override
  @JsonKey(name: 'creator_avatar_url')
  final String? creatorAvatarUrl;
  @override
  @JsonKey(name: 'view_count')
  final int viewCount;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey(name: 'like_count')
  final int likeCount;
  @override
  @JsonKey(name: 'duration')
  final int? duration;

  @override
  String toString() {
    return 'SkillModel(id: $id, title: $title, description: $description, videoUrl: $videoUrl, thumbnailUrl: $thumbnailUrl, category: $category, creatorId: $creatorId, creatorName: $creatorName, creatorAvatarUrl: $creatorAvatarUrl, viewCount: $viewCount, createdAt: $createdAt, tags: $tags, likeCount: $likeCount, duration: $duration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SkillModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.videoUrl, videoUrl) ||
                other.videoUrl == videoUrl) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.creatorId, creatorId) ||
                other.creatorId == creatorId) &&
            (identical(other.creatorName, creatorName) ||
                other.creatorName == creatorName) &&
            (identical(other.creatorAvatarUrl, creatorAvatarUrl) ||
                other.creatorAvatarUrl == creatorAvatarUrl) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.duration, duration) ||
                other.duration == duration));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    title,
    description,
    videoUrl,
    thumbnailUrl,
    category,
    creatorId,
    creatorName,
    creatorAvatarUrl,
    viewCount,
    createdAt,
    const DeepCollectionEquality().hash(_tags),
    likeCount,
    duration,
  );

  /// Create a copy of SkillModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SkillModelImplCopyWith<_$SkillModelImpl> get copyWith =>
      __$$SkillModelImplCopyWithImpl<_$SkillModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SkillModelImplToJson(this);
  }
}

abstract class _SkillModel implements SkillModel {
  const factory _SkillModel({
    required final String id,
    required final String title,
    final String? description,
    @JsonKey(name: 'video_url') required final String videoUrl,
    @JsonKey(name: 'thumbnail_url') final String? thumbnailUrl,
    required final String category,
    @JsonKey(name: 'creator_id') final String? creatorId,
    @JsonKey(name: 'creator_name') final String? creatorName,
    @JsonKey(name: 'creator_avatar_url') final String? creatorAvatarUrl,
    @JsonKey(name: 'view_count') final int viewCount,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    final List<String> tags,
    @JsonKey(name: 'like_count') final int likeCount,
    @JsonKey(name: 'duration') final int? duration,
  }) = _$SkillModelImpl;

  factory _SkillModel.fromJson(Map<String, dynamic> json) =
      _$SkillModelImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String? get description;
  @override
  @JsonKey(name: 'video_url')
  String get videoUrl;
  @override
  @JsonKey(name: 'thumbnail_url')
  String? get thumbnailUrl;
  @override
  String get category;
  @override
  @JsonKey(name: 'creator_id')
  String? get creatorId;
  @override
  @JsonKey(name: 'creator_name')
  String? get creatorName;
  @override
  @JsonKey(name: 'creator_avatar_url')
  String? get creatorAvatarUrl;
  @override
  @JsonKey(name: 'view_count')
  int get viewCount;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  List<String> get tags;
  @override
  @JsonKey(name: 'like_count')
  int get likeCount;
  @override
  @JsonKey(name: 'duration')
  int? get duration;

  /// Create a copy of SkillModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SkillModelImplCopyWith<_$SkillModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
