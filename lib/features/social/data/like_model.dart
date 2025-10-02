import 'package:freezed_annotation/freezed_annotation.dart';

part 'like_model.freezed.dart';
part 'like_model.g.dart';

@freezed
class LikeModel with _$LikeModel {
  const factory LikeModel({
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'skill_id') required String skillId,
    @JsonKey(name: 'liked_at') DateTime? likedAt,
  }) = _LikeModel;

  factory LikeModel.fromJson(Map<String, dynamic> json) => _$LikeModelFromJson(json);
} 