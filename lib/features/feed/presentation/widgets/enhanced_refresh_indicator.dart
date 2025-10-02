import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EnhancedRefreshIndicator extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color? color;
  final Color? backgroundColor;
  final double displacement;
  final double strokeWidth;
  final String? lastUpdatedText;

  const EnhancedRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color,
    this.backgroundColor,
    this.displacement = 40.0,
    this.strokeWidth = 2.0,
    this.lastUpdatedText,
  });

  @override
  State<EnhancedRefreshIndicator> createState() => _EnhancedRefreshIndicatorState();
}

class _EnhancedRefreshIndicatorState extends State<EnhancedRefreshIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isRefreshing = true;
    });
    
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    // Start animation
    _animationController.forward();
    
    try {
      await widget.onRefresh();
      
      // Success haptic feedback
      HapticFeedback.mediumImpact();
    } catch (e) {
      // Error haptic feedback
      HapticFeedback.heavyImpact();
    } finally {
      // Reverse animation
      _animationController.reverse();
      
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: widget.color ?? Theme.of(context).colorScheme.primary,
      backgroundColor: widget.backgroundColor ?? Colors.black.withOpacity(0.8),
      displacement: widget.displacement,
      strokeWidth: widget.strokeWidth,
      child: Stack(
        children: [
          widget.child,
          // Last updated indicator
          if (widget.lastUpdatedText != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedBuilder(
                              animation: _rotationAnimation,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _rotationAnimation.value * 2 * 3.14159,
                                  child: const Icon(
                                    Icons.refresh,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.lastUpdatedText!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CustomRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final String? lastUpdatedText;

  const CustomRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.lastUpdatedText,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedRefreshIndicator(
      onRefresh: onRefresh,
      lastUpdatedText: lastUpdatedText,
      child: child,
    );
  }
} 