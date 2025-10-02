// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tutor_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TutorProfileModelImpl _$$TutorProfileModelImplFromJson(
  Map<String, dynamic> json,
) => _$TutorProfileModelImpl(
  totalFollowers: (json['totalFollowers'] as num).toInt(),
  totalViews: (json['totalViews'] as num).toInt(),
  totalLikes: (json['totalLikes'] as num).toInt(),
  totalUploads: (json['totalUploads'] as num).toInt(),
  videos: (json['videos'] as List<dynamic>)
      .map((e) => SkillModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalEarnings: (json['totalEarnings'] as num).toDouble(),
  viewsEarnings: (json['viewsEarnings'] as num).toDouble(),
  followerBonus: (json['followerBonus'] as num).toDouble(),
  milestoneProgress:
      (json['milestoneProgress'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, (e as num).toDouble()),
      ) ??
      const {},
);

Map<String, dynamic> _$$TutorProfileModelImplToJson(
  _$TutorProfileModelImpl instance,
) => <String, dynamic>{
  'totalFollowers': instance.totalFollowers,
  'totalViews': instance.totalViews,
  'totalLikes': instance.totalLikes,
  'totalUploads': instance.totalUploads,
  'videos': instance.videos,
  'totalEarnings': instance.totalEarnings,
  'viewsEarnings': instance.viewsEarnings,
  'followerBonus': instance.followerBonus,
  'milestoneProgress': instance.milestoneProgress,
};
