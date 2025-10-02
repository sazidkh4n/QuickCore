import 'package:flutter/material.dart';
import 'skeleton_loader.dart';

/// Demonstration screen showing all available skeleton loader types
/// This can be used for testing and as a reference for implementation

class SkeletonDemoScreen extends StatefulWidget {
  const SkeletonDemoScreen({super.key});

  @override
  State<SkeletonDemoScreen> createState() => _SkeletonDemoScreenState();
}

class _SkeletonDemoScreenState extends State<SkeletonDemoScreen> {
  SkeletonType _selectedType = SkeletonType.feed;
  int _itemCount = 3;
  bool _showShimmer = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Skeleton Loader Demo',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildControls(),
          Expanded(
            child: _buildSkeletonDemo(),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFF1A1A1A),
      child: Column(
        children: [
          // Skeleton type selector
          Row(
            children: [
              const Text(
                'Type: ',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButton<SkeletonType>(
                  value: _selectedType,
                  dropdownColor: const Color(0xFF2A2A2A),
                  style: const TextStyle(color: Colors.white),
                  underline: Container(
                    height: 2,
                    color: const Color(0xFF404040),
                  ),
                  onChanged: (SkeletonType? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedType = newValue;
                      });
                    }
                  },
                  items: SkeletonType.values.map<DropdownMenuItem<SkeletonType>>((SkeletonType type) {
                    return DropdownMenuItem<SkeletonType>(
                      value: type,
                      child: Text(type.name.toUpperCase()),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Item count slider
          Row(
            children: [
              const Text(
                'Items: ',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Slider(
                  value: _itemCount.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: const Color(0xFF404040),
                  inactiveColor: const Color(0xFF2A2A2A),
                  onChanged: (double value) {
                    setState(() {
                      _itemCount = value.round();
                    });
                  },
                ),
              ),
              Text(
                '$_itemCount',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          
          // Shimmer toggle
          Row(
            children: [
              const Text(
                'Shimmer: ',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(width: 8),
              Switch(
                value: _showShimmer,
                activeColor: const Color(0xFF404040),
                onChanged: (bool value) {
                  setState(() {
                    _showShimmer = value;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonDemo() {
    return SkeletonLoader(
      type: _selectedType,
      itemCount: _itemCount,
      showShimmer: _showShimmer,
    );
  }
}

/// Example usage in different screens
class SkeletonUsageExamples {
  
  /// Example: Feed screen loading
  static Widget feedLoadingExample() {
    return const SkeletonLoader(
      type: SkeletonType.feed,
      itemCount: 3,
    );
  }
  
  /// Example: Profile screen loading
  static Widget profileLoadingExample() {
    return const SkeletonLoader(
      type: SkeletonType.profile,
      itemCount: 5,
    );
  }
  
  /// Example: Chat screen loading
  static Widget chatLoadingExample() {
    return const SkeletonLoader(
      type: SkeletonType.chat,
      itemCount: 8,
    );
  }
  
  /// Example: Explore screen loading
  static Widget exploreLoadingExample() {
    return const SkeletonLoader(
      type: SkeletonType.explore,
      itemCount: 6,
    );
  }
  
  /// Example: Upload screen loading
  static Widget uploadLoadingExample() {
    return const SkeletonLoader(
      type: SkeletonType.upload,
      itemCount: 3,
    );
  }
  
  /// Example: Card list loading
  static Widget cardListExample() {
    return const SkeletonLoader(
      type: SkeletonType.card,
      itemCount: 4,
    );
  }
  
  /// Example: Simple list loading
  static Widget simpleListExample() {
    return const SkeletonLoader(
      type: SkeletonType.list,
      itemCount: 10,
    );
  }
}

/// Custom skeleton for specific use cases
class CustomSkeletonExample extends StatelessWidget {
  const CustomSkeletonExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header with avatar and text
          Row(
            children: [
              const SkeletonCircle(size: 50),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonText(width: 120, height: 16),
                    const SizedBox(height: 4),
                    const SkeletonText(width: 80, height: 12),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Content area
          const SkeletonRectangle(
            width: double.infinity,
            height: 200,
            borderRadius: 12,
          ),
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              const SkeletonCircle(size: 32),
              const SizedBox(width: 12),
              const SkeletonCircle(size: 32),
              const SizedBox(width: 12),
              const SkeletonCircle(size: 32),
              const Spacer(),
              const SkeletonText(width: 60, height: 16),
            ],
          ),
        ],
      ),
    );
  }
}

/// Pulse animation example
class PulseAnimationExample extends StatelessWidget {
  const PulseAnimationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: PulseAnimation(
        child: SkeletonCircle(size: 80),
      ),
    );
  }
} 