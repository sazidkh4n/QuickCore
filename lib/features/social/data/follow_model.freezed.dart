// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'follow_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FollowModel _$FollowModelFromJson(Map<String, dynamic> json) {
  return _FollowModel.fromJson(json);
}

/// @nodoc
mixin _$FollowModel {
  @JsonKey(name: 'follower_id')
  String get followerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'followed_id')
  String get followedId => throw _privateConstructorUsedError;
  @JsonKey(name: 'followed_at')
  DateTime get followedAt => throw _privateConstructorUsedError;

  /// Serializes this FollowModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FollowModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FollowModelCopyWith<FollowModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FollowModelCopyWith<$Res> {
  factory $FollowModelCopyWith(
    FollowModel value,
    $Res Function(FollowModel) then,
  ) = _$FollowModelCopyWithImpl<$Res, FollowModel>;
  @useResult
  $Res call({
    @JsonKey(name: 'follower_id') String followerId,
    @JsonKey(name: 'followed_id') String followedId,
    @JsonKey(name: 'followed_at') DateTime followedAt,
  });
}

/// @nodoc
class _$FollowModelCopyWithImpl<$Res, $Val extends FollowModel>
    implements $FollowModelCopyWith<$Res> {
  _$FollowModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FollowModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? followerId = null,
    Object? followedId = null,
    Object? followedAt = null,
  }) {
    return _then(
      _value.copyWith(
            followerId: null == followerId
                ? _value.followerId
                : followerId // ignore: cast_nullable_to_non_nullable
                      as String,
            followedId: null == followedId
                ? _value.followedId
                : followedId // ignore: cast_nullable_to_non_nullable
                      as String,
            followedAt: null == followedAt
                ? _value.followedAt
                : followedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FollowModelImplCopyWith<$Res>
    implements $FollowModelCopyWith<$Res> {
  factory _$$FollowModelImplCopyWith(
    _$FollowModelImpl value,
    $Res Function(_$FollowModelImpl) then,
  ) = __$$FollowModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'follower_id') String followerId,
    @JsonKey(name: 'followed_id') String followedId,
    @JsonKey(name: 'followed_at') DateTime followedAt,
  });
}

/// @nodoc
class __$$FollowModelImplCopyWithImpl<$Res>
    extends _$FollowModelCopyWithImpl<$Res, _$FollowModelImpl>
    implements _$$FollowModelImplCopyWith<$Res> {
  __$$FollowModelImplCopyWithImpl(
    _$FollowModelImpl _value,
    $Res Function(_$FollowModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FollowModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? followerId = null,
    Object? followedId = null,
    Object? followedAt = null,
  }) {
    return _then(
      _$FollowModelImpl(
        followerId: null == followerId
            ? _value.followerId
            : followerId // ignore: cast_nullable_to_non_nullable
                  as String,
        followedId: null == followedId
            ? _value.followedId
            : followedId // ignore: cast_nullable_to_non_nullable
                  as String,
        followedAt: null == followedAt
            ? _value.followedAt
            : followedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FollowModelImpl implements _FollowModel {
  const _$FollowModelImpl({
    @JsonKey(name: 'follower_id') required this.followerId,
    @JsonKey(name: 'followed_id') required this.followedId,
    @JsonKey(name: 'followed_at') required this.followedAt,
  });

  factory _$FollowModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FollowModelImplFromJson(json);

  @override
  @JsonKey(name: 'follower_id')
  final String followerId;
  @override
  @JsonKey(name: 'followed_id')
  final String followedId;
  @override
  @JsonKey(name: 'followed_at')
  final DateTime followedAt;

  @override
  String toString() {
    return 'FollowModel(followerId: $followerId, followedId: $followedId, followedAt: $followedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FollowModelImpl &&
            (identical(other.followerId, followerId) ||
                other.followerId == followerId) &&
            (identical(other.followedId, followedId) ||
                other.followedId == followedId) &&
            (identical(other.followedAt, followedAt) ||
                other.followedAt == followedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, followerId, followedId, followedAt);

  /// Create a copy of FollowModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FollowModelImplCopyWith<_$FollowModelImpl> get copyWith =>
      __$$FollowModelImplCopyWithImpl<_$FollowModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FollowModelImplToJson(this);
  }
}

abstract class _FollowModel implements FollowModel {
  const factory _FollowModel({
    @JsonKey(name: 'follower_id') required final String followerId,
    @JsonKey(name: 'followed_id') required final String followedId,
    @JsonKey(name: 'followed_at') required final DateTime followedAt,
  }) = _$FollowModelImpl;

  factory _FollowModel.fromJson(Map<String, dynamic> json) =
      _$FollowModelImpl.fromJson;

  @override
  @JsonKey(name: 'follower_id')
  String get followerId;
  @override
  @JsonKey(name: 'followed_id')
  String get followedId;
  @override
  @JsonKey(name: 'followed_at')
  DateTime get followedAt;

  /// Create a copy of FollowModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FollowModelImplCopyWith<_$FollowModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
