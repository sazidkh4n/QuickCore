# Skeleton Loader System

A comprehensive, professional skeleton loader system for the QuickCore Flutter app. This system provides various skeleton types with smooth animations, staggered loading effects, and a consistent design language.

## Features

- **Multiple Skeleton Types**: Feed, card, list, profile, chat, explore, and upload layouts
- **Professional Animations**: Shimmer effects, pulse animations, and staggered loading
- **Consistent Design**: Dark theme with professional color scheme
- **Performance Optimized**: Efficient animations and memory management
- **Reusable Components**: Modular design for easy customization
- **Accessibility Support**: Proper semantics and screen reader support

## Color Scheme

The skeleton loader uses a professional dark theme color palette:

```dart
// Primary colors
Color(0xFF000000)  // Pure black background
Color(0xFF1A1A1A)  // Dark gray containers
Color(0xFF2A2A2A)  // Medium gray elements
Color(0xFF404040)  // Light gray highlights
Color(0xFF606060)  // Text placeholders
```

## Animation Specifications

### Shimmer Effect
- **Duration**: 1.5 seconds
- **Curve**: `Curves.easeInOut`
- **Base Color**: `Color(0xFF2A2A2A)`
- **Highlight Color**: `Color(0xFF404040)`

### Pulse Animation
- **Duration**: 2.0 seconds
- **Scale Range**: 0.95x to 1.05x
- **Curve**: `Curves.easeInOut`
- **Reverse**: Enabled for smooth back-and-forth motion

### Staggered Loading
- **Duration**: 600ms per element
- **Delay**: 100ms intervals between elements
- **Curve**: `Curves.easeOut`
- **Fade-in**: Smooth opacity transitions

## Usage

### Basic Usage

```dart
import 'package:your_app/shared/widgets/skeleton_loader.dart';

// Feed skeleton loader
SkeletonLoader(
  type: SkeletonType.feed,
  itemCount: 3,
)

// Profile skeleton loader
SkeletonLoader(
  type: SkeletonType.profile,
  itemCount: 5,
)
```

### Advanced Usage

```dart
SkeletonLoader(
  type: SkeletonType.card,
  itemCount: 4,
  width: double.infinity,
  height: 400,
  padding: EdgeInsets.all(16),
  showShimmer: true,
)
```

## Skeleton Types

### 1. Feed (`SkeletonType.feed`)
Perfect for TikTok/Instagram-style video feeds.

```dart
SkeletonLoader(
  type: SkeletonType.feed,
  itemCount: 3,
)
```

**Features:**
- Full-screen video layout
- Side action buttons (like, comment, share)
- Bottom content overlay
- Top navigation tabs
- Center play button

### 2. Card (`SkeletonType.card`)
Ideal for social media posts and content cards.

```dart
SkeletonLoader(
  type: SkeletonType.card,
  itemCount: 4,
)
```

**Features:**
- Card-based layout
- Avatar and user info
- Content area
- Action buttons
- Staggered loading

### 3. List (`SkeletonType.list`)
Perfect for user lists, notifications, and simple content.

```dart
SkeletonLoader(
  type: SkeletonType.list,
  itemCount: 10,
)
```

**Features:**
- Simple list layout
- Avatar and text content
- Quick loading with minimal delay

### 4. Profile (`SkeletonType.profile`)
Designed for user profile screens.

```dart
SkeletonLoader(
  type: SkeletonType.profile,
  itemCount: 5,
)
```

**Features:**
- Large profile avatar
- User stats (posts, followers, following)
- Content grid
- Bio information

### 5. Chat (`SkeletonType.chat`)
Optimized for messaging interfaces.

```dart
SkeletonLoader(
  type: SkeletonType.chat,
  itemCount: 8,
)
```

**Features:**
- Alternating message bubbles
- Avatar support
- Message text placeholders
- Chat-like layout

### 6. Explore (`SkeletonType.explore`)
Grid-based layout for discovery screens.

```dart
SkeletonLoader(
  type: SkeletonType.explore,
  itemCount: 6,
)
```

**Features:**
- Grid layout (2 columns)
- Image placeholders
- Title and subtitle
- Consistent spacing

### 7. Upload (`SkeletonType.upload`)
Designed for content creation screens.

```dart
SkeletonLoader(
  type: SkeletonType.upload,
  itemCount: 3,
)
```

**Features:**
- Upload area placeholder
- Form fields
- Action buttons
- Progress indicators

## Reusable Components

### SkeletonText
```dart
SkeletonText(
  width: 120,
  height: 16,
  borderRadius: 8.0,
  margin: EdgeInsets.only(bottom: 8),
)
```

### SkeletonCircle
```dart
SkeletonCircle(
  size: 40,
  margin: EdgeInsets.only(right: 12),
)
```

### SkeletonRectangle
```dart
SkeletonRectangle(
  width: double.infinity,
  height: 200,
  borderRadius: 12.0,
  margin: EdgeInsets.all(16),
)
```

### PulseAnimation
```dart
PulseAnimation(
  duration: Duration(milliseconds: 2000),
  minScale: 0.95,
  maxScale: 1.05,
  child: SkeletonCircle(size: 80),
)
```

## Integration Examples

### Feed Screen Integration
```dart
class FeedScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(feedProvider);
    
    return feedAsync.when(
      data: (feed) => FeedContent(feed: feed),
      loading: () => const SkeletonLoader(
        type: SkeletonType.feed,
        itemCount: 3,
      ),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

### Profile Screen Integration
```dart
class ProfileScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    
    return profileAsync.when(
      data: (profile) => ProfileContent(profile: profile),
      loading: () => const SkeletonLoader(
        type: SkeletonType.profile,
        itemCount: 5,
      ),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

### Chat Screen Integration
```dart
class ChatScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(messagesProvider);
    
    return messagesAsync.when(
      data: (messages) => ChatContent(messages: messages),
      loading: () => const SkeletonLoader(
        type: SkeletonType.chat,
        itemCount: 8,
      ),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

## Customization

### Custom Color Scheme
```dart
// Override shimmer colors
Shimmer.fromColors(
  baseColor: const Color(0xFF1A1A1A),
  highlightColor: const Color(0xFF404040),
  child: YourWidget(),
)
```

### Custom Animation Timing
```dart
// In your custom skeleton widget
AnimationController(
  duration: const Duration(milliseconds: 1500), // Custom duration
  vsync: this,
)
```

### Custom Stagger Delays
```dart
// Custom stagger implementation
final delay = index * 150.0; // Custom delay
final progress = (_staggerAnimation.value * 1000 - delay) / 600;
```

## Performance Considerations

1. **Memory Management**: Always dispose of animation controllers
2. **Widget Reuse**: Use `const` constructors where possible
3. **Animation Optimization**: Limit concurrent animations
4. **Image Caching**: Use cached network images for real content
5. **Lazy Loading**: Load skeleton only when needed

## Best Practices

1. **Consistent Timing**: Use the same animation durations across the app
2. **Proper Spacing**: Follow the 8dp, 12dp, 16dp spacing grid
3. **Accessibility**: Add semantics labels for screen readers
4. **Error Handling**: Provide fallback content for error states
5. **Testing**: Test on different screen sizes and orientations

## Demo

Use the `SkeletonDemoScreen` to test all skeleton types:

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const SkeletonDemoScreen(),
  ),
);
```

## Dependencies

Make sure you have the following dependencies in your `pubspec.yaml`:

```yaml
dependencies:
  shimmer: ^3.0.0
  google_fonts: ^6.2.1
```

## Troubleshooting

### Common Issues

1. **Animation not working**: Check if `showShimmer` is enabled
2. **Memory leaks**: Ensure animation controllers are disposed
3. **Performance issues**: Reduce item count or disable shimmer
4. **Layout issues**: Check parent widget constraints

### Debug Mode

Enable debug mode to see skeleton boundaries:

```dart
SkeletonLoader(
  type: SkeletonType.feed,
  itemCount: 3,
  showShimmer: true,
  // Add debug paint if needed
)
```

## Contributing

When adding new skeleton types:

1. Add the new type to the `SkeletonType` enum
2. Implement the build method in `_buildSkeletonByType()`
3. Add proper documentation
4. Include usage examples
5. Test on different screen sizes

## License

This skeleton loader system is part of the QuickCore app and follows the same licensing terms. 