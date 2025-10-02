// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skill_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SkillModelImpl _$$SkillModelImplFromJson(Map<String, dynamic> json) =>
    _$SkillModelImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      videoUrl: json['video_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      category: json['category'] as String,
      creatorId: json['creator_id'] as String?,
      creatorName: json['creator_name'] as String?,
      creatorAvatarUrl: json['creator_avatar_url'] as String?,
      viewCount: (json['view_count'] as num?)?.toInt() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const [],
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      duration: (json['duration'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$SkillModelImplToJson(_$SkillModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'video_url': instance.videoUrl,
      'thumbnail_url': instance.thumbnailUrl,
      'category': instance.category,
      'creator_id': instance.creatorId,
      'creator_name': instance.creatorName,
      'creator_avatar_url': instance.creatorAvatarUrl,
      'view_count': instance.viewCount,
      'created_at': instance.createdAt.toIso8601String(),
      'tags': instance.tags,
      'like_count': instance.likeCount,
      'duration': instance.duration,
    };
