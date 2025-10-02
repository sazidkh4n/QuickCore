import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quickcore/features/auth/providers/auth_provider.dart';
import 'package:quickcore/features/feed/data/skill_model.dart';
import 'package:quickcore/core/providers/storage_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:video_editor/video_editor.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

// Represents the overall state of the upload process
class UploadState {
  final VideoEditorController? controller;
  final File? videoFile; // Mobile
  final Uint8List? videoBytes; // Web
  final String? videoFileName; // Web
  final bool isExporting;
  final double progress;
  final String? title;
  final String? description;
  final String? category;
  final List<String> tags;
  final Uint8List? thumbnail;

  UploadState({
    this.controller,
    this.videoFile,
    this.videoBytes,
    this.videoFileName,
    this.isExporting = false,
    this.progress = 0.0,
    this.title,
    this.description,
    this.category,
    this.tags = const [],
    this.thumbnail,
  });

  UploadState copyWith({
    VideoEditorController? controller,
    File? videoFile,
    Uint8List? videoBytes,
    String? videoFileName,
    bool? isExporting,
    double? progress,
    String? title,
    String? description,
    String? category,
    List<String>? tags,
    Uint8List? thumbnail,
    bool clearController = false,
  }) {
    return UploadState(
      controller: clearController ? null : controller ?? this.controller,
      videoFile: videoFile ?? this.videoFile,
      videoBytes: videoBytes ?? this.videoBytes,
      videoFileName: videoFileName ?? this.videoFileName,
      isExporting: isExporting ?? this.isExporting,
      progress: progress ?? this.progress,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }
}

// Manages the logic for the upload process
class UploadNotifier extends StateNotifier<UploadState> {
  final Ref ref;
  UploadNotifier(this.ref) : super(UploadState());

  void setVideoFile(File file) {
    if (kIsWeb) return;
    final controller = VideoEditorController.file(file, maxDuration: const Duration(seconds: 60));
    controller.initialize().then((_) {
      state = state.copyWith(videoFile: file, controller: controller);
    });
  }

  void setVideoBytes(Uint8List bytes, String name) {
    if (!kIsWeb) return;
    state = state.copyWith(videoBytes: bytes, videoFileName: name);
  }

  void updateDetails({String? title, String? description, String? category, List<String>? tags}) {
    state = state.copyWith(title: title, description: description, category: category, tags: tags);
  }
  
  void setThumbnail(Uint8List? thumbnailData) {
    state = state.copyWith(thumbnail: thumbnailData);
  }

  Future<void> uploadSkill() async {
    final s = state;
    if ((s.videoFile == null && s.videoBytes == null) || s.title == null || s.category == null) {
      throw Exception('Missing required information for upload.');
    }
    
    // For web, we don't require a thumbnail
    if (!kIsWeb && s.thumbnail == null) {
      throw Exception('Thumbnail is required for mobile uploads.');
    }

    state = state.copyWith(isExporting: true, progress: 0.0);
    
    final user = ref.read(authProvider).value;
    if (user == null) throw Exception('User not authenticated.');

    // Get the storage service (hybrid by default - S3 for videos, Supabase for thumbnails)
    final storageService = ref.read(dynamicStorageProvider);
    final client = Supabase.instance.client;
    
    final uuid = const Uuid().v4();
    
    // Get original filename and create safe paths
    String originalFileName = s.videoFileName ?? s.videoFile!.path.split('/').last;
    String extension = '';
    if (originalFileName.contains('.')) {
      extension = originalFileName.substring(originalFileName.lastIndexOf('.'));
    } else {
      extension = '.mp4'; // Default extension
    }
    
    final videoPath = '$uuid$extension';
    final thumbPath = '${uuid}_thumb.jpg';
    
    print('Starting upload process with new storage system...');
    print('Video path: $videoPath');
    print('Thumbnail path: $thumbPath');
    
    try {
      String videoUrl;
      String? thumbUrl;
      
      // Upload video file
      if (kIsWeb) {
        print('Web upload: Uploading video of size: ${s.videoBytes!.length} bytes');
        
        videoUrl = await storageService.uploadFile(
          path: videoPath,
          data: s.videoBytes!,
          contentType: 'video/mp4',
          onProgress: (progress) {
            state = state.copyWith(progress: progress * 0.6); // 60% for video upload
          },
        );
        
        print('Video uploaded successfully to: $videoUrl');
        
        // Generate a proper placeholder thumbnail for web
        try {
          final placeholderThumb = await _generateProperThumbnail();
          
          thumbUrl = await storageService.uploadFile(
            path: thumbPath,
            data: placeholderThumb,
            contentType: 'image/jpeg',
          );
          print('Placeholder thumbnail uploaded for web');
        } catch (e) {
          print('Failed to upload placeholder thumbnail: $e');
          thumbUrl = null;
        }
        
      } else {
        print('Mobile upload: Uploading video file: ${s.videoFile!.path}');
        
        videoUrl = await storageService.uploadFile(
          path: videoPath,
          data: s.videoFile!,
          contentType: 'video/mp4',
          onProgress: (progress) {
            state = state.copyWith(progress: progress * 0.6); // 60% for video upload
          },
        );
        
        print('Video uploaded successfully to: $videoUrl');
        
        // Upload the thumbnail if available, otherwise generate one
        if (s.thumbnail != null) {
          print('Uploading thumbnail of size: ${s.thumbnail!.length} bytes');
          try {
            thumbUrl = await storageService.uploadFile(
              path: thumbPath,
              data: s.thumbnail!,
              contentType: 'image/jpeg',
            );
            print('Thumbnail uploaded successfully to: $thumbUrl');
          } catch (e) {
            print('Failed to upload thumbnail: $e');
            thumbUrl = null;
          }
        } else {
          // Generate thumbnail from video file for mobile
          try {
            final generatedThumb = await _generateThumbnailFromVideo(s.videoFile!);
            if (generatedThumb != null) {
              thumbUrl = await storageService.uploadFile(
                path: thumbPath,
                data: generatedThumb,
                contentType: 'image/jpeg',
              );
              print('Generated thumbnail uploaded successfully');
            } else {
              // Fallback to placeholder
              final placeholderThumb = await _generateProperThumbnail();
              thumbUrl = await storageService.uploadFile(
                path: thumbPath,
                data: placeholderThumb,
                contentType: 'image/png',
              );
              print('Placeholder thumbnail uploaded for mobile');
            }
          } catch (e) {
            print('Failed to generate/upload thumbnail: $e');
            thumbUrl = null;
          }
        }
      }
      
      state = state.copyWith(progress: 0.8);

      // Create the skill model
      final newSkill = SkillModel(
        id: uuid,
        title: s.title!,
        description: s.description,
        videoUrl: videoUrl,
        thumbnailUrl: thumbUrl,
        creatorId: user.id,
        category: s.category!,
        tags: s.tags,
        createdAt: DateTime.now(),
      );

      print('Inserting skill into database: ${newSkill.id}');
      
      // Insert into Supabase database
      try {
        await client.from('skills').insert(newSkill.toJson());
        print('Skill inserted successfully');
      } catch (e) {
        print('Error inserting skill: $e');
        // Try a simpler approach with just the essential fields
        final Map<String, dynamic> essentialData = {
          'id': uuid,
          'title': s.title,
          'video_url': videoUrl,
          'creator_id': user.id,
          'category': s.category,
        };
        print('Trying with essential data only: $essentialData');
        await client.from('skills').insert(essentialData);
        print('Skill inserted with essential data only');
      }
      
      state = state.copyWith(isExporting: false, progress: 1.0);
      reset();
    } catch (e) {
      print('Error in uploadSkill: $e');
      state = state.copyWith(isExporting: false, progress: 0.0);
      rethrow;
    }
  }

  // Helper method to generate a proper placeholder thumbnail
  Future<Uint8List> _generateProperThumbnail() async {
    // Create a simple colored image using Flutter's painting system
    const int width = 300;
    const int height = 200;
    
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    
    // Draw a gradient background
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()));
    
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      paint,
    );
    
    // Draw a play button icon
    final playPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    final playPath = Path();
    final centerX = width / 2;
    final centerY = height / 2;
    final size = 40.0;
    
    playPath.moveTo(centerX - size / 3, centerY - size / 2);
    playPath.lineTo(centerX - size / 3, centerY + size / 2);
    playPath.lineTo(centerX + size / 2, centerY);
    playPath.close();
    
    canvas.drawPath(playPath, playPaint);
    
    // Draw text based on video title if available
    final videoTitle = (state.title?.isNotEmpty == true) ? state.title! : 'Educational Video';
    final displayText = videoTitle.length > 20 ? '${videoTitle.substring(0, 17)}...' : videoTitle;
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: displayText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: Offset(1, 1),
              blurRadius: 2,
              color: Colors.black54,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    
    textPainter.layout(maxWidth: width.toDouble() - 20);
    textPainter.paint(
      canvas,
      Offset(
        (width - textPainter.width) / 2,
        height - 25,
      ),
    );
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return byteData!.buffer.asUint8List();
  }

  // Helper method to generate thumbnail from video file (mobile only)
  Future<Uint8List?> _generateThumbnailFromVideo(File videoFile) async {
    if (kIsWeb) {
      print('Web platform: Cannot extract video thumbnails, using placeholder');
      return null;
    }
    
    try {
      print('🎬 Generating real thumbnail from video: ${videoFile.path}');
      
      final thumbnailData = await VideoThumbnail.thumbnailData(
        video: videoFile.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 300,
        maxHeight: 200,
        quality: 75,
        timeMs: 1000, // Get thumbnail at 1 second
      );
      
      if (thumbnailData != null) {
        print('✅ Real video thumbnail generated successfully, size: ${thumbnailData.length} bytes');
        return thumbnailData;
      } else {
        print('⚠️ Video thumbnail extraction returned null - using placeholder');
        return null;
      }
    } catch (e) {
      print('❌ Error generating thumbnail from video: $e');
      print('📱 Falling back to placeholder thumbnail');
      return null;
    }
  }

  void reset() {
    state.controller?.dispose();
    state = UploadState();
  }

  @override
  void dispose() {
    state.controller?.dispose();
    super.dispose();
  }
}

final uploadProvider = StateNotifierProvider.autoDispose<UploadNotifier, UploadState>((ref) {
  return UploadNotifier(ref);
}); 