import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickcore/features/auth/data/user_model.dart';
import 'package:quickcore/features/profile/providers/profile_providers.dart';
import 'package:quickcore/shared/widgets/cached_network_image.dart';
import 'dart:ui';
import 'dart:developer' as dev;


class ProfileHeader extends ConsumerWidget {
  final UserModel user;
  const ProfileHeader({required this.user, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = colorScheme.secondary;
    final isTutor = user.role == 'tutor';
    // Using the providers we already have to fetch live data
    final followers = ref.watch(followerCountProvider(user.id));
    final following = ref.watch(followingCountProvider(user.id));
    final likes = ref.watch(userTotalLikesProvider(user.id));
    
    // Log avatar URL for debugging
    dev.log('ProfileHeader avatar URL: ${user.avatarUrl}');

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface.withOpacity(0.7),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: accent.withOpacity(0.13), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Glowing avatar
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isTutor ? accent.withOpacity(0.25) : accent.withOpacity(0.12),
                        blurRadius: isTutor ? 32 : 16,
                        spreadRadius: isTutor ? 4 : 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 54,
                    backgroundColor: Colors.grey.shade800,
                    child: ClipOval(
                      child: SizedBox(
                        width: 108,
                        height: 108,
                        child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                          ? SafeNetworkImage(
                              imageUrl: user.avatarUrl,
                              fit: BoxFit.cover,
                              errorWidget: const Icon(Icons.person, size: 54, color: Colors.white70),
                            )
                          : const Icon(Icons.person, size: 54, color: Colors.white70),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(user.name ?? 'No Name', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, fontFamily: 'Inter', color: accent)),
                if (user.username != null)
                  Text('@${user.username!}', style: theme.textTheme.titleMedium?.copyWith(color: accent.withOpacity(0.7), fontFamily: 'Inter')),
                if (user.bio != null && user.bio!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(user.bio!, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium?.copyWith(fontFamily: 'Inter')),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ProfileStat(
                      label: 'Following',
                      value: following.when(
                        data: (val) => val.toString(),
                        loading: () => '...',
                        error: (e,s) => '!',
                      ),
                      accent: accent,
                    ),
                    ProfileStat(
                      label: 'Followers',
                      value: followers.when(
                        data: (val) => val.toString(),
                        loading: () => '...',
                        error: (e,s) => '!',
                      ),
                      accent: accent,
                    ),
                    ProfileStat(
                      label: 'Likes',
                      value: likes.when(
                        data: (val) => val.toString(),
                        loading: () => '...',
                        error: (e,s) => '!',
                      ),
                      accent: accent,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (user.role == 'learner')
                  ElevatedButton.icon(
                    icon: const Icon(Icons.star_border),
                    label: const Text('Become a Tutor'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Become a Tutor?'),
                          content: const Text('You will be able to upload videos and earn from your content.'),
                          actions: [
                            TextButton(onPressed: () => context.pop(), child: const Text('Cancel')),
                            TextButton(onPressed: () {
                              ref.read(profileNotifierProvider.notifier).updateUserRole(user.id, 'tutor');
                              context.pop();
                            }, child: const Text('Confirm')),
                          ],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  const ProfileStat({required this.label, required this.value, required this.accent, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: accent, fontFamily: 'Inter')),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: accent.withOpacity(0.7), fontFamily: 'Inter')),
      ],
    );
  }
} 