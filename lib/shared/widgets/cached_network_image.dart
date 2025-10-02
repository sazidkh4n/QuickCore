import 'package:flutter/material.dart';
import 'dart:developer' as dev;

class SafeNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget? errorWidget;
  
  const SafeNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorWidget,
  });
  
  @override
  Widget build(BuildContext context) {
    // Default placeholder
    final defaultPlaceholder = Container(
      color: Colors.grey.shade800,
      child: const Center(
        child: Icon(
          Icons.video_library,
          color: Colors.white70,
          size: 36,
        ),
      ),
    );
    
    // Default error widget
    final defaultErrorWidget = Container(
      color: Colors.grey.shade800,
      child: const Center(
        child: Icon(
          Icons.broken_image,
          color: Colors.white70,
          size: 36,
        ),
      ),
    );
    
    // If URL is null or empty, return placeholder
    if (imageUrl == null || imageUrl!.isEmpty) {
      dev.log('Image URL is null or empty');
      return SizedBox(
        width: width,
        height: height,
        child: placeholder ?? defaultPlaceholder,
      );
    }
    
    // Handle invalid URLs
    if (!Uri.parse(imageUrl!).isAbsolute) {
      dev.log('Invalid image URL: $imageUrl');
      return SizedBox(
        width: width,
        height: height,
        child: errorWidget ?? defaultErrorWidget,
      );
    }
    
    // Use a placeholder URL if the URL is encoded bytes
    if (imageUrl!.contains('encoded image bytes')) {
      dev.log('Replacing encoded image bytes URL with placeholder');
      return SizedBox(
        width: width,
        height: height,
        child: Image.network(
          'https://via.placeholder.com/400x225?text=Video+Thumbnail',
          fit: fit,
          width: width,
          height: height,
          errorBuilder: (context, error, stackTrace) {
            dev.log('Error loading placeholder image: $error');
            return errorWidget ?? defaultErrorWidget;
          },
        ),
      );
    }
    
    // Try to load the network image with error handling
    return SizedBox(
      width: width,
      height: height,
      child: Image.network(
        imageUrl!,
        fit: fit,
        width: width,
        height: height,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ?? defaultPlaceholder;
        },
        errorBuilder: (context, error, stackTrace) {
          dev.log('Error loading image from URL $imageUrl: $error');
          // Try a fallback placeholder
          return Image.network(
            'https://via.placeholder.com/400x225?text=Video+Thumbnail',
            fit: fit,
            width: width,
            height: height,
            errorBuilder: (context, error, stackTrace) {
              return errorWidget ?? defaultErrorWidget;
            },
          );
        },
      ),
    );
  }
} 