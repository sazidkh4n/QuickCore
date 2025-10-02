// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'learning_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LearningStatsImpl _$$LearningStatsImplFromJson(Map<String, dynamic> json) =>
    _$LearningStatsImpl(
      skillsViewed: (json['skillsViewed'] as num?)?.toInt() ?? 0,
      minutesLearned: (json['minutesLearned'] as num?)?.toInt() ?? 0,
      learningStreak: (json['learningStreak'] as num?)?.toInt() ?? 0,
      interests:
          (json['interests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      achievements:
          (json['achievements'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as bool),
          ) ??
          const {},
    );

Map<String, dynamic> _$$LearningStatsImplToJson(_$LearningStatsImpl instance) =>
    <String, dynamic>{
      'skillsViewed': instance.skillsViewed,
      'minutesLearned': instance.minutesLearned,
      'learningStreak': instance.learningStreak,
      'interests': instance.interests,
      'achievements': instance.achievements,
    };
