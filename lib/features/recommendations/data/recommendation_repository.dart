import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quickcore/features/feed/data/skill_model.dart';
import 'package:quickcore/features/auth/data/user_model.dart';
import 'dart:developer' as dev;

class RecommendationRepository {
  final _client = Supabase.instance.client;

  /// Fetch personalized recommendations based on user interests and watch history
  Future<List<SkillModel>> getPersonalizedRecommendations(String userId) async {
    try {
      dev.log('Fetching personalized recommendations for user: $userId');
      
      // Get user interests
      final interestsRes = await _client
          .from('user_interests')
          .select('category')
          .eq('user_id', userId);
      
      final interests = (interestsRes as List)
          .map((e) => e['category'] as String)
          .toList();
      
      // If no interests, return empty list
      if (interests.isEmpty) {
        dev.log('No interests found for user: $userId');
        return [];
      }
      
      dev.log('User interests: $interests');
      
      // Get skills matching user interests
      final res = await _client
          .from('skills')
          .select()
          .filter('category', 'in', '(${interests.map((e) => "'$e'").join(',')})')
          .order('created_at', ascending: false)
          .limit(20);
      
      final skills = (res as List)
          .map((e) => SkillModel.fromJson(e))
          .toList();
      
      dev.log('Found ${skills.length} personalized recommendations');
      return skills;
    } catch (e) {
      dev.log('Error fetching personalized recommendations: $e');
      return [];
    }
  }

  /// Fetch trending content based on view counts and likes
  Future<List<SkillModel>> getTrendingContent() async {
    try {
      dev.log('Fetching trending content');
      
      // Get skills with highest view counts in the last 7 days
      final res = await _client.rpc('get_trending_skills', params: {
        'days_ago': 7,
        'limit_count': 20
      });
      
      final skills = (res as List)
          .map((e) => SkillModel.fromJson(e))
          .toList();
      
      dev.log('Found ${skills.length} trending skills');
      return skills;
    } catch (e) {
      dev.log('Error fetching trending content: $e');
      
      // Fallback to simple query if RPC fails
      try {
        final res = await _client
            .from('skills')
            .select()
            .order('view_count', ascending: false)
            .limit(20);
        
        return (res as List)
            .map((e) => SkillModel.fromJson(e))
            .toList();
      } catch (e2) {
        dev.log('Fallback query also failed: $e2');
        return [];
      }
    }
  }

  /// Fetch content by specific topic/category
  Future<List<SkillModel>> getContentByTopic(String topic) async {
    try {
      dev.log('Fetching content for topic: $topic');
      
      final res = await _client
          .from('skills')
          .select()
          .eq('category', topic)
          .order('created_at', ascending: false)
          .limit(20);
      
      final skills = (res as List)
          .map((e) => SkillModel.fromJson(e))
          .toList();
      
      dev.log('Found ${skills.length} skills for topic: $topic');
      return skills;
    } catch (e) {
      dev.log('Error fetching content by topic: $e');
      return [];
    }
  }

  /// Get popular topics based on content volume and engagement
  Future<List<Map<String, dynamic>>> getPopularTopics() async {
    try {
      dev.log('Fetching popular topics');
      
      // Get categories with counts and average engagement
      final res = await _client.rpc('get_popular_topics', params: {
        'limit_count': 10
      });
      
      dev.log('Found ${(res as List).length} popular topics');
      return res.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      dev.log('Error fetching popular topics: $e');
      
      // Fallback to simple aggregation
      try {
        final res = await _client
            .from('skills')
            .select('category, count(*)')
            .not('category', 'is', null)
            .order('count', ascending: false)
            .limit(10);
        
        return (res as List).map((e) => {
          'category': e['category'],
          'count': e['count'],
          'engagement_score': 0.0
        }).toList();
      } catch (e2) {
        dev.log('Fallback query also failed: $e2');
        return [];
      }
    }
  }

  /// Get recommended creators to follow based on user interests
  Future<List<UserModel>> getRecommendedCreators(String userId) async {
    try {
      dev.log('Fetching recommended creators for user: $userId');
      
      // Get creators who create content in user's interest categories
      final res = await _client.rpc('get_recommended_creators', params: {
        'user_id_param': userId,
        'limit_count': 5
      });
      
      final creators = (res as List)
          .map((e) => UserModel.fromJson(e))
          .toList();
      
      dev.log('Found ${creators.length} recommended creators');
      return creators;
    } catch (e) {
      dev.log('Error fetching recommended creators: $e');
      
      // Fallback to simple query for top creators
      try {
        final res = await _client.rpc('get_top_creators', params: {
          'limit_count': 5
        });
        
        return (res as List)
            .map((e) => UserModel.fromJson(e))
            .toList();
      } catch (e2) {
        dev.log('Fallback query also failed: $e2');
        return [];
      }
    }
  }
} 