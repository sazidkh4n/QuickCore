import 'package:supabase_flutter/supabase_flutter.dart';
import 'comment_model.dart';

class SocialRepository {
  final _client = Supabase.instance.client;

  Future<void> likeSkill(String userId, String skillId) async {
    await _client.from('likes').insert({'user_id': userId, 'skill_id': skillId});
  }

  Future<void> unlikeSkill(String userId, String skillId) async {
    await _client
        .from('likes')
        .delete()
        .match({'user_id': userId, 'skill_id': skillId});
  }

  Future<int> getLikeCount(String skillId) async {
    final res = await _client
        .from('likes')
        .select('user_id')
        .eq('skill_id', skillId);
    return (res as List).length;
  }

  Future<bool> isLiked(String userId, String skillId) async {
    final res = await _client
        .from('likes')
        .select()
        .match({'user_id': userId, 'skill_id': skillId})
        .maybeSingle();
    return res != null;
  }

  Future<int> getLikesCount(String skillId) async {
    final res = await _client.from('likes').select('skill_id').eq('skill_id', skillId);
    return (res as List).length;
  }

  Future<List<CommentModel>> getComments(String skillId) async {
    final res = await _client
        .from('comments')
        .select()
        .eq('skill_id', skillId)
        .filter('parent_comment_id', 'is', 'null') // Only fetch top-level comments
        .order('created_at', ascending: false);
    return res.map((json) => CommentModel.fromJson(json)).toList();
  }

  Future<List<CommentModel>> getReplies(String commentId) async {
    final res = await _client
        .from('comments')
        .select()
        .eq('parent_comment_id', commentId)
        .order('created_at', ascending: true);
    return res.map((json) => CommentModel.fromJson(json)).toList();
  }

  Future<void> addComment(CommentModel comment) async {
    await _client.from('comments').insert(comment.toJson());
  }

  Future<void> likeComment(String userId, String commentId) async {
    await _client
        .from('comment_likes')
        .insert({'user_id': userId, 'comment_id': commentId});
  }

  Future<void> unlikeComment(String userId, String commentId) async {
    await _client
        .from('comment_likes')
        .delete()
        .match({'user_id': userId, 'comment_id': commentId});
  }

  Future<bool> isCommentLiked(String userId, String commentId) async {
    final res = await _client
        .from('comment_likes')
        .select()
        .match({'user_id': userId, 'comment_id': commentId})
        .maybeSingle();
    return res != null;
  }

  Future<int> getCommentLikeCount(String commentId) async {
    final res = await _client
        .from('comment_likes')
        .select('user_id')
        .eq('comment_id', commentId);
    return (res as List).length;
  }

  Future<bool> isFollowing(String currentUserId, String profileUserId) async {
    final res = await _client
        .from('follows')
        .select()
        .match({'follower_id': currentUserId, 'followed_id': profileUserId})
        .maybeSingle();
    return res != null;
  }

  Future<void> followUser(String currentUserId, String profileUserId) async {
    await _client
        .from('follows')
        .insert({'follower_id': currentUserId, 'followed_id': profileUserId});
  }

  Future<void> unfollowUser(String currentUserId, String profileUserId) async {
    await _client
        .from('follows')
        .delete()
        .match({'follower_id': currentUserId, 'followed_id': profileUserId});
  }

  Future<int> getFollowersCount(String userId) async {
    final res = await _client.from('follows').select('followed_id').eq('followed_id', userId);
    return (res as List).length;
  }

  Future<int> getFollowingCount(String userId) async {
    final res = await _client.from('follows').select('follower_id').eq('follower_id', userId);
    return (res as List).length;
  }

  Future<List<String>> getFollowing(String userId) async {
    final res = await _client
        .from('follows')
        .select('followed_id')
        .eq('follower_id', userId);

    return (res as List).map((e) => e['followed_id'] as String).toList();
  }

  Future<int> getFollowerCount(String userId) async {
    // This is a placeholder. You'll need to implement this based on your schema.
    return 0;
  }

  Future<int> getTotalLikesForUser(String userId) async {
    try {
      print('🔍 Getting total likes for user: $userId');
      
      // Use a more efficient approach with a join query
      final result = await _client
          .rpc('get_total_likes_for_user', params: {'target_user_id': userId});
      
      final totalLikes = result as int? ?? 0;
      print('✅ Total likes for user $userId: $totalLikes');
      
      return totalLikes;
    } catch (e) {
      print('Error getting total likes for user $userId: $e');
      
      // Fallback to manual counting if RPC fails
      try {
        final skills = await _client
            .from('skills')
            .select('id')
            .eq('creator_id', userId);
        
        if (skills.isEmpty) return 0;
        
        int totalLikes = 0;
        for (final skill in skills) {
          final likes = await _client
              .from('likes')
              .select('user_id')
              .eq('skill_id', skill['id']);
          totalLikes += (likes as List).length;
        }
        
        return totalLikes;
      } catch (e2) {
        print('Fallback also failed: $e2');
        return 0;
      }
    }
  }
} 