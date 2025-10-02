import 'package:freezed_annotation/freezed_annotation.dart';

part 'skill_model.freezed.dart';
part 'skill_model.g.dart';

@freezed
class SkillModel with _$SkillModel {
  const factory SkillModel({
    required String id,
    required String title,
    String? description,
    @JsonKey(name: 'video_url') required String videoUrl,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    required String category,
    @JsonKey(name: 'creator_id') String? creatorId,
    @JsonKey(name: 'creator_name') String? creatorName,
    @JsonKey(name: 'creator_avatar_url') String? creatorAvatarUrl,
    @JsonKey(name: 'view_count') @Default(0) int viewCount,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @Default([]) List<String> tags,
    @JsonKey(name: 'like_count') @Default(0) int likeCount,
    @JsonKey(name: 'duration') int? duration,
  }) = _SkillModel;

  factory SkillModel.fromJson(Map<String, dynamic> json) =>
      _$SkillModelFromJson(json);
}
