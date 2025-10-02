import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickcore/features/auth/data/user_model.dart';
import 'package:quickcore/features/profile/providers/profile_providers.dart';
import 'package:quickcore/features/profile/providers/learning_stats_providers.dart';
import 'package:quickcore/features/profile/presentation/widgets/profile_header.dart';

// Main view for Learners
class LearnerProfileScreen extends ConsumerWidget {
  final UserModel user;
  const LearnerProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the role transition state
    final roleTransitionState = ref.watch(roleTransitionProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(user.username ?? 'Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/profile/edit'),
          ),
        ],
      ),
      body: roleTransitionState.maybeWhen(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${e.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(roleTransitionProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        orElse: () => _buildProfileContent(context, ref),
      ),
    );
  }
  
  Widget _buildProfileContent(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3, // My Skills, History, Bookmarked
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(child: ProfileHeader(user: user)),
            // Enhanced Become a Tutor button with better visibility
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 4,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Share Your Knowledge',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Become a tutor and start earning by creating educational content',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            ),
                            icon: const Icon(Icons.school),
                            label: const Text('Become a Tutor'),
                            onPressed: () async {
                              // Use the dedicated provider for role transitions
                              await ref.read(roleTransitionProvider.notifier).updateRole(user.id, 'tutor');
                              
                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('You are now a tutor!')),
                              );
                              
                              // Navigate to refresh the screen
                              if (context.mounted) {
                                context.go('/profile');
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.star_outline), text: 'Skills'),
                Tab(icon: Icon(Icons.history_outlined), text: 'History'),
                Tab(icon: Icon(Icons.bookmark_border), text: 'Bookmarks'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _SkillInterestsView(userId: user.id),
                  _WatchHistoryView(userId: user.id),
                  _BookmarkedVideosView(userId: user.id),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillInterestsView extends ConsumerWidget {
  final String userId;
  const _SkillInterestsView({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skillsAsync = ref.watch(skillInterestsProvider(userId));
    return skillsAsync.when(
      data: (skills) {
        if (skills.isEmpty) {
          return const Center(child: Text('No skill interests set yet.'));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: skills.map((skill) => Chip(label: Text(skill))).toList(),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: ${e.toString()}')),
    );
  }
}

class _WatchHistoryView extends ConsumerWidget {
  final String userId;
  const _WatchHistoryView({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(watchHistoryProvider(userId));
    return historyAsync.when(
      data: (videos) {
        if (videos.isEmpty) {
          return const Center(child: Text('No videos in your watch history.'));
        }
        return ListView.builder(
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            // A simple list tile to show video info. Can be expanded later.
            return ListTile(
              leading: video['thumbnail_url'] != null
                  ? Image.network(video['thumbnail_url'],
                      width: 100, fit: BoxFit.cover)
                  : Container(width: 100, color: Colors.grey),
              title: Text(video['title'] ?? 'Untitled'),
              subtitle: Text('Duration: ${video['duration'] ?? 'N/A'}'),
              onTap: () {
                // TODO: Navigate to video player
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: ${e.toString()}')),
    );
  }
}

class _BookmarkedVideosView extends ConsumerWidget {
  final String userId;
  const _BookmarkedVideosView({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(bookmarkedVideosProvider(userId));
    return bookmarksAsync.when(
      data: (videos) {
        if (videos.isEmpty) {
          return const Center(child: Text('You have no bookmarked videos.'));
        }
        // Using a horizontal scroll view as requested
        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: videos.length,
          itemBuilder: (context, index) {
            final video = videos[index];
            return GestureDetector(
              onTap: () {
                // TODO: Navigate to video player
              },
              child: Card(
                margin: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: 180,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      video['thumbnail_url'] != null
                          ? Image.network(video['thumbnail_url'],
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover)
                          : Container(height: 100, color: Colors.grey),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          video['title'] ?? 'Untitled',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: ${e.toString()}')),
    );
  }
} 