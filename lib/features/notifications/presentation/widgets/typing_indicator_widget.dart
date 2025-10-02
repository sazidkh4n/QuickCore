import 'package:flutter/material.dart';
import 'package:quickcore/features/notifications/data/simple_enhanced_chat_repository.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TypingIndicatorWidget extends StatefulWidget {
  final List<TypingIndicator> indicators;

  const TypingIndicatorWidget({
    super.key,
    required this.indicators,
  });

  @override
  State<TypingIndicatorWidget> createState() => _TypingIndicatorWidgetState();
}

class _TypingIndicatorWidgetState extends State<TypingIndicatorWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
    
    if (widget.indicators.isNotEmpty) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TypingIndicatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.indicators.isNotEmpty && oldWidget.indicators.isEmpty) {
      _animationController.forward();
    } else if (widget.indicators.isEmpty && oldWidget.indicators.isNotEmpty) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.indicators.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // User avatars
              SizedBox(
                height: 24,
                child: Stack(
                  children: widget.indicators.take(3).map((indicator) {
                    final index = widget.indicators.indexOf(indicator);
                    return Positioned(
                      left: index * 16.0,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.colorScheme.surface,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                          child: Icon(
                            Icons.person,
                            size: 12,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              SizedBox(width: widget.indicators.length > 1 ? 40 : 16),
              
              // Typing indicator bubble
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getTypingText(),
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _TypingDots(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTypingText() {
    if (widget.indicators.isEmpty) return '';
    
    if (widget.indicators.length == 1) {
      return '${widget.indicators.first.userName} is typing';
    } else if (widget.indicators.length == 2) {
      return '${widget.indicators.first.userName} and ${widget.indicators.last.userName} are typing';
    } else {
      return '${widget.indicators.first.userName} and ${widget.indicators.length - 1} others are typing';
    }
  }
}

class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    
    _controllers = List.generate(3, (index) {
      return AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
    });
    
    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();
    
    _startAnimations();
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _controllers[i].repeat(reverse: true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              child: Opacity(
                opacity: 0.4 + (_animations[index].value * 0.6),
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}