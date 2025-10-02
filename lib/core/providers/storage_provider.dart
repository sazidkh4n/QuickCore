import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/storage_service.dart';
import '../services/s3_service.dart';
import '../config/app_config.dart';

// S3 Service Provider
final s3ServiceProvider = Provider<S3Service>((ref) {
  final config = S3Config(
    accessKey: AppConfig.awsAccessKey,
    secretKey: AppConfig.awsSecretKey,
    bucketName: AppConfig.awsBucketName,
    region: AppConfig.awsRegion,
    endpoint: AppConfig.effectiveAwsEndpoint,
  );
  
  return S3Service(config);
});

// Supabase Storage Service Provider
final supabaseStorageServiceProvider = Provider<SupabaseStorageService>((ref) {
  return SupabaseStorageService(
    client: Supabase.instance.client,
    bucketName: 'videos', // Your existing Supabase bucket
  );
});

// S3 Storage Service Provider
final s3StorageServiceProvider = Provider<S3StorageService>((ref) {
  final s3Service = ref.read(s3ServiceProvider);
  return S3StorageService(s3Service);
});

// Main Storage Service Provider - Uses hybrid approach
final storageServiceProvider = Provider<StorageService>((ref) {
  final supabaseStorage = ref.read(supabaseStorageServiceProvider);
  final s3Storage = ref.read(s3StorageServiceProvider);
  
  // Use hybrid storage: S3 for videos, Supabase for thumbnails
  return HybridStorageService(
    primaryStorage: supabaseStorage,    // Supabase for thumbnails
    secondaryStorage: s3Storage,        // S3 for videos
    useSecondaryForVideos: true,
  );
});

// Alternative: Pure S3 Storage (if you want to move everything to S3)
final pureS3StorageProvider = Provider<StorageService>((ref) {
  return ref.read(s3StorageServiceProvider);
});

// Alternative: Pure Supabase Storage (current setup)
final pureSupabaseStorageProvider = Provider<StorageService>((ref) {
  return ref.read(supabaseStorageServiceProvider);
});

// Storage strategy selector
enum StorageStrategy { hybrid, pureS3, pureSupabase }

final storageStrategyProvider = StateProvider<StorageStrategy>((ref) {
  return StorageStrategy.hybrid; // Default to hybrid
});

// Dynamic storage provider based on strategy
final dynamicStorageProvider = Provider<StorageService>((ref) {
  final strategy = ref.watch(storageStrategyProvider);
  
  switch (strategy) {
    case StorageStrategy.hybrid:
      return ref.read(storageServiceProvider);
    case StorageStrategy.pureS3:
      return ref.read(pureS3StorageProvider);
    case StorageStrategy.pureSupabase:
      return ref.read(pureSupabaseStorageProvider);
  }
});