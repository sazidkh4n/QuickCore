import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ChatInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSendMessage;
  final VoidCallback? onAttachmentTap;
  final VoidCallback? onVoiceMessageTap;
  final String hintText;
  final bool enabled;

  const ChatInputWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSendMessage,
    this.onAttachmentTap,
    this.onVoiceMessageTap,
    this.hintText = 'Type a message...',
    this.enabled = true,
  });

  @override
  State<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends State<ChatInputWidget>
    with TickerProviderStateMixin {
  late AnimationController _sendButtonController;
  late AnimationController _attachmentController;
  late Animation<double> _sendButtonAnimation;
  late Animation<double> _attachmentAnimation;
  
  bool _hasText = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    
    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _attachmentController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _sendButtonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sendButtonController, curve: Curves.easeInOut),
    );
    
    _attachmentAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _attachmentController, curve: Curves.easeInOut),
    );
    
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _sendButtonController.dispose();
    _attachmentController.dispose();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
      
      if (hasText) {
        _sendButtonController.forward();
        _attachmentController.forward();
      } else {
        _sendButtonController.reverse();
        _attachmentController.reverse();
      }
    }
  }

  void _onSendPressed() {
    if (widget.controller.text.trim().isNotEmpty) {
      HapticFeedback.lightImpact();
      widget.onSendMessage();
    }
  }

  void _startVoiceRecording() {
    setState(() {
      _isRecording = true;
    });
    HapticFeedback.mediumImpact();
    // TODO: Start voice recording
  }

  void _stopVoiceRecording() {
    setState(() {
      _isRecording = false;
    });
    HapticFeedback.lightImpact();
    // TODO: Stop voice recording and send
    widget.onVoiceMessageTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Attachment button
            ScaleTransition(
              scale: _attachmentAnimation,
              child: _AttachmentButton(
                onTap: widget.onAttachmentTap,
                enabled: widget.enabled && !_isRecording,
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Text input
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  enabled: widget.enabled && !_isRecording,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: _isRecording ? 'Recording...' : widget.hintText,
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 16,
                  ),
                  onSubmitted: (_) => _onSendPressed(),
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Send/Voice button
            _hasText
                ? ScaleTransition(
                    scale: _sendButtonAnimation,
                    child: _SendButton(
                      onTap: _onSendPressed,
                      enabled: widget.enabled,
                    ),
                  )
                : _VoiceButton(
                    onTapDown: _startVoiceRecording,
                    onTapUp: _stopVoiceRecording,
                    onTapCancel: _stopVoiceRecording,
                    isRecording: _isRecording,
                    enabled: widget.enabled,
                  ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool enabled;

  const _AttachmentButton({
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: enabled 
              ? theme.colorScheme.primary.withOpacity(0.1)
              : theme.colorScheme.surfaceVariant,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.attach_file,
          color: enabled 
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withOpacity(0.3),
          size: 22,
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool enabled;

  const _SendButton({
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: enabled 
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceVariant,
          shape: BoxShape.circle,
          boxShadow: enabled ? [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Icon(
          Icons.send,
          color: enabled 
              ? Colors.white
              : theme.colorScheme.onSurface.withOpacity(0.3),
          size: 20,
        ),
      ),
    );
  }
}

class _VoiceButton extends StatefulWidget {
  final VoidCallback? onTapDown;
  final VoidCallback? onTapUp;
  final VoidCallback? onTapCancel;
  final bool isRecording;
  final bool enabled;

  const _VoiceButton({
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.isRecording = false,
    this.enabled = true,
  });

  @override
  State<_VoiceButton> createState() => _VoiceButtonState();
}

class _VoiceButtonState extends State<_VoiceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_VoiceButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => widget.onTapDown?.call() : null,
      onTapUp: widget.enabled ? (_) => widget.onTapUp?.call() : null,
      onTapCancel: widget.enabled ? widget.onTapCancel : null,
      child: ScaleTransition(
        scale: widget.isRecording ? _pulseAnimation : 
               const AlwaysStoppedAnimation(1.0),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: widget.isRecording
                ? Colors.red
                : widget.enabled 
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : theme.colorScheme.surfaceVariant,
            shape: BoxShape.circle,
            boxShadow: widget.isRecording ? [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Icon(
            widget.isRecording ? Icons.stop : Icons.mic,
            color: widget.isRecording
                ? Colors.white
                : widget.enabled 
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.3),
            size: 22,
          ),
        ),
      ),
    );
  }
}