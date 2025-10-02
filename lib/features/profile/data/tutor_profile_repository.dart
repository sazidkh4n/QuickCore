import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quickcore/features/feed/data/skill_model.dart';
import 'package:quickcore/features/profile/data/tutor_profile_model.dart';

class TutorProfileRepository {
  final _client = Supabase.instance.client;

  // Fetch all data needed for the tutor profile
  Future<TutorProfileModel> fetchTutorProfileData(String tutorId) async {
    // Run multiple queries concurrently for better performance
    final results = await Future.wait([
      _fetchTutorVideos(tutorId),
      _fetchTotalFollowers(tutorId),
      _fetchTotalViews(tutorId),
      _fetchTotalLikes(tutorId),
    ]);

    final List<SkillModel> videos = results[0] as List<SkillModel>;
    final int totalFollowers = results[1] as int;
    final int totalViews = results[2] as int;
    final int totalLikes = results[3] as int;
    final int totalUploads = videos.length;

    // Calculate earnings based on the requirements
    double viewsEarnings = (totalViews / 10000).floor() * 100.0;
    double followerBonus = 0.0;

    if (totalFollowers >= 1000000) {
      followerBonus = 100000.0;
    } else if (totalFollowers >= 100000) {
      followerBonus = 10000.0;
    } else if (totalFollowers >= 10000) {
      followerBonus = 1000.0;
    }

    double totalEarnings = viewsEarnings + followerBonus;

    // Calculate milestone progress
    Map<String, double> milestoneProgress = {
      '10k': totalFollowers / 10000.0,
      '100k': totalFollowers / 100000.0,
      '1M': totalFollowers / 1000000.0,
    };

    // Cap progress values at 1.0
    milestoneProgress = milestoneProgress.map((key, value) => 
      MapEntry(key, value > 1.0 ? 1.0 : value));

    return TutorProfileModel(
      totalFollowers: totalFollowers,
      totalViews: totalViews,
      totalLikes: totalLikes,
      totalUploads: totalUploads,
      videos: videos,
      totalEarnings: totalEarnings,
      viewsEarnings: viewsEarnings,
      followerBonus: followerBonus,
      milestoneProgress: milestoneProgress,
    );
  }

  // Fetch videos uploaded by the tutor
  Future<List<SkillModel>> _fetchTutorVideos(String tutorId) async {
    final res = await _client
        .from('skills')
        .select()
        .eq('creator_id', tutorId)
        .order('created_at', ascending: false);
    
    // Get like counts for all skills
    final videosWithLikes = await Future.wait((res as List).map((skill) async {
      final skillData = Map<String, dynamic>.from(skill);
      
      // Get like count for this skill
      final likeCount = await _client
          .from('likes')
          .select('user_id')
          .eq('skill_id', skillData['id'])
          .then((likes) => (likes as List).length);
      
      skillData['like_count'] = likeCount;
      
      return SkillModel.fromJson(skillData);
    }));
    
    return videosWithLikes;
  }

  // Fetch total followers count
  Future<int> _fetchTotalFollowers(String tutorId) async {
    // Fixed: Use proper method to count followers
    final res = await _client
        .from('follows')
        .select()
        .eq('followed_id', tutorId);
    
    return (res as List).length;
  }

  // Fetch total views across all videos
  Future<int> _fetchTotalViews(String tutorId) async {
    final res = await _client
        .from('skills')
        .select('view_count')
        .eq('creator_id', tutorId);
    
    int totalViews = 0;
    for (var video in res) {
      totalViews += (video['view_count'] as int? ?? 0);
    }
    
    return totalViews;
  }

  // Fetch total likes across all videos
  Future<int> _fetchTotalLikes(String tutorId) async {
    try {
      // Use the new function to get accurate total likes
      final result = await _client
          .rpc('get_total_likes_for_user', params: {'target_user_id': tutorId});
      
      return result as int? ?? 0;
    } catch (e) {
      print('Error fetching total likes for tutor $tutorId: $e');
      
      // Fallback to manual counting if RPC fails
      final res = await _client
          .from('skills')
          .select('id')
          .eq('creator_id', tutorId);
      
      int totalLikes = 0;
      for (var skill in res) {
        final likes = await _client
            .from('likes')
            .select('user_id')
            .eq('skill_id', skill['id']);
        totalLikes += (likes as List).length;
      }
      
      return totalLikes;
    }
  }
} 