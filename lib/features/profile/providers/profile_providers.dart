import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/data/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../feed/data/skill_model.dart';
import '../../social/providers/social_provider.dart';
import '../data/profile_repository.dart';

class SkillRepository {
  final _client = Supabase.instance.client;

  Future<List<SkillModel>> fetchSkillsByCreator(String creatorId) async {
    final res = await _client
        .from('skills')
        .select()
        .eq('creator_id', creatorId)
        .order('created_at', ascending: false);

    // Get like counts for all skills
    final skillsWithLikes = await Future.wait(
      (res as List).map((skill) async {
        final skillData = Map<String, dynamic>.from(skill);

        // Get like count for this skill
        final likeCount = await _client
            .from('likes')
            .select('user_id')
            .eq('skill_id', skillData['id'])
            .then((likes) => (likes as List).length);

        skillData['like_count'] = likeCount;

        return SkillModel.fromJson(skillData);
      }),
    );

    return skillsWithLikes;
  }
}

final skillRepositoryProvider = Provider<SkillRepository>((ref) {
  return SkillRepository();
});

final userProfileProvider = FutureProvider.family<UserModel, String>((
  ref,
  userId,
) async {
  final userRepo = ref.watch(userRepositoryProvider);
  return userRepo.getUserById(userId).then((user) {
    if (user == null) {
      throw Exception('User not found');
    }
    return user;
  });
});

final skillsByCreatorProvider = FutureProvider.family<List<SkillModel>, String>(
  (ref, creatorId) async {
    final skillRepo = ref.watch(skillRepositoryProvider);
    return skillRepo.fetchSkillsByCreator(creatorId);
  },
);

final followingCountProvider = FutureProvider.family<int, String>((
  ref,
  userId,
) async {
  final socialRepository = ref.watch(socialRepositoryProvider);
  return socialRepository.getFollowingCount(userId);
});

final followerCountProvider = FutureProvider.family<int, String>((
  ref,
  userId,
) async {
  final socialRepository = ref.watch(socialRepositoryProvider);
  return socialRepository.getFollowerCount(userId);
});

final userTotalLikesProvider = FutureProvider.family<int, String>((
  ref,
  userId,
) async {
  final socialRepository = ref.watch(socialRepositoryProvider);
  return socialRepository.getTotalLikesForUser(userId);
});

final isFollowingProvider = FutureProvider.family<bool, (String, String)>((
  ref,
  ids,
) async {
  final (currentUserId, profileUserId) = ids;
  final socialRepository = ref.watch(socialRepositoryProvider);
  return socialRepository.isFollowing(currentUserId, profileUserId);
});

final followUserProvider = FutureProvider.family<void, (String, String)>((
  ref,
  ids,
) async {
  final (currentUserId, profileUserId) = ids;
  final socialRepository = ref.watch(socialRepositoryProvider);
  await socialRepository.followUser(currentUserId, profileUserId);
  ref.invalidate(followerCountProvider(profileUserId));
  ref.invalidate(followingCountProvider(currentUserId));
  ref.invalidate(isFollowingProvider(ids));
});

final unfollowUserProvider = FutureProvider.family<void, (String, String)>((
  ref,
  ids,
) async {
  final (currentUserId, profileUserId) = ids;
  final socialRepository = ref.watch(socialRepositoryProvider);
  await socialRepository.unfollowUser(currentUserId, profileUserId);
  ref.invalidate(followerCountProvider(profileUserId));
  ref.invalidate(followingCountProvider(currentUserId));
  ref.invalidate(isFollowingProvider(ids));
});

// New provider for the logged-in user's profile logic
final profileRepositoryProvider = Provider((ref) => ProfileRepository());

// Provider for a user's uploaded skills
final userSkillsProvider = FutureProvider.family<List<SkillModel>, String>((
  ref,
  userId,
) async {
  final client = Supabase.instance.client;
  final res = await client
      .from('skills')
      .select()
      .eq('creator_id', userId)
      .order('created_at', ascending: false);

  // Get like counts for all skills
  final skillsWithLikes = await Future.wait(
    (res as List).map((skill) async {
      final skillData = Map<String, dynamic>.from(skill);

      // Get like count for this skill
      final likeCount = await client
          .from('likes')
          .select('user_id')
          .eq('skill_id', skillData['id'])
          .then((likes) => (likes as List).length);

      skillData['like_count'] = likeCount;

      return SkillModel.fromJson(skillData);
    }),
  );

  return skillsWithLikes;
});

// Note: skillsByCreatorProvider and userTotalLikesProvider are already defined above

class ProfileNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;
  ProfileNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<void> updateUserRole(String userId, String role) async {
    state = const AsyncValue.loading();
    try {
      print('Updating user role to: $role');
      // Update the role in Supabase
      await ref.read(profileRepositoryProvider).updateUserRole(userId, role);

      // Clear all user-related cache
      print('Invalidating user providers...');
      ref.invalidate(authProvider);
      ref.invalidate(userProfileProvider(userId));

      // Force refresh all providers that depend on user data
      print('Role updated successfully');
      state = const AsyncValue.data(null);
    } catch (e, st) {
      print('Error updating role: $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateProfile({
    required String userId,
    required String name,
    required String bio,
  }) async {
    state = const AsyncValue.loading();
    try {
      await ref
          .read(profileRepositoryProvider)
          .updateProfile(userId: userId, name: name, bio: bio);
      ref.invalidate(
        authProvider,
      ); // Invalidate to refetch the user with new info
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<void>>((ref) {
      return ProfileNotifier(ref);
    });

// Add this provider to handle role transitions
final roleTransitionProvider =
    StateNotifierProvider<RoleTransitionNotifier, AsyncValue<String?>>((ref) {
      return RoleTransitionNotifier(ref);
    });

class RoleTransitionNotifier extends StateNotifier<AsyncValue<String?>> {
  final Ref _ref;

  RoleTransitionNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> updateRole(String userId, String newRole) async {
    state = const AsyncValue.loading();

    try {
      await _ref
          .read(profileRepositoryProvider)
          .updateUserRole(userId, newRole);

      // Force refresh the user data
      _ref.invalidate(authProvider);
      _ref.invalidate(userProfileProvider(userId));

      state = AsyncValue.data(newRole);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
