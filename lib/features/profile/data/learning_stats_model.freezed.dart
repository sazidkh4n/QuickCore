// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'learning_stats_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LearningStats _$LearningStatsFromJson(Map<String, dynamic> json) {
  return _LearningStats.fromJson(json);
}

/// @nodoc
mixin _$LearningStats {
  int get skillsViewed => throw _privateConstructorUsedError;
  int get minutesLearned => throw _privateConstructorUsedError;
  int get learningStreak => throw _privateConstructorUsedError;
  List<String> get interests => throw _privateConstructorUsedError;
  Map<String, bool> get achievements => throw _privateConstructorUsedError;

  /// Serializes this LearningStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LearningStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LearningStatsCopyWith<LearningStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LearningStatsCopyWith<$Res> {
  factory $LearningStatsCopyWith(
    LearningStats value,
    $Res Function(LearningStats) then,
  ) = _$LearningStatsCopyWithImpl<$Res, LearningStats>;
  @useResult
  $Res call({
    int skillsViewed,
    int minutesLearned,
    int learningStreak,
    List<String> interests,
    Map<String, bool> achievements,
  });
}

/// @nodoc
class _$LearningStatsCopyWithImpl<$Res, $Val extends LearningStats>
    implements $LearningStatsCopyWith<$Res> {
  _$LearningStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LearningStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? skillsViewed = null,
    Object? minutesLearned = null,
    Object? learningStreak = null,
    Object? interests = null,
    Object? achievements = null,
  }) {
    return _then(
      _value.copyWith(
            skillsViewed: null == skillsViewed
                ? _value.skillsViewed
                : skillsViewed // ignore: cast_nullable_to_non_nullable
                      as int,
            minutesLearned: null == minutesLearned
                ? _value.minutesLearned
                : minutesLearned // ignore: cast_nullable_to_non_nullable
                      as int,
            learningStreak: null == learningStreak
                ? _value.learningStreak
                : learningStreak // ignore: cast_nullable_to_non_nullable
                      as int,
            interests: null == interests
                ? _value.interests
                : interests // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            achievements: null == achievements
                ? _value.achievements
                : achievements // ignore: cast_nullable_to_non_nullable
                      as Map<String, bool>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LearningStatsImplCopyWith<$Res>
    implements $LearningStatsCopyWith<$Res> {
  factory _$$LearningStatsImplCopyWith(
    _$LearningStatsImpl value,
    $Res Function(_$LearningStatsImpl) then,
  ) = __$$LearningStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int skillsViewed,
    int minutesLearned,
    int learningStreak,
    List<String> interests,
    Map<String, bool> achievements,
  });
}

/// @nodoc
class __$$LearningStatsImplCopyWithImpl<$Res>
    extends _$LearningStatsCopyWithImpl<$Res, _$LearningStatsImpl>
    implements _$$LearningStatsImplCopyWith<$Res> {
  __$$LearningStatsImplCopyWithImpl(
    _$LearningStatsImpl _value,
    $Res Function(_$LearningStatsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LearningStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? skillsViewed = null,
    Object? minutesLearned = null,
    Object? learningStreak = null,
    Object? interests = null,
    Object? achievements = null,
  }) {
    return _then(
      _$LearningStatsImpl(
        skillsViewed: null == skillsViewed
            ? _value.skillsViewed
            : skillsViewed // ignore: cast_nullable_to_non_nullable
                  as int,
        minutesLearned: null == minutesLearned
            ? _value.minutesLearned
            : minutesLearned // ignore: cast_nullable_to_non_nullable
                  as int,
        learningStreak: null == learningStreak
            ? _value.learningStreak
            : learningStreak // ignore: cast_nullable_to_non_nullable
                  as int,
        interests: null == interests
            ? _value._interests
            : interests // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        achievements: null == achievements
            ? _value._achievements
            : achievements // ignore: cast_nullable_to_non_nullable
                  as Map<String, bool>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LearningStatsImpl implements _LearningStats {
  const _$LearningStatsImpl({
    this.skillsViewed = 0,
    this.minutesLearned = 0,
    this.learningStreak = 0,
    final List<String> interests = const [],
    final Map<String, bool> achievements = const {},
  }) : _interests = interests,
       _achievements = achievements;

  factory _$LearningStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$LearningStatsImplFromJson(json);

  @override
  @JsonKey()
  final int skillsViewed;
  @override
  @JsonKey()
  final int minutesLearned;
  @override
  @JsonKey()
  final int learningStreak;
  final List<String> _interests;
  @override
  @JsonKey()
  List<String> get interests {
    if (_interests is EqualUnmodifiableListView) return _interests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_interests);
  }

  final Map<String, bool> _achievements;
  @override
  @JsonKey()
  Map<String, bool> get achievements {
    if (_achievements is EqualUnmodifiableMapView) return _achievements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_achievements);
  }

  @override
  String toString() {
    return 'LearningStats(skillsViewed: $skillsViewed, minutesLearned: $minutesLearned, learningStreak: $learningStreak, interests: $interests, achievements: $achievements)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LearningStatsImpl &&
            (identical(other.skillsViewed, skillsViewed) ||
                other.skillsViewed == skillsViewed) &&
            (identical(other.minutesLearned, minutesLearned) ||
                other.minutesLearned == minutesLearned) &&
            (identical(other.learningStreak, learningStreak) ||
                other.learningStreak == learningStreak) &&
            const DeepCollectionEquality().equals(
              other._interests,
              _interests,
            ) &&
            const DeepCollectionEquality().equals(
              other._achievements,
              _achievements,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    skillsViewed,
    minutesLearned,
    learningStreak,
    const DeepCollectionEquality().hash(_interests),
    const DeepCollectionEquality().hash(_achievements),
  );

  /// Create a copy of LearningStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LearningStatsImplCopyWith<_$LearningStatsImpl> get copyWith =>
      __$$LearningStatsImplCopyWithImpl<_$LearningStatsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LearningStatsImplToJson(this);
  }
}

abstract class _LearningStats implements LearningStats {
  const factory _LearningStats({
    final int skillsViewed,
    final int minutesLearned,
    final int learningStreak,
    final List<String> interests,
    final Map<String, bool> achievements,
  }) = _$LearningStatsImpl;

  factory _LearningStats.fromJson(Map<String, dynamic> json) =
      _$LearningStatsImpl.fromJson;

  @override
  int get skillsViewed;
  @override
  int get minutesLearned;
  @override
  int get learningStreak;
  @override
  List<String> get interests;
  @override
  Map<String, bool> get achievements;

  /// Create a copy of LearningStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LearningStatsImplCopyWith<_$LearningStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
