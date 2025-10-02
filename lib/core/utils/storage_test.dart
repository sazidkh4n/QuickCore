import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/storage_provider.dart';

class StorageTestUtils {
  /// Test S3 connection with a small file
  static Future<bool> testS3Connection(WidgetRef ref) async {
    try {
      final s3Storage = ref.read(s3StorageServiceProvider);
      
      // Create a small test file
      final testData = Uint8List.fromList('S3 connection test'.codeUnits);
      final testPath = 'test/connection-${DateTime.now().millisecondsSinceEpoch}.txt';
      
      print('Testing S3 upload...');
      
      // Upload test file
      final url = await s3Storage.uploadFile(
        path: testPath,
        data: testData,
        contentType: 'text/plain',
      );
      
      print('S3 upload successful: $url');
      
      // Clean up test file
      final deleted = await s3Storage.deleteFile(testPath);
      print('S3 cleanup ${deleted ? 'successful' : 'failed'}');
      
      return true;
    } catch (e) {
      print('S3 connection test failed: $e');
      return false;
    }
  }
  
  /// Test Supabase connection
  static Future<bool> testSupabaseConnection(WidgetRef ref) async {
    try {
      final supabaseStorage = ref.read(supabaseStorageServiceProvider);
      
      // Create a small test file
      final testData = Uint8List.fromList('Supabase connection test'.codeUnits);
      final testPath = 'test/connection-${DateTime.now().millisecondsSinceEpoch}.txt';
      
      print('Testing Supabase upload...');
      
      // Upload test file
      final url = await supabaseStorage.uploadFile(
        path: testPath,
        data: testData,
        contentType: 'text/plain',
      );
      
      print('Supabase upload successful: $url');
      
      // Clean up test file
      final deleted = await supabaseStorage.deleteFile(testPath);
      print('Supabase cleanup ${deleted ? 'successful' : 'failed'}');
      
      return true;
    } catch (e) {
      print('Supabase connection test failed: $e');
      return false;
    }
  }
  
  /// Test hybrid storage (recommended setup)
  static Future<bool> testHybridStorage(WidgetRef ref) async {
    try {
      final hybridStorage = ref.read(storageServiceProvider);
      
      print('Testing hybrid storage...');
      
      // Test video upload (should go to S3)
      final videoData = Uint8List.fromList(List.generate(1024, (i) => i % 256));
      final videoPath = 'test/video-${DateTime.now().millisecondsSinceEpoch}.mp4';
      
      final videoUrl = await hybridStorage.uploadFile(
        path: videoPath,
        data: videoData,
        contentType: 'video/mp4',
      );
      
      print('Video upload successful: $videoUrl');
      
      // Test thumbnail upload (should go to Supabase)
      final thumbData = Uint8List.fromList(List.generate(512, (i) => i % 256));
      final thumbPath = 'test/thumb-${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final thumbUrl = await hybridStorage.uploadFile(
        path: thumbPath,
        data: thumbData,
        contentType: 'image/jpeg',
      );
      
      print('Thumbnail upload successful: $thumbUrl');
      
      // Clean up
      await hybridStorage.deleteFile(videoPath);
      await hybridStorage.deleteFile(thumbPath);
      
      return true;
    } catch (e) {
      print('Hybrid storage test failed: $e');
      return false;
    }
  }
  
  /// Run all storage tests
  static Future<Map<String, bool>> runAllTests(WidgetRef ref) async {
    final results = <String, bool>{};
    
    print('Running storage connection tests...\n');
    
    results['supabase'] = await testSupabaseConnection(ref);
    results['s3'] = await testS3Connection(ref);
    results['hybrid'] = await testHybridStorage(ref);
    
    print('\n=== Test Results ===');
    results.forEach((test, passed) {
      print('$test: ${passed ? '✅ PASSED' : '❌ FAILED'}');
    });
    
    final allPassed = results.values.every((passed) => passed);
    print('\nOverall: ${allPassed ? '✅ ALL TESTS PASSED' : '❌ SOME TESTS FAILED'}');
    
    return results;
  }
}