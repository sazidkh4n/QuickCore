import 'package:supabase_flutter/supabase_flutter.dart';
import 'skill_model.dart';
import 'dart:developer' as dev;

class SkillRepository {
  final _client = Supabase.instance.client;

  Future<SkillModel> getSkill(String id) async {
    try {
      final res = await _client
          .from('skills')
          .select('*, users:creator_id(name, avatar_url)')
          .eq('id', id)
          .single();
      
      // Extract user info and add it to the skill
      final userData = res['users'] as Map<String, dynamic>?;
      final skillData = Map<String, dynamic>.from(res);
      
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
    } catch (e) {
      dev.log('Error fetching skill: $e');
      rethrow;
    }
  }
  
  // New method to get a skill by ID
  Future<SkillModel?> getSkillById(String id) async {
    try {
      dev.log('Fetching skill with ID: $id from database');
      final res = await _client
          .from('skills')
          .select('*, users:creator_id(name, avatar_url)')
          .eq('id', id)
          .maybeSingle();
      
      if (res == null) {
        dev.log('Skill with ID: $id not found in database');
        throw Exception('Skill not found');
      }
      
      // Extract user info and add it to the skill
      final userData = res['users'] as Map<String, dynamic>?;
      final skillData = Map<String, dynamic>.from(res);
      
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
    } catch (e) {
      dev.log('Error fetching skill from database: $e');
      
      // For demo/development, try to find the skill in the demo data
      try {
        dev.log('Trying to find skill in demo data');
        final demoSkills = await fetchFeed();
        final skill = demoSkills.firstWhere(
          (skill) => skill.id == id,
          orElse: () => throw Exception('Skill not found in demo data'),
        );
        return skill;
      } catch (innerError) {
        dev.log('Failed to find skill in demo data: $innerError');
        // Rethrow the original error
        throw Exception('Skill not found: $e');
      }
    }
  }

  Future<List<SkillModel>> fetchSkillsByCategory(String category) async {
    try {
      final res = await _client
          .from('skills')
          .select('*, users:creator_id(name, avatar_url)')
          .eq('category', category)
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
      dev.log('Error fetching skills by category: $e');
      return [];
    }
  }

  Future<List<SkillModel>> fetchSkillsByCreator(String creatorId) async {
    try {
      final res = await _client
          .from('skills')
          .select('*, users:creator_id(name, avatar_url)')
          .eq('creator_id', creatorId)
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
      dev.log('Error fetching skills by creator: $e');
      return [];
    }
  }

  Future<List<SkillModel>> searchSkills(String query) async {
    try {
      final res = await _client
          .from('skills')
          .select('*, users:creator_id(name, avatar_url)')
          .textSearch('title', query, config: 'english')
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
      dev.log('Error searching skills: $e');
      return [];
    }
  }

  Future<List<String>> getCategories() async {
    final res = await _client.from('skills').select('category');
    final categories = (res as List)
        .map<String>((e) => e['category'] as String)
        .toSet()
        .toList();
    return categories;
  }

  Future<List<SkillModel>> fetchFeed() async {
    // Return more demo data (same as FeedRepository for demo)
    return [
      SkillModel(
        id: '1',
        title: 'Learn Flutter',
        category: 'Coding',
        videoUrl: 'https://samplelib.com/mp4/sample-5s.mp4',
        creatorId: 'demo_user',
        viewCount: 123,
        createdAt: DateTime(2024, 1, 1),
        thumbnailUrl: 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=400&q=80',
        description: 'A quick intro to Flutter.',
      ),
      SkillModel(
        id: '2',
        title: 'Design Basics',
        category: 'Design',
        videoUrl: 'https://samplelib.com/mp4/sample-5s.mp4',
        creatorId: 'jane',
        viewCount: 45,
        createdAt: DateTime(2024, 1, 2),
        thumbnailUrl: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
        description: 'Learn design fundamentals.',
      ),
      SkillModel(
        id: '3',
        title: 'Finance 101',
        category: 'Finance',
        videoUrl: 'https://samplelib.com/mp4/sample-5s.mp4',
        creatorId: 'alex',
        viewCount: 67,
        createdAt: DateTime(2024, 1, 3),
        thumbnailUrl: 'https://images.unsplash.com/photo-1461749280684-dccba630e2f6?auto=format&fit=crop&w=400&q=80',
        description: 'Basics of personal finance.',
      ),
      SkillModel(
        id: '4',
        title: 'Marketing Hacks',
        category: 'Marketing',
        videoUrl: 'https://samplelib.com/mp4/sample-5s.mp4',
        creatorId: 'sara',
        viewCount: 89,
        createdAt: DateTime(2024, 1, 4),
        thumbnailUrl: 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=400&q=80',
        description: 'Quick marketing tips.',
      ),
      SkillModel(
        id: '5',
        title: 'Productivity Boost',
        category: 'Productivity',
        videoUrl: 'https://samplelib.com/mp4/sample-5s.mp4',
        creatorId: 'chris',
        viewCount: 101,
        createdAt: DateTime(2024, 1, 5),
        thumbnailUrl: 'https://images.unsplash.com/photo-1465101178521-c1a9136a3b99?auto=format&fit=crop&w=400&q=80',
        description: 'Boost your productivity.',
      ),
      SkillModel(
        id: '6',
        title: 'Other Skills',
        category: 'Other',
        videoUrl: 'https://samplelib.com/mp4/sample-5s.mp4',
        creatorId: 'pat',
        viewCount: 33,
        createdAt: DateTime(2024, 1, 6),
        thumbnailUrl: 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=400&q=80',
        description: 'Miscellaneous skills.',
      ),
    ];
  }

  Future<void> incrementViewCount(String skillId) async {
    // No-op for demo
  }
} 