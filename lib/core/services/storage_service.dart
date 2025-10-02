import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 's3_service.dart';

enum StorageProvider { supabase, s3 }

abstract class StorageService {
  Future<String> uploadFile({
    required String path,
    required dynamic data,
    required String contentType,
    Function(double)? onProgress,
  });
  
  Future<bool> deleteFile(String path);
  String getPublicUrl(String path);
}

class SupabaseStorageService implements StorageService {
  final SupabaseClient client;
  final String bucketName;

  SupabaseStorageService({
    required this.client,
    required this.bucketName,
  });

  @override
  Future<String> uploadFile({
    required String path,
    required dynamic data,
    required String contentType,
    Function(double)? onProgress,
  }) async {
    if (data is File) {
      await client.storage.from(bucketName).upload(path, data);
    } else if (data is Uint8List) {
      await client.storage.from(bucketName).uploadBinary(
        path,
        data,
        fileOptions: FileOptions(contentType: contentType),
      );
    } else {
      throw ArgumentError('Unsupported data type for Supabase upload');
    }
    
    return client.storage.from(bucketName).getPublicUrl(path);
  }

  @override
  Future<bool> deleteFile(String path) async {
    try {
      await client.storage.from(bucketName).remove([path]);
      return true;
    } catch (e) {
      print('Supabase delete error: $e');
      return false;
    }
  }

  @override
  String getPublicUrl(String path) {
    return client.storage.from(bucketName).getPublicUrl(path);
  }
}

class S3StorageService implements StorageService {
  final S3Service s3Service;

  S3StorageService(this.s3Service);

  @override
  Future<String> uploadFile({
    required String path,
    required dynamic data,
    required String contentType,
    Function(double)? onProgress,
  }) async {
    return await s3Service.uploadFile(
      key: path,
      data: data,
      contentType: contentType,
      onProgress: onProgress,
    );
  }

  @override
  Future<bool> deleteFile(String path) async {
    return await s3Service.deleteFile(path);
  }

  @override
  String getPublicUrl(String path) {
    return s3Service.getPublicUrl(path);
  }
}

class HybridStorageService implements StorageService {
  final StorageService primaryStorage;
  final StorageService secondaryStorage;
  final bool useSecondaryForVideos;

  HybridStorageService({
    required this.primaryStorage,
    required this.secondaryStorage,
    this.useSecondaryForVideos = true,
  });

  StorageService _getStorageForFile(String path, String contentType) {
    // Use S3 for videos to save on egress costs
    if (useSecondaryForVideos && contentType.startsWith('video/')) {
      return secondaryStorage;
    }
    // Use Supabase for thumbnails and other small files
    return primaryStorage;
  }

  @override
  Future<String> uploadFile({
    required String path,
    required dynamic data,
    required String contentType,
    Function(double)? onProgress,
  }) async {
    final storage = _getStorageForFile(path, contentType);
    return await storage.uploadFile(
      path: path,
      data: data,
      contentType: contentType,
      onProgress: onProgress,
    );
  }

  @override
  Future<bool> deleteFile(String path) async {
    // Try both storages since we don't know which one has the file
    final results = await Future.wait([
      primaryStorage.deleteFile(path),
      secondaryStorage.deleteFile(path),
    ]);
    return results.any((result) => result);
  }

  @override
  String getPublicUrl(String path) {
    // This is tricky - we need to know which storage has the file
    // For now, assume videos are in secondary storage
    if (path.contains('video') || path.endsWith('.mp4') || path.endsWith('.mov')) {
      return secondaryStorage.getPublicUrl(path);
    }
    return primaryStorage.getPublicUrl(path);
  }
}