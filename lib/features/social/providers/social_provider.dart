import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../data/social_repository.dart';
import '../data/comment_model.dart';
import '../../feed/providers/feed_provider.dart';
import '../../../core/utils/display_name_utils.dart';
import '../../auth/data/user_model.dart';
import 'dart:developer' as dev;

final socialRepositoryProvider = Provider((ref) => SocialRepository());

final socialProvider = StateNotifierProvider<SocialNotifier, void>((ref) {
  return SocialNotifier(ref);
});

class SocialNotifier extends StateNotifier<void> {
  final Ref _ref;
  SocialNotifier(this._ref) : super(null);

  Future<void> likeSkill(String userId, String skillId) async {
    try {
      // Add the like in the database
      await _ref.read(socialRepositoryProvider).likeSkill(userId, skillId);
      
      // Update the like count in the feed provider
      final feedNotifier = _ref.read(feedProvider.notifier);
      
      // Invalidate providers to refresh like counts
      _ref.invalidate(likeCountProvider(skillId));
      _ref.invalidate(likeStateProvider((userId, skillId)));
      
      // Also update the following feed provider if it's being used
      _ref.invalidate(followingFeedProvider);
      
      dev.log('Like added for skill $skillId by user $userId');
    } catch (e) {
      dev.log('Error adding like: $e');
    }
  }

  Future<void> unlikeSkill(String userId, String skillId) async {
    try {
      // Remove the like from the database
      await _ref.read(socialRepositoryProvider).unlikeSkill(userId, skillId);
      
      // Invalidate providers to refresh like counts
      _ref.invalidate(likeCountProvider(skillId));
      _ref.invalidate(likeStateProvider((userId, skillId)));
      
      // Also update the following feed provider if it's being used
      _ref.invalidate(followingFeedProvider);
      
      dev.log('Like removed for skill $skillId by user $userId');
    } catch (e) {
      dev.log('Error removing like: $e');
    }
  }

  Future<void> toggleLike(String userId, String skillId) async {
    try {
      final isLiked = await _ref.read(likeStateProvider((userId, skillId)).future);
      if (isLiked) {
        await unlikeSkill(userId, skillId);
      } else {
        await likeSkill(userId, skillId);
      }
    } catch (e) {
      dev.log('Error toggling like: $e');
    }
  }

  Future<void> addComment(String skillId, String userId, String text, {String? parentCommentId}) async {
    const uuid = Uuid();
    final comment = CommentModel(
      id: uuid.v4(),
      skillId: skillId,
      userId: userId,
      content: text,
      createdAt: DateTime.now(),
      parentCommentId: parentCommentId,
    );
    await _ref.read(socialRepositoryProvider).addComment(comment);

    if (parentCommentId != null) {
      _ref.invalidate(repliesProvider(parentCommentId));
    } else {
      _ref.invalidate(commentsProvider(skillId));
    }
  }

  Future<void> toggleCommentLike(String userId, String commentId) async {
    final isLiked = await _ref.read(isCommentLikedProvider((userId, commentId)).future);
    final repo = _ref.read(socialRepositoryProvider);
    if (isLiked) {
      await repo.unlikeComment(userId, commentId);
    } else {
      await repo.likeComment(userId, commentId);
    }
    _ref.invalidate(isCommentLikedProvider((userId, commentId)));
    _ref.invalidate(commentLikeCountProvider(commentId));
  }
}

final likeCountProvider = FutureProvider.family<int, String>((ref, skillId) async {
  return ref.watch(socialRepositoryProvider).getLikeCount(skillId);
});

final likeStateProvider = FutureProvider.family<bool, (String, String)>((ref, ids) async {
  final (userId, skillId) = ids;
  return ref.watch(socialRepositoryProvider).isLiked(userId, skillId);
});

final commentsProvider = FutureProvider.family<List<CommentModel>, String>((ref, skillId) async {
  return ref.watch(socialRepositoryProvider).getComments(skillId);
});

final repliesProvider =
    FutureProvider.family<List<CommentModel>, String>((ref, commentId) async {
  return ref.watch(socialRepositoryProvider).getReplies(commentId);
});

final isCommentLikedProvider =
    FutureProvider.family<bool, (String, String)>((ref, ids) async {
  final (userId, commentId) = ids;
  return ref.watch(socialRepositoryProvider).isCommentLiked(userId, commentId);
});

final commentLikeCountProvider =
    FutureProvider.family<int, String>((ref, commentId) async {
  return ref.watch(socialRepositoryProvider).getCommentLikeCount(commentId);
});

final followsProvider = FutureProvider.family<bool, String>((ref, key) async {
  final parts = key.split('|');
  final followerId = parts[0];
  final followedId = parts[1];
  final supabase = Supabase.instance.client;
  final res = await supabase
      .from('follows')
      .select()
      .eq('follower_id', followerId)
      .eq('followed_id', followedId)
      .maybeSingle();
  return res != null;
});

final followerCountProvider = FutureProvider.family<int, String>((ref, followedId) async {
  final supabase = Supabase.instance.client;
  final res = await supabase
      .from('follows')
      .select('follower_id')
      .eq('followed_id', followedId);
  return (res as List).length;
});

class FollowActions {
  static Future<void> follow(String followerId, String followedId) async {
    final supabase = Supabase.instance.client;
    await supabase.from('follows').insert({
      'follower_id': followerId,
      'followed_id': followedId,
      'followed_at': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> unfollow(String followerId, String followedId) async {
    final supabase = Supabase.instance.client;
    await supabase
        .from('follows')
        .delete()
        .eq('follower_id', followerId)
        .eq('followed_id', followedId);
  }
}

final displayNameProvider = FutureProvider.family<String, String>((ref, userId) async {
  final supabase = Supabase.instance.client;
  final res = await supabase
      .from('users')
      .select('name, username')
      .eq('id', userId)
      .maybeSingle();
  
  if (res != null) {
    // Create a temporary user model to use the utility function
    final user = UserModel(
      id: userId,
      name: res['name'] as String?,
      username: res['username'] as String?,
    );
    return DisplayNameUtils.getDisplayName(user);
  }
  
  // Fallback: use a generic identifier
  return 'User_${userId.substring(0, 8)}';
});

// Keep the old userNameProvider for backward compatibility but mark as deprecated
@Deprecated('Use displayNameProvider instead')
final userNameProvider = FutureProvider.family<String, String>((ref, userId) async {
  return await ref.watch(displayNameProvider(userId).future);
}); 