import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickcore/features/auth/presentation/create_profile_screen.dart';
import 'package:quickcore/features/video/providers/video_controller_provider.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/sign_in_screen.dart';
import '../../features/auth/presentation/sign_up_screen.dart';
import '../../features/feed/presentation/feed_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/user_profile_screen_new.dart';
import '../../features/profile/presentation/become_tutor_screen.dart';
import '../../features/explore/presentation/explore_screen.dart';
import '../../features/upload/presentation/upload_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/notifications/presentation/enhanced_chat_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'dart:ui';
import '../../features/profile/presentation/settings_screen.dart';
import '../../features/profile/presentation/interests_screen.dart';
import '../../features/profile/presentation/video_viewer_screen.dart';
import '../../features/recommendations/presentation/discovery_screen.dart';
import 'dart:developer' as dev;

class MainScaffold extends ConsumerStatefulWidget {
  const MainScaffold({super.key, required this.child});
  final Widget child;
  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  int _index = 0;

  void _onTap(int i) {
    if (i < 0 || i > 4) return;

    final routes = [
      '/feed',
      '/explore',
      '/upload',
      '/notifications',
      '/profile',
    ];

    final screenNames = [
      'feed',
      'explore',
      'upload',
      'notifications',
      'profile',
    ];

    // Set screen context and handle video pausing
    final videoController = ref.read(videoControllerNotifierProvider);
    videoController.setCurrentScreen(screenNames[i]);

    // Pause videos when navigating away from feed
    if (_index == 0 && i != 0) {
      // Moving away from feed
      videoController.pauseAllVideosManually();
    }

    context.go(routes[i]);
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: widget.child,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
            child: BottomNavigationBar(
              currentIndex: _index,
              onTap: _onTap,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.black.withOpacity(0.4),
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white70,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Feed',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.search),
                  label: 'Explore',
                ),
                BottomNavigationBarItem(
                  icon: Container(
                    width: 50,
                    height: 35,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add, color: Colors.black),
                  ),
                  label: 'Upload',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.notifications_outlined),
                  label: 'Alerts',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/auth',
    redirect: (context, state) {
      // While the auth state is loading, stay on the loading screen.
      // This happens on app startup.
      if (authState is AsyncLoading) {
        return state.matchedLocation == '/auth' ? null : '/auth';
      }

      // If there's an error in auth state, don't redirect - let the error be handled in the UI
      if (authState is AsyncError) {
        dev.log('Auth error detected: ${authState.error}');
        // Stay on the current page if it's a sign-in or sign-up page
        if (state.matchedLocation == '/signIn' ||
            state.matchedLocation == '/signUp') {
          return null;
        }
        // Otherwise, go to sign-in page to handle the error there
        return '/signIn';
      }

      final loggedIn = authState.value != null;

      // Define all pages that are part of the authentication flow.
      final onAuthFlow =
          state.matchedLocation == '/auth' ||
          state.matchedLocation == '/signIn' ||
          state.matchedLocation == '/signUp' ||
          state.matchedLocation == '/forgot-password';

      // If the user is not logged in, they must be on an auth page.
      // If they are on the initial loading screen, redirect to sign-in.
      if (!loggedIn) {
        return onAuthFlow && state.matchedLocation != '/auth'
            ? null
            : '/signIn';
      }

      // --- From here, we know the user is logged in. ---

      // If the user needs to create a profile, send them there.
      final hasUsername = authState.value!.username != null;
      final creatingProfile = state.matchedLocation == '/create-profile';
      if (!hasUsername && !creatingProfile) {
        return '/create-profile';
      }

      // If the user is logged in and on any auth page, send them to the feed.
      if (onAuthFlow && hasUsername) {
        return '/feed';
      }

      // No other redirection is needed.
      return null;
    },
    errorBuilder: (context, state) {
      dev.log('Navigation error: ${state.error}');
      // Return a user-friendly error screen instead of the default error page
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Check if we came from notifications and go back there
              final uri = state.uri.toString();
              if (uri.contains('/video/') || uri.contains('/skill/')) {
                context.go('/notifications');
              } else {
                // Default fallback
                context.go('/feed');
              }
            },
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Please try again or contact support if the problem persists.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    // Check if we came from notifications and go back there
                    final uri = state.uri.toString();
                    if (uri.contains('/video/') || uri.contains('/skill/')) {
                      context.go('/notifications');
                    } else {
                      // Default fallback
                      context.go('/feed');
                    }
                  },
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    },
    routes: [
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      GoRoute(
        path: '/signIn',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/signUp',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/create-profile',
        builder: (context, state) => const CreateProfileScreen(),
      ),
      // Video analytics route outside the ShellRoute so it doesn't have the bottom navigation bar
      GoRoute(
        path: '/video/:videoId/analytics',
        builder: (context, state) {
          final videoId = state.pathParameters['videoId']!;
          return VideoViewerScreen(videoId: videoId, showAnalytics: true);
        },
      ),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/feed',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const FeedScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                final slide = Tween<Offset>(
                  begin: const Offset(0.12, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
                final fade = CurvedAnimation(parent: animation, curve: Curves.easeIn);
                final scale = Tween<double>(begin: 0.98, end: 1.0).animate(animation);
                return SlideTransition(
                  position: slide,
                  child: FadeTransition(
                    opacity: fade,
                    child: ScaleTransition(
                      scale: scale,
                      child: child,
                    ),
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 200),
            ),
          ),
          GoRoute(
            path: '/explore',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: ExploreScreen(category: state.uri.queryParameters['category']),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                final slide = Tween<Offset>(
                  begin: const Offset(0.12, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
                final fade = CurvedAnimation(parent: animation, curve: Curves.easeIn);
                final scale = Tween<double>(begin: 0.98, end: 1.0).animate(animation);
                return SlideTransition(
                  position: slide,
                  child: FadeTransition(
                    opacity: fade,
                    child: ScaleTransition(
                      scale: scale,
                      child: child,
                    ),
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 200),
            ),
          ),
          GoRoute(
            path: '/discover',
            builder: (context, state) => const DiscoveryScreen(),
          ),
          GoRoute(
            path: '/upload',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const UploadScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                final slide = Tween<Offset>(
                  begin: const Offset(0.12, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
                final fade = CurvedAnimation(parent: animation, curve: Curves.easeIn);
                final scale = Tween<double>(begin: 0.98, end: 1.0).animate(animation);
                return SlideTransition(
                  position: slide,
                  child: FadeTransition(
                    opacity: fade,
                    child: ScaleTransition(
                      scale: scale,
                      child: child,
                    ),
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 200),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const ProfileScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                final slide = Tween<Offset>(
                  begin: const Offset(0.12, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
                final fade = CurvedAnimation(parent: animation, curve: Curves.easeIn);
                final scale = Tween<double>(begin: 0.98, end: 1.0).animate(animation);
                return SlideTransition(
                  position: slide,
                  child: FadeTransition(
                    opacity: fade,
                    child: ScaleTransition(
                      scale: scale,
                      child: child,
                    ),
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 200),
            ),
          ),
          GoRoute(
            path: '/profile/:userId',
            pageBuilder: (context, state) {
              final userId = state.pathParameters['userId']!;
              return CustomTransitionPage(
                key: state.pageKey,
                child: UserProfileScreenNew(userId: userId),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },
              );
            },
          ),
          GoRoute(
            path: '/edit-profile',
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            path: '/settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: '/interests',
            builder: (context, state) {
              final userId = ref.read(authProvider).value?.id;
              if (userId == null) {
                return const AuthScreen();
              }
              return InterestsScreen(userId: userId);
            },
          ),
          GoRoute(
            path: '/skill/:skillId',
            builder: (context, state) {
              final skillId = state.pathParameters['skillId']!;
              return FeedScreen(initialSkillId: skillId);
            },
          ),
          // Add route for /video/:videoId to handle notifications properly
          GoRoute(
            path: '/video/:videoId',
            builder: (context, state) {
              final videoId = state.pathParameters['videoId']!;
              final source = state.uri.queryParameters['source'] ?? 'feed';
              final openComments = state.uri.queryParameters['openComments'] == 'true';
              final notificationType = state.uri.queryParameters['notificationType'];
              return VideoViewerScreen(
                videoId: videoId, 
                source: source,
                openComments: openComments,
                notificationType: notificationType,
              );
            },
          ),
          GoRoute(
            path: '/notifications',
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const NotificationsScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                final slide = Tween<Offset>(
                  begin: const Offset(0.12, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
                final fade = CurvedAnimation(parent: animation, curve: Curves.easeIn);
                final scale = Tween<double>(begin: 0.98, end: 1.0).animate(animation);
                return SlideTransition(
                  position: slide,
                  child: FadeTransition(
                    opacity: fade,
                    child: ScaleTransition(
                      scale: scale,
                      child: child,
                    ),
                  ),
                );
              },
              transitionDuration: const Duration(milliseconds: 200),
            ),
          ),
          GoRoute(
            path: '/chat/:userId',
            builder: (context, state) {
              final userId = state.pathParameters['userId']!;
              final name = state.uri.queryParameters['name'] ?? 'User';
              final avatar = state.uri.queryParameters['avatar'];
              return EnhancedChatScreen(
                otherUserId: userId,
                otherUserName: name,
                otherUserAvatar: avatar,
              );
            },
          ),
          GoRoute(
            path: '/become-tutor',
            builder: (context, state) {
              final currentUser = ref.read(authProvider).value;
              if (currentUser == null) {
                return const AuthScreen();
              }
              return BecomeTutorScreen(user: currentUser);
            },
          ),
        ],
      ),
    ],
  );
});
