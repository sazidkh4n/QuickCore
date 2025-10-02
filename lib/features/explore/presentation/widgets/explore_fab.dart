import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';

class ExploreFAB extends StatefulWidget {
  const ExploreFAB({super.key});

  @override
  State<ExploreFAB> createState() => _ExploreFABState();
}

class _ExploreFABState extends State<ExploreFAB> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _rotationController;
  late Animation<double> _animation;
  late Animation<double> _rotationAnimation;

  bool _isExpanded = false;

  final List<FABAction> _actions = [
    FABAction(
      icon: Icons.camera_alt_rounded,
      label: 'Create Video',
      color: Colors.red,
      onTap: (context) => context.push('/upload'),
    ),
    FABAction(
      icon: Icons.live_tv_rounded,
      label: 'Go Live',
      color: Colors.purple,
      onTap: (context) => context.push('/live'),
    ),
    FABAction(
      icon: Icons.article_rounded,
      label: 'Write Article',
      color: Colors.blue,
      onTap: (context) => context.push('/article/create'),
    ),
    FABAction(
      icon: Icons.group_rounded,
      label: 'Join Community',
      color: Colors.green,
      onTap: (context) => context.push('/community'),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _rotationAnimation =
        Tween<double>(
          begin: 0.0,
          end: 0.125, // 45 degrees
        ).animate(
          CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _animationController.forward();
      _rotationController.forward();
    } else {
      _animationController.reverse();
      _rotationController.reverse();
    }

    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Backdrop
        if (_isExpanded)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggle,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Container(
                    color: Colors.black.withOpacity(0.3 * _animation.value),
                  );
                },
              ),
            ),
          ),

        // Action buttons
        ...List.generate(_actions.length, (index) {
          return AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final offset = (index + 1) * 70.0;
              return Transform.translate(
                offset: Offset(0, -offset * _animation.value),
                child: Transform.scale(
                  scale: _animation.value,
                  child: Opacity(
                    opacity: _animation.value,
                    child: _buildActionButton(
                      _actions[index],
                      colorScheme,
                      theme,
                    ),
                  ),
                ),
              );
            },
          );
        }),

        // Main FAB
        AnimatedBuilder(
          animation: _rotationAnimation,
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationAnimation.value * 2 * 3.14159,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colorScheme.primary, colorScheme.secondary],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: _toggle,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _isExpanded ? Icons.close_rounded : Icons.add_rounded,
                      key: ValueKey(_isExpanded),
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
    FABAction action,
    ColorScheme colorScheme,
    ThemeData theme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              action.label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Action button
          Container(
            decoration: BoxDecoration(
              color: action.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: action.color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton(
              mini: true,
              onPressed: () {
                _toggle();
                action.onTap(context);
                HapticFeedback.mediumImpact();
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Icon(action.icon, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class FABAction {
  final IconData icon;
  final String label;
  final Color color;
  final Function(BuildContext) onTap;

  FABAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
