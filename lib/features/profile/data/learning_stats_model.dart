import 'package:freezed_annotation/freezed_annotation.dart';

part 'learning_stats_model.freezed.dart';
part 'learning_stats_model.g.dart';

@freezed
class LearningStats with _$LearningStats {
  const factory LearningStats({
    @Default(0) int skillsViewed,
    @Default(0) int minutesLearned,
    @Default(0) int learningStreak,
    @Default([]) List<String> interests,
    @Default({}) Map<String, bool> achievements,
  }) = _LearningStats;

  factory LearningStats.fromJson(Map<String, dynamic> json) => _$LearningStatsFromJson(json);
} 