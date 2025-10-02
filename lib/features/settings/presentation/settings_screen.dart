import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'storage_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          
          // Storage Settings
          ListTile(
            leading: const Icon(Icons.cloud_upload),
            title: const Text('Storage Settings'),
            subtitle: const Text('Configure video storage options'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const StorageSettingsScreen(),
                ),
              );
            },
          ),
          
          const Divider(),
          
          // Other settings can go here
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Account Settings'),
            subtitle: const Text('Manage your account'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to account settings
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            subtitle: const Text('Manage notification preferences'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to notification settings
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy'),
            subtitle: const Text('Privacy and security settings'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to privacy settings
            },
          ),
          
          const Divider(),
          
          // Storage Info Section
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Storage Information',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('Current storage strategy: Hybrid'),
                const Text('Videos: Amazon S3 (quickcore-videos, ap-south-1)'),
                const Text('Thumbnails: Supabase'),
                const SizedBox(height: 8),
                const Text(
                  'This configuration provides the best balance of cost and performance for your educational content.',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}