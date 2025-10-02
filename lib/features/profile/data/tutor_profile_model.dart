import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:quickcore/features/feed/data/skill_model.dart';

part 'tutor_profile_model.freezed.dart';
part 'tutor_profile_model.g.dart';

@freezed
class TutorProfileModel with _$TutorProfileModel {
  const factory TutorProfileModel({
    required int totalFollowers,
    required int totalViews,
    required int totalLikes,
    required int totalUploads,
    required List<SkillModel> videos,
    required double totalEarnings,
    required double viewsEarnings,
    required double followerBonus,
    @Default({}) Map<String, double> milestoneProgress,
  }) = _TutorProfileModel;

  factory TutorProfileModel.fromJson(Map<String, dynamic> json) =>
      _$TutorProfileModelFromJson(json);
} 