import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoTestWidget extends StatefulWidget {
  final String videoUrl;
  
  const VideoTestWidget({
    super.key,
    required this.videoUrl,
  });

  @override
  State<VideoTestWidget> createState() => _VideoTestWidgetState();
}

class _VideoTestWidgetState extends State<VideoTestWidget> {
  late VideoPlayerController _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      print('🎥 Testing video URL: ${widget.videoUrl}');
      
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      
      await _controller.initialize();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        print('✅ Video initialized successfully');
        print('📊 Video duration: ${_controller.value.duration}');
        print('📐 Video size: ${_controller.value.size}');
      }
    } catch (e) {
      print('❌ Video initialization failed: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Test'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Testing Video URL:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                widget.videoUrl,
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const SizedBox(height: 24),
            
            if (_isLoading)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading video...'),
                  ],
                ),
              )
            else if (_error != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '❌ Video Load Failed',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Error: $_error'),
                    const SizedBox(height: 16),
                    const Text(
                      'Possible Solutions:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Text('1. Check S3 bucket permissions'),
                    const Text('2. Verify CORS configuration'),
                    const Text('3. Ensure bucket policy allows public read'),
                    const Text('4. Test URL in browser first'),
                  ],
                ),
              )
            else
              Expanded(
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Video controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () {
                            if (_controller.value.isPlaying) {
                              _controller.pause();
                            } else {
                              _controller.play();
                            }
                            setState(() {});
                          },
                          icon: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _controller.seekTo(Duration.zero);
                          },
                          icon: const Icon(Icons.replay),
                        ),
                      ],
                    ),
                    
                    // Video info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '✅ Video Loaded Successfully!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Duration: ${_controller.value.duration}'),
                          Text('Size: ${_controller.value.size}'),
                          Text('Aspect Ratio: ${_controller.value.aspectRatio.toStringAsFixed(2)}'),
                        ],
                      ),
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

// Helper function to test a video URL
void testVideoUrl(BuildContext context, String videoUrl) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => VideoTestWidget(videoUrl: videoUrl),
    ),
  );
}