// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FollowModelImpl _$$FollowModelImplFromJson(Map<String, dynamic> json) =>
    _$FollowModelImpl(
      followerId: json['follower_id'] as String,
      followedId: json['followed_id'] as String,
      followedAt: DateTime.parse(json['followed_at'] as String),
    );

Map<String, dynamic> _$$FollowModelImplToJson(_$FollowModelImpl instance) =>
    <String, dynamic>{
      'follower_id': instance.followerId,
      'followed_id': instance.followedId,
      'followed_at': instance.followedAt.toIso8601String(),
    };
