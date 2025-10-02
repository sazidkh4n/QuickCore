// Deprecated: Use favorites_provider.dart instead for all favorites/bookmarks logic.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../bookmarks_repository.dart';
import '../../feed/data/skill_model.dart';

final bookmarksRepositoryProvider = Provider((ref) => BookmarksRepository());

final bookmarksProvider =
    StateNotifierProvider<BookmarksNotifier, List<SkillModel>>((ref) {
  return BookmarksNotifier(ref);
});

class BookmarksNotifier extends StateNotifier<List<SkillModel>> {
  final Ref _ref;
  BookmarksNotifier(this._ref) : super([]);

  Future<void> getBookmarks(String userId) async {
    state = await _ref.read(bookmarksRepositoryProvider).getBookmarks(userId);
  }

  Future<void> toggleBookmark(String userId, String skillId) async {
    await _ref
        .read(bookmarksRepositoryProvider)
        .toggleBookmark(userId, skillId);
    _ref.invalidate(isBookmarkedProvider((userId, skillId)));
    getBookmarks(userId);
  }
}

final userBookmarksProvider =
    FutureProvider.family<List<SkillModel>, String>((ref, userId) async {
  return ref.watch(bookmarksRepositoryProvider).getBookmarks(userId);
});

final isBookmarkedProvider =
    FutureProvider.family<bool, (String, String)>((ref, ids) async {
  final (userId, skillId) = ids;
  return ref.watch(bookmarksRepositoryProvider).isBookmarked(userId, skillId);
});

final bookmarkedSkillsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, userId) async {
  final repo = ref.read(bookmarksRepositoryProvider);
  final client = repo.client;
  final res = await client
      .from('favorites')
      .select('skill_id, skills(*)')
      .eq('user_id', userId)
      .order('saved_at', ascending: false);
  // Each row: { skill_id: ..., skills: { ...skill fields... } }
  return List<Map<String, dynamic>>.from(res);
});

class BookmarkActions {
  static Future<void> add(WidgetRef ref, String userId, String skillId) async {
    final repo = ref.read(bookmarksRepositoryProvider);
    await repo.addBookmark(userId, skillId);
    ref.invalidate(isBookmarkedProvider((userId, skillId)));
  }

  static Future<void> remove(WidgetRef ref, String userId, String skillId) async {
    final repo = ref.read(bookmarksRepositoryProvider);
    await repo.removeBookmark(userId, skillId);
    ref.invalidate(isBookmarkedProvider((userId, skillId)));
  }
} 