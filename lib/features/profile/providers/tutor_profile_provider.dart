import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickcore/features/auth/providers/auth_provider.dart';
import 'package:quickcore/features/profile/data/tutor_profile_model.dart';
import 'package:quickcore/features/profile/data/tutor_profile_repository.dart';

// Provider for the TutorProfileRepository
final tutorProfileRepositoryProvider = Provider<TutorProfileRepository>((ref) {
  return TutorProfileRepository();
});

// FutureProvider that fetches the tutor profile data
final tutorProfileDataProvider = FutureProvider.family<TutorProfileModel, String>((ref, tutorId) async {
  final repository = ref.watch(tutorProfileRepositoryProvider);
  return repository.fetchTutorProfileData(tutorId);
});

// Provider to check if the current user is a tutor
final isCurrentUserTutorProvider = FutureProvider<bool>((ref) async {
  final userAsync = ref.watch(authProvider);
  final user = userAsync.value;
  
  if (user == null) {
    return false;
  }
  
  return user.role == 'tutor';
});

// Provider to determine which profile view to show
final shouldShowTutorProfileProvider = FutureProvider.family<bool, String>((ref, userId) async {
  final userRepo = ref.watch(userRepositoryProvider);
  final user = await userRepo.getUserById(userId);
  
  return user?.role == 'tutor';
}); 