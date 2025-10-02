import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickcore/features/auth/providers/auth_provider.dart';
import 'package:quickcore/features/profile/providers/profile_providers.dart';
import 'package:quickcore/features/profile/presentation/widgets/tutor_profile_page.dart';
import 'package:quickcore/features/profile/presentation/widgets/learner_profile_page.dart';
import 'dart:developer' as dev;

/// New role-based user profile screen that renders different UI based on user role
/// This is used for viewing other users' profiles via /profile/:userId route
class UserProfileScreenNew extends ConsumerWidget {
  final String userId;

  const UserProfileScreenNew({required this.userId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final currentUser = authState.value;

    // Check if this is the current user's own profile
    final isCurrentUser = currentUser?.id == userId;

    dev.log('UserProfileScreenNew: Loading profile for userId: $userId');
    dev.log('UserProfileScreenNew: Current user ID: ${currentUser?.id}');
    dev.log('UserProfileScreenNew: Is current user: $isCurrentUser');

    return authState.when(
      data: (user) {
        if (user == null) {
          return _buildErrorScreen(
            context,
            'Authentication Error',
            'Please log in to view profiles',
            () => Navigator.of(context).pop(),
          );
        }

        final userProfileAsync = ref.watch(userProfileProvider(userId));

        return userProfileAsync.when(
          data: (profileUser) {
            dev.log(
              'UserProfileScreenNew: Profile user role: ${profileUser.role}',
            );

            // Route to appropriate profile page based on user role
            if (profileUser.role == 'tutor') {
              return TutorProfilePage(
                user: profileUser,
                isCurrentUser: isCurrentUser,
              );
            } else {
              // Default to learner profile for 'learner' role or null/unknown roles
              return LearnerProfilePage(
                user: profileUser,
                isCurrentUser: isCurrentUser,
              );
            }
          },
          loading: () => _buildLoadingScreen(context),
          error: (error, stackTrace) {
            dev.log('UserProfileScreenNew: Error loading profile: $error');
            return _buildErrorScreen(
              context,
              'Profile Not Found',
              'Unable to load user profile. The user may not exist or there was a network error.',
              () => Navigator.of(context).pop(),
            );
          },
        );
      },
      loading: () => _buildLoadingScreen(context),
      error: (error, stackTrace) {
        dev.log('UserProfileScreenNew: Auth error: $error');
        return _buildErrorScreen(
          context,
          'Authentication Error',
          'Please check your connection and try again.',
          () => Navigator.of(context).pop(),
        );
      },
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated loading indicator
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1000),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.5 + (value * 0.5),
                  child: Opacity(
                    opacity: value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1200),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Text(
                    'Loading Profile...',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 1400),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Text(
                    'Please wait while we fetch the user data',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(
    BuildContext context,
    String title,
    String message,
    VoidCallback onRetry,
  ) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated error icon
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.error.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person_off_outlined,
                        size: 50,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Error title
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1000),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Error message
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1200),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Text(
                      message,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Action buttons
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1400),
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, (1 - value) * 20),
                    child: Opacity(
                      opacity: value,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: onRetry,
                            icon: const Icon(Icons.arrow_back),
                            label: const Text('Go Back'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Refresh the page by rebuilding the widget
                              // This will trigger the providers to refetch data
                              (context as Element).markNeedsBuild();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
