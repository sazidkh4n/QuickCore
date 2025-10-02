// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'like_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LikeModel _$LikeModelFromJson(Map<String, dynamic> json) {
  return _LikeModel.fromJson(json);
}

/// @nodoc
mixin _$LikeModel {
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  @JsonKey(name: 'skill_id')
  String get skillId => throw _privateConstructorUsedError;
  @JsonKey(name: 'liked_at')
  DateTime? get likedAt => throw _privateConstructorUsedError;

  /// Serializes this LikeModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LikeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LikeModelCopyWith<LikeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LikeModelCopyWith<$Res> {
  factory $LikeModelCopyWith(LikeModel value, $Res Function(LikeModel) then) =
      _$LikeModelCopyWithImpl<$Res, LikeModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'skill_id') String skillId,
    @JsonKey(name: 'liked_at') DateTime? likedAt,
  });
}

/// @nodoc
class _$LikeModelCopyWithImpl<$Res, $Val extends LikeModel>
    implements $LikeModelCopyWith<$Res> {
  _$LikeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LikeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? skillId = null,
    Object? likedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            skillId: null == skillId
                ? _value.skillId
                : skillId // ignore: cast_nullable_to_non_nullable
                      as String,
            likedAt: freezed == likedAt
                ? _value.likedAt
                : likedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LikeModelImplCopyWith<$Res>
    implements $LikeModelCopyWith<$Res> {
  factory _$$LikeModelImplCopyWith(
    _$LikeModelImpl value,
    $Res Function(_$LikeModelImpl) then,
  ) = __$$LikeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'user_id') String userId,
    @JsonKey(name: 'skill_id') String skillId,
    @JsonKey(name: 'liked_at') DateTime? likedAt,
  });
}

/// @nodoc
class __$$LikeModelImplCopyWithImpl<$Res>
    extends _$LikeModelCopyWithImpl<$Res, _$LikeModelImpl>
    implements _$$LikeModelImplCopyWith<$Res> {
  __$$LikeModelImplCopyWithImpl(
    _$LikeModelImpl _value,
    $Res Function(_$LikeModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LikeModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? skillId = null,
    Object? likedAt = freezed,
  }) {
    return _then(
      _$LikeModelImpl(
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        skillId: null == skillId
            ? _value.skillId
            : skillId // ignore: cast_nullable_to_non_nullable
                  as String,
        likedAt: freezed == likedAt
            ? _value.likedAt
            : likedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LikeModelImpl implements _LikeModel {
  const _$LikeModelImpl({
    @JsonKey(name: 'user_id') required this.userId,
    @JsonKey(name: 'skill_id') required this.skillId,
    @JsonKey(name: 'liked_at') this.likedAt,
  });

  factory _$LikeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$LikeModelImplFromJson(json);

  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  @JsonKey(name: 'skill_id')
  final String skillId;
  @override
  @JsonKey(name: 'liked_at')
  final DateTime? likedAt;

  @override
  String toString() {
    return 'LikeModel(userId: $userId, skillId: $skillId, likedAt: $likedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LikeModelImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.skillId, skillId) || other.skillId == skillId) &&
            (identical(other.likedAt, likedAt) || other.likedAt == likedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, skillId, likedAt);

  /// Create a copy of LikeModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LikeModelImplCopyWith<_$LikeModelImpl> get copyWith =>
      __$$LikeModelImplCopyWithImpl<_$LikeModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LikeModelImplToJson(this);
  }
}

abstract class _LikeModel implements LikeModel {
  const factory _LikeModel({
    @JsonKey(name: 'user_id') required final String userId,
    @JsonKey(name: 'skill_id') required final String skillId,
    @JsonKey(name: 'liked_at') final DateTime? likedAt,
  }) = _$LikeModelImpl;

  factory _LikeModel.fromJson(Map<String, dynamic> json) =
      _$LikeModelImpl.fromJson;

  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  @JsonKey(name: 'skill_id')
  String get skillId;
  @override
  @JsonKey(name: 'liked_at')
  DateTime? get likedAt;

  /// Create a copy of LikeModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LikeModelImplCopyWith<_$LikeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
