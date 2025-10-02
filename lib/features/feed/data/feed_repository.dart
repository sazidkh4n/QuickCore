import 'package:supabase_flutter/supabase_flutter.dart';
import '../../social/data/social_repository.dart';
import 'skill_model.dart';
import 'dart:developer' as dev;

class FeedRepository {
  final _client = Supabase.instance.client;
  final _socialRepository = SocialRepository();

  Future<List<SkillModel>> fetchFeed() async {
    try {
      final res = await _client
          .from('skills')
          .select('*, users:creator_id(name, avatar_url)')
          .order('created_at', ascending: false);
      
      // Get like counts for all skills
      final skillsWithLikes = await Future.wait((res as List).map((skill) async {
        final skillData = Map<String, dynamic>.from(skill);
        
        // Get like count for this skill
        final likeCount = await _client
            .from('likes')
            .select('user_id')
            .eq('skill_id', skillData['id'])
            .then((likes) => (likes as List).length);
        
        skillData['like_count'] = likeCount;
        
        // Extract user info and add it to the skill
        final userData = skillData['users'] as Map<String, dynamic>?;
        
        // Add creator name and avatar if available
        if (userData != null) {
          skillData['creator_name'] = userData['name'];
          skillData['creator_avatar_url'] = userData['avatar_url'];
        }
        
        // Ensure thumbnail URL is set
        if (skillData['thumbnail_url'] == null || skillData['thumbnail_url'] == '') {
          // Use a default thumbnail if none is available
          skillData['thumbnail_url'] = 'https://via.placeholder.com/400x225?text=Video+Thumbnail';
        }
        
        return SkillModel.fromJson(skillData);
      }));
      
      return skillsWithLikes;
    } catch (e) {
      dev.log('Error fetching feed: $e');
      return [];
    }
  }
  
  Future<List<SkillModel>> fetchRandomFeed() async {
    try {
      dev.log('Fetching random feed');
      // Try to fetch random videos from the database with user info
      final res = await _client
          .from('skills')
          .select('*, users:creator_id(name, avatar_url)')
          .limit(20);
      
      // Get like counts for all skills
      final skillsWithLikes = await Future.wait((res as List).map((skill) async {
        final skillData = Map<String, dynamic>.from(skill);
        
        // Get like count for this skill
        final likeCount = await _client
            .from('likes')
            .select('user_id')
            .eq('skill_id', skillData['id'])
            .then((likes) => (likes as List).length);
        
        skillData['like_count'] = likeCount;
        
        // Extract user info and add it to the skill
        final userData = skillData['users'] as Map<String, dynamic>?;
        
        // Add creator name and avatar if available
        if (userData != null) {
          skillData['creator_name'] = userData['name'];
          skillData['creator_avatar_url'] = userData['avatar_url'];
        }
        
        // Ensure thumbnail URL is set
        if (skillData['thumbnail_url'] == null || skillData['thumbnail_url'] == '') {
          // Use a default thumbnail if none is available
          skillData['thumbnail_url'] = 'https://via.placeholder.com/400x225?text=Video+Thumbnail';
        }
        
        return SkillModel.fromJson(skillData);
      }));
      
      // Shuffle the results to randomize the order
      skillsWithLikes.shuffle();
      
      dev.log('Fetched ${skillsWithLikes.length} random videos');
      return skillsWithLikes;
    } catch (e) {
      dev.log('Error fetching random feed: $e');
      
      // Fallback to regular feed if there's an error
      final regularFeed = await fetchFeed();
      regularFeed.shuffle();
      return regularFeed;
    }
  }

  Future<List<SkillModel>> fetchFollowingFeed(String userId) async {
    try {
      final followingIds = await _socialRepository.getFollowing(userId);
      if (followingIds.isEmpty) {
        return [];
      }
      final res = await _client
          .from('skills')
          .select('*, users:creator_id(name, avatar_url)')
          .filter('creator_id', 'in', '(${followingIds.join(',')})')
          .order('created_at', ascending: false);
      
      return (res as List).map((e) {
        // Extract user info and add it to the skill
        final userData = e['users'] as Map<String, dynamic>?;
        final skillData = Map<String, dynamic>.from(e);
        
        // Add creator name and avatar if available
        if (userData != null) {
          skillData['creator_name'] = userData['name'];
          skillData['creator_avatar_url'] = userData['avatar_url'];
        }
        
        // Ensure thumbnail URL is set
        if (skillData['thumbnail_url'] == null || skillData['thumbnail_url'] == '') {
          // Use a default thumbnail if none is available
          skillData['thumbnail_url'] = 'https://via.placeholder.com/400x225?text=Video+Thumbnail';
        }
        
        return SkillModel.fromJson(skillData);
      }).toList();
    } catch (e) {
      dev.log('Error fetching following feed: $e');
      return [];
    }
  }
  
  Future<List<SkillModel>> fetchRandomFollowingFeed(String userId) async {
    try {
      final followingIds = await _socialRepository.getFollowing(userId);
      if (followingIds.isEmpty) {
        return [];
      }
      
      final res = await _client
          .from('skills')
          .select('*, users:creator_id(name, avatar_url)')
          .filter('creator_id', 'in', '(${followingIds.join(',')})')
          .limit(20);
          
      final skills = (res as List).map((e) {
        // Extract user info and add it to the skill
        final userData = e['users'] as Map<String, dynamic>?;
        final skillData = Map<String, dynamic>.from(e);
        
        // Add creator name and avatar if available
        if (userData != null) {
          skillData['creator_name'] = userData['name'];
          skillData['creator_avatar_url'] = userData['avatar_url'];
        }
        
        // Ensure thumbnail URL is set
        if (skillData['thumbnail_url'] == null || skillData['thumbnail_url'] == '') {
          // Use a default thumbnail if none is available
          skillData['thumbnail_url'] = 'https://via.placeholder.com/400x225?text=Video+Thumbnail';
        }
        
        return SkillModel.fromJson(skillData);
      }).toList();
      
      // Shuffle the results
      skills.shuffle();
      return skills;
    } catch (e) {
      dev.log('Error fetching random following feed: $e');
      
      // Fallback to regular following feed
      final regularFeed = await fetchFollowingFeed(userId);
      regularFeed.shuffle();
      return regularFeed;
    }
  }

  Future<void> incrementViewCount(String skillId) async {
    try {
      // First try to use the edge function
      await _client.functions.invoke('increment_view_count', body: {
        'skill_id': skillId,
      });
    } catch (e) {
      dev.log('Error using edge function to increment view: $e');
      
      // Fallback to direct update
      try {
        final skill = await _client
            .from('skills')
            .select('view_count')
            .eq('id', skillId)
            .single();
        
        final currentCount = skill['view_count'] as int? ?? 0;
        
        await _client
            .from('skills')
            .update({'view_count': currentCount + 1})
            .eq('id', skillId);
      } catch (e2) {
        dev.log('Error incrementing view count directly: $e2');
      }
    }
  }
}
