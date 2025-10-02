import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickcore/features/auth/data/user_model.dart';
import 'package:quickcore/features/auth/providers/auth_provider.dart';
import 'package:quickcore/features/profile/presentation/become_tutor_screen.dart';
import 'package:quickcore/features/profile/presentation/edit_profile_screen.dart';
import 'package:quickcore/features/profile/presentation/interests_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final user = auth.value;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not signed in')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader(context, 'Account Management'),
          _buildSettingItem(
            context,
            icon: Icons.person_outline,
            title: 'Edit Profile',
            subtitle: 'Change your name, username, and profile picture',
            onTap: () => context.push('/edit-profile'),
          ),
          _buildSettingItem(
            context,
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your password',
            onTap: () {
              // TODO: Implement change password flow
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon')),
              );
            },
          ),
          _buildSettingItem(
            context,
            icon: Icons.email_outlined,
            title: 'Email Address',
            subtitle: user.email ?? 'No email set',
            onTap: null,
          ),
          if (user.role != 'tutor' && user.role != 'creator')
            _buildSettingItem(
              context,
              icon: Icons.star_border,
              title: 'Become a Tutor',
              subtitle: 'Apply to become a content creator',
              onTap: () => context.push('/become-tutor'),
            ),
          _buildSettingItem(
            context,
            icon: Icons.delete_outline,
            title: 'Delete Account',
            subtitle: 'Permanently delete your account and all data',
            onTap: () => _showDeleteAccountDialog(context, ref),
            textColor: Colors.red,
          ),
          _buildSectionHeader(context, 'Content & Display'),
          _buildSettingItem(
            context,
            icon: Icons.interests_outlined,
            title: 'Interests',
            subtitle: 'Manage your interests for better recommendations',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => InterestsScreen(userId: user.id),
              ),
            ),
          ),
          _buildSettingItem(
            context,
            icon: Icons.history_outlined,
            title: 'Clear Watch History',
            subtitle: 'Erase your viewing history',
            onTap: () => _showConfirmationDialog(
              context,
              'Clear Watch History',
              'Are you sure you want to clear your watch history? This cannot be undone.',
              () {
                // TODO: Implement clear watch history
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Watch history cleared')),
                );
              },
            ),
          ),
          _buildSettingItem(
            context,
            icon: Icons.search_outlined,
            title: 'Clear Search History',
            subtitle: 'Erase your search history',
            onTap: () => _showConfirmationDialog(
              context,
              'Clear Search History',
              'Are you sure you want to clear your search history? This cannot be undone.',
              () {
                // TODO: Implement clear search history
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Search history cleared')),
                );
              },
            ),
          ),
          _buildSettingItem(
            context,
            icon: Icons.data_usage_outlined,
            title: 'Data Saver / Video Quality',
            subtitle: 'Manage video playback quality',
            onTap: () => _showVideoQualityDialog(context),
          ),
          _buildSectionHeader(context, 'Notifications'),
          _buildSwitchItem(
            context,
            icon: Icons.favorite_border,
            title: 'Likes',
            subtitle: 'Get notified when someone likes your content',
            value: true, // TODO: Get from user preferences
            onChanged: (value) {
              // TODO: Save preference
            },
          ),
          _buildSwitchItem(
            context,
            icon: Icons.person_add_outlined,
            title: 'New Followers',
            subtitle: 'Get notified when someone follows you',
            value: true, // TODO: Get from user preferences
            onChanged: (value) {
              // TODO: Save preference
            },
          ),
          _buildSwitchItem(
            context,
            icon: Icons.comment_outlined,
            title: 'Comments',
            subtitle: 'Get notified when someone comments on your content',
            value: true, // TODO: Get from user preferences
            onChanged: (value) {
              // TODO: Save preference
            },
          ),
          _buildSwitchItem(
            context,
            icon: Icons.recommend_outlined,
            title: 'Skill Recommendations',
            subtitle: 'Get notified about skills you might like',
            value: false, // TODO: Get from user preferences
            onChanged: (value) {
              // TODO: Save preference
            },
          ),
          _buildSectionHeader(context, 'Privacy & Safety'),
          _buildSwitchItem(
            context,
            icon: Icons.lock_outlined,
            title: 'Private Account',
            subtitle: 'Only followers can see your activity',
            value: false, // TODO: Get from user preferences
            onChanged: (value) {
              // TODO: Save preference
            },
          ),
          _buildSettingItem(
            context,
            icon: Icons.block_outlined,
            title: 'Blocked Accounts',
            subtitle: 'Manage users you\'ve blocked',
            onTap: () {
              // TODO: Navigate to blocked accounts screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon')),
              );
            },
          ),
          _buildSettingItem(
            context,
            icon: Icons.comment_outlined,
            title: 'Manage Comments',
            subtitle: 'Control who can comment on your content',
            onTap: () {
              // TODO: Navigate to comment settings screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon')),
              );
            },
          ),
          _buildSectionHeader(context, 'Support & About'),
          _buildSettingItem(
            context,
            icon: Icons.help_outline,
            title: 'Help Center / FAQ',
            subtitle: 'Get answers to common questions',
            onTap: () {
              // TODO: Navigate to help center
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon')),
              );
            },
          ),
          _buildSettingItem(
            context,
            icon: Icons.bug_report_outlined,
            title: 'Report a Problem',
            subtitle: 'Tell us about an issue you encountered',
            onTap: () {
              // TODO: Navigate to report problem screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon')),
              );
            },
          ),
          _buildSettingItem(
            context,
            icon: Icons.description_outlined,
            title: 'Terms & Conditions',
            subtitle: 'Read our terms of service',
            onTap: () {
              // TODO: Navigate to terms screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon')),
              );
            },
          ),
          _buildSettingItem(
            context,
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'Read our privacy policy',
            onTap: () {
              // TODO: Navigate to privacy policy screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon')),
              );
            },
          ),
          _buildSettingItem(
            context,
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of your account',
            onTap: () => _showConfirmationDialog(
              context,
              'Logout',
              'Are you sure you want to log out?',
              () {
                ref.read(authProvider.notifier).signOut();
                context.go('/auth');
              },
            ),
            textColor: Colors.red,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor),
      title: Text(title, style: TextStyle(color: textColor)),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }

  Widget _buildSwitchItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  void _showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    final textController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'This action cannot be undone. All your data will be permanently deleted.',
              style: TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            const Text('Type "DELETE" to confirm:'),
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                hintText: 'DELETE',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (textController.text == 'DELETE') {
                Navigator.of(context).pop();
                // TODO: Implement account deletion
                ref.read(authProvider.notifier).signOut();
                context.go('/auth');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please type "DELETE" to confirm')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showVideoQualityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Video Quality'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(
              title: const Text('Auto'),
              subtitle: const Text('Adjust quality based on your connection'),
              value: 'auto',
              groupValue: 'auto', // TODO: Get from user preferences
              onChanged: (value) {
                // TODO: Save preference
                Navigator.of(context).pop();
              },
            ),
            RadioListTile(
              title: const Text('Data Saver'),
              subtitle: const Text('Lower quality to reduce data usage'),
              value: 'low',
              groupValue: 'auto', // TODO: Get from user preferences
              onChanged: (value) {
                // TODO: Save preference
                Navigator.of(context).pop();
              },
            ),
            RadioListTile(
              title: const Text('Always High Quality'),
              subtitle: const Text('Higher quality but uses more data'),
              value: 'high',
              groupValue: 'auto', // TODO: Get from user preferences
              onChanged: (value) {
                // TODO: Save preference
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
} 