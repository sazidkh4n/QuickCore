import 'package:freezed_annotation/freezed_annotation.dart';

part 'follow_model.freezed.dart';
part 'follow_model.g.dart';

@freezed
class FollowModel with _$FollowModel {
  const factory FollowModel({
    @JsonKey(name: 'follower_id') required String followerId,
    @JsonKey(name: 'followed_id') required String followedId,
    @JsonKey(name: 'followed_at') required DateTime followedAt,
  }) = _FollowModel;

  factory FollowModel.fromJson(Map<String, dynamic> json) => _$FollowModelFromJson(json);
} 