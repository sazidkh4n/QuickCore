// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'like_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LikeModelImpl _$$LikeModelImplFromJson(Map<String, dynamic> json) =>
    _$LikeModelImpl(
      userId: json['user_id'] as String,
      skillId: json['skill_id'] as String,
      likedAt: json['liked_at'] == null
          ? null
          : DateTime.parse(json['liked_at'] as String),
    );

Map<String, dynamic> _$$LikeModelImplToJson(_$LikeModelImpl instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'skill_id': instance.skillId,
      'liked_at': instance.likedAt?.toIso8601String(),
    };
