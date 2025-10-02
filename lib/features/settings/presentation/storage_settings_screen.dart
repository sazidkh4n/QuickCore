import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickcore/core/providers/storage_provider.dart';
import 'package:quickcore/core/utils/video_test_widget.dart';

class StorageSettingsScreen extends ConsumerWidget {
  const StorageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStrategy = ref.watch(storageStrategyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Storage Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Storage Strategy',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Choose how your videos and thumbnails are stored:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            
            // Hybrid Storage Option
            Card(
              child: RadioListTile<StorageStrategy>(
                title: const Text('Hybrid Storage (Recommended)'),
                subtitle: const Text(
                  'Videos stored in Amazon S3 (cost-effective)\n'
                  'Thumbnails stored in Supabase (fast access)',
                ),
                value: StorageStrategy.hybrid,
                groupValue: currentStrategy,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(storageStrategyProvider.notifier).state = value;
                  }
                },
              ),
            ),
            
            // Pure S3 Option
            Card(
              child: RadioListTile<StorageStrategy>(
                title: const Text('Amazon S3 Only'),
                subtitle: const Text(
                  'All files stored in Amazon S3\n'
                  'Lowest cost, requires AWS setup',
                ),
                value: StorageStrategy.pureS3,
                groupValue: currentStrategy,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(storageStrategyProvider.notifier).state = value;
                  }
                },
              ),
            ),
            
            // Pure Supabase Option
            Card(
              child: RadioListTile<StorageStrategy>(
                title: const Text('Supabase Only'),
                subtitle: const Text(
                  'All files stored in Supabase\n'
                  'Simple setup, higher egress costs',
                ),
                value: StorageStrategy.pureSupabase,
                groupValue: currentStrategy,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(storageStrategyProvider.notifier).state = value;
                  }
                },
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Information Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cost Comparison',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('• Supabase Storage: \$0.021/GB egress'),
                  const Text('• Amazon S3: \$0.09/GB egress (first 10TB)'),
                  const Text('• CloudFront CDN: \$0.085/GB egress'),
                  const SizedBox(height: 16),
                  const Text(
                    'Recommendations',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('• Use Hybrid for best cost/performance balance'),
                  const Text('• Use S3 Only if you have high video traffic'),
                  const Text('• Use Supabase Only for simplicity (small scale)'),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Test Connection Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _testStorageConnection(context, ref),
                child: const Text('Test Storage Connection'),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Test Video Playback Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => _testVideoPlayback(context),
                child: const Text('Test Video Playback'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testStorageConnection(BuildContext context, WidgetRef ref) async {
    final strategy = ref.read(storageStrategyProvider);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Testing connection...'),
          ],
        ),
      ),
    );

    try {
      // Test the storage connection
      final storageService = ref.read(dynamicStorageProvider);
      
      // Create a small test file
      final testData = 'test-connection-${DateTime.now().millisecondsSinceEpoch}';
      final testPath = 'test/connection-test.txt';
      
      // Try to upload and then delete
      await storageService.uploadFile(
        path: testPath,
        data: testData.codeUnits,
        contentType: 'text/plain',
      );
      
      await storageService.deleteFile(testPath);
      
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${strategy.name} storage connection successful!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Connection Failed'),
            content: Text('Error: $e\n\nPlease check your configuration.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _testVideoPlayback(BuildContext context) {
    // Test with your uploaded video URL
    const testVideoUrl = 'https://quickcore-videos.s3.ap-south-1.amazonaws.com/2d540be6-8ce1-499e-8ff7-18bd20870653.mp4';
    
    testVideoUrl(context, testVideoUrl);
  }
}