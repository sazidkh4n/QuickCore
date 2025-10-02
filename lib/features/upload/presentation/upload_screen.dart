import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../upload/providers/upload_provider.dart';
import 'dart:ui';

class UploadScreen extends ConsumerStatefulWidget {
  const UploadScreen({super.key});

  @override
  ConsumerState<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends ConsumerState<UploadScreen> {
  String? _fileName;
  PlatformFile? _pickedFile;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  String? _category;
  List<String> _tags = [];
  final List<String> _categories = [
    'Mathematics', 'Science', 'Programming', 'Language Learning', 'History',
    'Literature', 'Art & Design', 'Music', 'Business', 'Technology',
    'Health & Fitness', 'Cooking', 'Other'
  ];

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
      withData: true,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _pickedFile = result.files.first;
        _fileName = kIsWeb ? result.files.first.name : result.files.first.path;
      });
    }
  }

  bool get _canPublish {
    return _pickedFile != null &&
      _titleController.text.trim().isNotEmpty &&
      _descriptionController.text.trim().isNotEmpty &&
      _category != null;
  }

  void _addTag(String tag) {
    final cleanTag = tag.trim();
    if (cleanTag.isNotEmpty && !_tags.contains(cleanTag) && _tags.length < 10) {
      setState(() => _tags.add(cleanTag));
      _tagsController.clear();
    }
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  Future<void> _publish() async {
    final notifier = ref.read(uploadProvider.notifier);
    try {
      // Set video file/bytes in provider
      if (kIsWeb) {
        notifier.setVideoBytes(_pickedFile!.bytes!, _pickedFile!.name);
      } else {
        notifier.setVideoFile(File(_pickedFile!.path!));
      }
      notifier.updateDetails(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category,
        tags: _tags,
      );
      await notifier.uploadSkill();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload successful!')),
        );
        setState(() {
          _fileName = null;
          _pickedFile = null;
          _titleController.clear();
          _descriptionController.clear();
          _tagsController.clear();
          _category = null;
          _tags = [];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final uploadState = ref.watch(uploadProvider);
    final isUploading = uploadState.isExporting;
    final colorScheme = theme.colorScheme;
    final accent = colorScheme.secondary;
    final isTitleFilled = _titleController.text.trim().isNotEmpty;
    final isDescFilled = _descriptionController.text.trim().isNotEmpty;
    final isCatFilled = _category != null;
    final allFilled = isTitleFilled && isDescFilled && isCatFilled;
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Upload Educational Content'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Subtle animated background gradient
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.surface,
                    colorScheme.surfaceContainerHighest.withOpacity(0.7),
                    accent.withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Progress/stepper bar
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildStepCircle(1, allFilled || _pickedFile == null, accent),
                          _buildStepLine(allFilled, accent),
                          _buildStepCircle(2, allFilled, accent),
                        ],
                      ),
                    ),
                    // Modern glassmorphic upload card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: Container(
                          width: 400,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: colorScheme.surface.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: accent.withOpacity(0.18), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: accent.withOpacity(0.10),
                                blurRadius: 32,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: InkWell(
                            onTap: isUploading ? null : _pickVideo,
                            borderRadius: BorderRadius.circular(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Animated upload icon
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 600),
                                  curve: Curves.easeInOut,
                                  padding: EdgeInsets.all(_pickedFile == null ? 0 : 8),
                                  child: Icon(
                                    Icons.cloud_upload_rounded,
                                    size: 72,
                                    color: accent.withOpacity(_pickedFile == null ? 0.7 : 1),
                                    shadows: [
                                      Shadow(
                                        color: accent.withOpacity(0.3),
                                        blurRadius: 24,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _pickedFile == null ? 'Tap to select video' : 'Selected: ${_pickedFile!.name}',
                                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, fontFamily: 'Inter'),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Maximum 60 seconds • 100MB',
                                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
                                ),
                                const SizedBox(height: 8),
                                if (isUploading) const CircularProgressIndicator(),
                                if (_pickedFile == null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Text(
                                      'Videos help learners grasp concepts quickly!',
                                      style: theme.textTheme.bodySmall?.copyWith(color: accent, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Requirements/info with animated checkmarks
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: accent.withOpacity(0.18)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info_outline, color: accent, size: 22),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Requirements',
                                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: accent, fontFamily: 'Inter'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              _buildAnimatedRequirement('Video duration: Maximum 60 seconds', _pickedFile != null, accent),
                              _buildAnimatedRequirement('File size: Maximum 100MB', _pickedFile != null, accent),
                              _buildAnimatedRequirement('Format: MP4, MOV, AVI', _pickedFile != null, accent),
                              _buildAnimatedRequirement('Quality: HD recommended', _pickedFile != null, accent),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (_pickedFile != null) ...[
                      const SizedBox(height: 32),
                      // Glassmorphic details card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            width: 400,
                            padding: const EdgeInsets.all(28),
                            decoration: BoxDecoration(
                              color: colorScheme.surface.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: accent.withOpacity(0.10),
                                  blurRadius: 24,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Video Details', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontFamily: 'Inter')),
                                const SizedBox(height: 20),
                                TextField(
                                  controller: _titleController,
                                  enabled: !isUploading,
                                  style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w600),
                                  decoration: InputDecoration(
                                    labelText: 'Title *',
                                    border: const OutlineInputBorder(),
                                    hintText: 'Enter a compelling title',
                                    helperText: isTitleFilled ? 'Great title! Learners love clear names.' : 'A clear title helps learners find your video.',
                                    helperStyle: TextStyle(color: isTitleFilled ? Colors.greenAccent.shade400 : accent),
                                    suffixIcon: isTitleFilled ? const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20) : null,
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _descriptionController,
                                  enabled: !isUploading,
                                  maxLines: 3,
                                  style: const TextStyle(fontFamily: 'Inter'),
                                  decoration: InputDecoration(
                                    labelText: 'Description *',
                                    border: const OutlineInputBorder(),
                                    hintText: 'Describe your video',
                                    helperText: isDescFilled ? 'Awesome! A good description boosts engagement.' : 'Describe what learners will gain.',
                                    helperStyle: TextStyle(color: isDescFilled ? Colors.greenAccent.shade400 : accent),
                                    suffixIcon: isDescFilled ? const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20) : null,
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  value: _category,
                                  decoration: InputDecoration(
                                    labelText: 'Category *',
                                    border: const OutlineInputBorder(),
                                    helperText: isCatFilled ? 'Perfect! Helps learners discover your content.' : 'Pick the most relevant category.',
                                    helperStyle: TextStyle(color: isCatFilled ? Colors.greenAccent.shade400 : accent),
                                    suffixIcon: isCatFilled ? const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20) : null,
                                  ),
                                  items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                                  onChanged: isUploading ? null : (val) => setState(() => _category = val),
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: _tagsController,
                                  enabled: !isUploading,
                                  style: const TextStyle(fontFamily: 'Inter'),
                                  decoration: InputDecoration(
                                    labelText: 'Add Tag',
                                    border: const OutlineInputBorder(),
                                    suffixIcon: IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: isUploading ? null : () => _addTag(_tagsController.text),
                                    ),
                                  ),
                                  onSubmitted: isUploading ? null : _addTag,
                                ),
                                if (_tags.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    children: _tags.map((tag) => Chip(
                                      label: Text(tag, style: const TextStyle(fontFamily: 'Inter')),
                                      backgroundColor: accent.withOpacity(0.15),
                                      deleteIcon: const Icon(Icons.close, size: 18),
                                      onDeleted: isUploading ? null : () => _removeTag(tag),
                                    )).toList(),
                                  ),
                                ],
                                const SizedBox(height: 28),
                                // Stunning publish button
                                SizedBox(
                                  width: double.infinity,
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [accent, accent.withOpacity(0.7), colorScheme.primary],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: accent.withOpacity(0.25),
                                          blurRadius: 16,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _canPublish && !isUploading ? _publish : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        padding: const EdgeInsets.symmetric(vertical: 18),
                                        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                      child: isUploading
                                          ? const SizedBox(
                                              height: 22,
                                              width: 22,
                                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                            )
                                          : const Text('Publish', style: TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 96),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, bool active, Color accent) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: active ? accent : accent.withOpacity(0.18),
        shape: BoxShape.circle,
        boxShadow: [
          if (active)
            BoxShadow(
              color: accent.withOpacity(0.18),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Center(
        child: Text('$step', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStepLine(bool active, Color accent) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: active ? accent : accent.withOpacity(0.18),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildAnimatedRequirement(String text, bool met, Color accent) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, top: 6),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: met
                ? Icon(Icons.check_circle, size: 18, color: Colors.greenAccent.shade400, key: const ValueKey('met'))
                : Icon(Icons.radio_button_unchecked, size: 18, color: accent, key: const ValueKey('unmet')),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 15, color: accent, fontFamily: 'Inter'),
            ),
          ),
        ],
      ),
    );
  }
} 