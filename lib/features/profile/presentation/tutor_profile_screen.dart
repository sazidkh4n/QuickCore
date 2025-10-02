import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickcore/features/auth/data/user_model.dart';
import 'package:quickcore/features/profile/providers/tutor_profile_provider.dart';
import 'package:quickcore/features/profile/data/tutor_profile_model.dart';
import 'package:quickcore/features/profile/presentation/widgets/profile_header.dart';

class TutorProfileScreen extends ConsumerWidget {
  final UserModel user;
  const TutorProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tutorProfileDataAsync = ref.watch(tutorProfileDataProvider(user.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(user.username ?? 'Tutor Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: tutorProfileDataAsync.when(
        data: (tutorProfile) => _buildProfileContent(context, tutorProfile),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildErrorView(context, error, ref),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/upload'),
        label: const Text('Upload Video'),
        icon: const Icon(Icons.upload_outlined),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, TutorProfileModel profile) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        ProfileHeader(user: user),
        const SizedBox(height: 24),
        _CreatorStatsCard(profile: profile),
        const SizedBox(height: 16),
        _MonetizationDashboard(profile: profile),
        const SizedBox(height: 16),
        _TutorSkillsGrid(profile: profile),
      ],
    );
  }

  Widget _buildErrorView(BuildContext context, Object error, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Error loading profile data: ${error.toString()}',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.refresh(tutorProfileDataProvider(user.id)),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _CreatorStatsCard extends StatelessWidget {
  final TutorProfileModel profile;

  const _CreatorStatsCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Creator Stats',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  value: profile.totalUploads.toString(),
                  label: 'Total Uploads',
                  icon: Icons.video_library_outlined,
                ),
                _StatItem(
                  value: profile.totalViews.toString(),
                  label: 'Total Views',
                  icon: Icons.visibility_outlined,
                ),
                _StatItem(
                  value: profile.totalLikes.toString(),
                  label: 'Total Likes',
                  icon: Icons.favorite_border_outlined,
                ),
                _StatItem(
                  value: profile.totalFollowers.toString(),
                  label: 'Followers',
                  icon: Icons.people_outline,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _MonetizationDashboard extends StatelessWidget {
  final TutorProfileModel profile;

  const _MonetizationDashboard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monetization Dashboard',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              '₹${profile.totalEarnings.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'From Views: ₹${profile.viewsEarnings.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Expanded(
                  child: Text(
                    'From Followers: ₹${profile.followerBonus.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Text(
              'Follower Milestones',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _MilestoneProgress(
              label: 'Road to 10k Followers',
              value: profile.milestoneProgress['10k'] ?? 0,
              currentFollowers: profile.totalFollowers,
              targetFollowers: 10000,
            ),
            _MilestoneProgress(
              label: 'Road to 100k Followers',
              value: profile.milestoneProgress['100k'] ?? 0,
              currentFollowers: profile.totalFollowers,
              targetFollowers: 100000,
            ),
            _MilestoneProgress(
              label: 'Road to 1M Followers',
              value: profile.milestoneProgress['1M'] ?? 0,
              currentFollowers: profile.totalFollowers,
              targetFollowers: 1000000,
            ),
          ],
        ),
      ),
    );
  }
}

class _MilestoneProgress extends StatelessWidget {
  final String label;
  final double value; // 0.0 to 1.0
  final int currentFollowers;
  final int targetFollowers;

  const _MilestoneProgress({
    required this.label,
    required this.value,
    required this.currentFollowers,
    required this.targetFollowers,
  });

  @override
  Widget build(BuildContext context) {
    final isAchieved = value >= 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              if (isAchieved)
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.green.shade700,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
                isAchieved ? Colors.green.shade700 : Theme.of(context).colorScheme.primary),
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
          const SizedBox(height: 4),
          Text(
            '$currentFollowers / $targetFollowers',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _TutorSkillsGrid extends StatelessWidget {
  final TutorProfileModel profile;

  const _TutorSkillsGrid({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Skills',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        profile.videos.isEmpty
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Text('You have not uploaded any videos yet.'),
                ),
              )
            : GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 9 / 12,
                ),
                itemCount: profile.videos.length,
                itemBuilder: (context, index) {
                  final video = profile.videos[index];
                  return _VideoThumbnail(video: video);
                },
              ),
      ],
    );
  }
}

class _VideoThumbnail extends StatelessWidget {
  final dynamic video;

  const _VideoThumbnail({required this.video});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to video analytics page
        context.push('/video/${video.id}/analytics');
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: video.thumbnailUrl != null
                  ? Image.network(
                      video.thumbnailUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade800,
                        child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.white),
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade800,
                      child: const Center(
                        child: Icon(Icons.video_file, color: Colors.white70, size: 42),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.visibility_outlined, size: 12, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${video.viewCount}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.favorite_outline, size: 12, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${video.likeCount}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 