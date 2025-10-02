import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../favorites_repository.dart';

final favoritesRepositoryProvider = Provider((ref) => FavoritesRepository());

final isFavoritedProvider = FutureProvider.family<bool, Map<String, String>>((ref, params) async {
  final repo = ref.read(favoritesRepositoryProvider);
  return repo.isFavorited(params['userId']!, params['skillId']!);
});

final favoritesListProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, userId) async {
  final repo = ref.read(favoritesRepositoryProvider);
  return repo.getFavorites(userId);
});

class FavoriteActions {
  static Future<void> add(WidgetRef ref, String userId, String skillId) async {
    final repo = ref.read(favoritesRepositoryProvider);
    await repo.addFavorite(userId, skillId);
    ref.invalidate(isFavoritedProvider({'userId': userId, 'skillId': skillId}));
    ref.invalidate(favoritesListProvider(userId));
  }

  static Future<void> remove(WidgetRef ref, String userId, String skillId) async {
    final repo = ref.read(favoritesRepositoryProvider);
    await repo.removeFavorite(userId, skillId);
    ref.invalidate(isFavoritedProvider({'userId': userId, 'skillId': skillId}));
    ref.invalidate(favoritesListProvider(userId));
  }
} 