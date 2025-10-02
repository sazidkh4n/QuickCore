import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'dart:developer' as dev;

// Global video controller manager
class GlobalVideoController
    extends StateNotifier<Map<String, VideoPlayerController>> {
  GlobalVideoController() : super({});

  String? _lastActiveVideoId;
  bool _shouldAutoResume = false;
  String? _currentScreen = 'feed';

  // Register a video controller
  void registerController(String videoId, VideoPlayerController controller) {
    // Check for any duplicate registration
    if (state.containsKey(videoId)) {
      try {
        final oldController = state[videoId];
        if (oldController != null && oldController != controller && oldController.value.isInitialized) {
          oldController.pause();
          oldController.dispose();
          dev.log('Disposed duplicate controller for: $videoId');
        }
      } catch (e) {
        dev.log('Error cleaning up old controller: $e');
      }
    }
    state = {...state, videoId: controller};
    dev.log('Registered video controller for: $videoId');
  }

  // Unregister a video controller
  void unregisterController(String videoId) {
    try {
      final newState = Map<String, VideoPlayerController>.from(state);
      newState.remove(videoId);
      state = newState;
      dev.log('Unregistered video controller for: $videoId');
      
      // If this was the last active video, clear state
      if (_lastActiveVideoId == videoId) {
        _lastActiveVideoId = null;
        _shouldAutoResume = false;
      }
    } catch (e) {
      dev.log('Error unregistering controller: $e');
    }
  }

  // Set current screen context
  void setCurrentScreen(String screenName) {
    _currentScreen = screenName;
    dev.log('Current screen: $screenName');
  }

  // Pause all videos with context
  void pauseAllVideos({String? reason}) {
    dev.log(
      'Pausing all videos (${state.length} controllers) - Reason: $reason',
    );

    // Remember the currently playing video for potential resume
    for (final entry in state.entries) {
      if (entry.value.value.isInitialized && entry.value.value.isPlaying) {
        _lastActiveVideoId = entry.key;
        _shouldAutoResume = reason == 'navigation_to_profile';
        dev.log(
          'Remembered active video: ${entry.key}, shouldAutoResume: $_shouldAutoResume',
        );
        break;
      }
    }

    for (final controller in state.values) {
      if (controller.value.isInitialized && controller.value.isPlaying) {
        controller.pause();
      }
    }
  }

  // Pause all videos without auto-resume (for manual actions)
  void pauseAllVideosManually() {
    dev.log('Manually pausing all videos - no auto-resume');
    _shouldAutoResume = false;
    _lastActiveVideoId = null;

    for (final controller in state.values) {
      if (controller.value.isInitialized && controller.value.isPlaying) {
        controller.pause();
      }
    }
  }

  // Resume video only if conditions are met
  void resumeVideoIfAppropriate(String? currentVideoId) {
    // Only resume if we're on the feed screen and auto-resume is enabled
    if (_currentScreen != 'feed' ||
        !_shouldAutoResume ||
        _lastActiveVideoId == null) {
      dev.log(
        'Not resuming - screen: $_currentScreen, shouldAutoResume: $_shouldAutoResume, lastActiveId: $_lastActiveVideoId',
      );
      return;
    }

    // If a specific video ID is provided, use that, otherwise use the last active one
    final videoIdToResume = currentVideoId ?? _lastActiveVideoId;
    if (videoIdToResume == null) return;

    final controller = state[videoIdToResume];
    if (controller != null &&
        controller.value.isInitialized &&
        !controller.value.isPlaying) {
      controller.play();
      dev.log('Resumed video: $videoIdToResume');

      // Reset auto-resume flag after successful resume
      _shouldAutoResume = false;
      _lastActiveVideoId = null;
    }
  }

  // Resume a specific video (direct control)
  void resumeVideo(String videoId) {
    final controller = state[videoId];
    if (controller != null &&
        controller.value.isInitialized &&
        !controller.value.isPlaying) {
      controller.play();
      dev.log('Directly resumed video: $videoId');
    }
  }

  // Get controller for a specific video
  VideoPlayerController? getController(String videoId) {
    return state[videoId];
  }

  // Check if any video is playing
  bool get hasPlayingVideo {
    return state.values.any(
      (controller) =>
          controller.value.isInitialized && controller.value.isPlaying,
    );
  }

  // Clear auto-resume state
  void clearAutoResumeState() {
    _shouldAutoResume = false;
    _lastActiveVideoId = null;
    dev.log('Cleared auto-resume state');
  }

  // Ensure only one video plays at a time
  void ensureSingleVideoPlaying(String activeVideoId) {
    try {
      for (final entry in state.entries) {
        final videoId = entry.key;
        final controller = entry.value;
        
        if (videoId != activeVideoId && 
            controller.value.isInitialized && 
            controller.value.isPlaying) {
          controller.pause();
          dev.log('Paused video $videoId to ensure only $activeVideoId is playing');
        }
      }
    } catch (e) {
      dev.log('Error in ensureSingleVideoPlaying: $e');
    }
  }
}

// Provider for the global video controller
final globalVideoControllerProvider =
    StateNotifierProvider<
      GlobalVideoController,
      Map<String, VideoPlayerController>
    >((ref) {
      return GlobalVideoController();
    });

// Helper provider to access the notifier
final videoControllerNotifierProvider = Provider<GlobalVideoController>((ref) {
  return ref.read(globalVideoControllerProvider.notifier);
});
