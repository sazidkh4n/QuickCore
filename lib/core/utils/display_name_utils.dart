import '../../features/auth/data/user_model.dart';

/// Utility functions for handling user display names consistently across the app
class DisplayNameUtils {
  
  /// Get the display name for a user with proper priority:
  /// 1. name (if available, not empty, and not an email)
  /// 2. @username (if available, not empty, and not an email)
  /// 3. fallback identifier
  static String getDisplayName(UserModel user) {
    if (user.name != null && user.name!.isNotEmpty && !isEmail(user.name!)) {
      return user.name!;
    }
    
    if (user.username != null && user.username!.isNotEmpty && !isEmail(user.username!)) {
      return '@${user.username}';
    }
    
    // Fallback: use a shortened version of the user ID
    return 'User_${user.id.substring(0, 8)}';
  }
  
  /// Get the display name for a user with custom fallback
  static String getDisplayNameWithFallback(UserModel user, String fallback) {
    if (user.name != null && user.name!.isNotEmpty) {
      return user.name!;
    }
    
    if (user.username != null && user.username!.isNotEmpty) {
      return '@${user.username}';
    }
    
    return fallback;
  }
  
  /// Get username with @ prefix if available
  static String getUsernameDisplay(String? username) {
    if (username != null && username.isNotEmpty) {
      return '@$username';
    }
    return 'User';
  }
  
  /// Check if a string looks like an email address
  static bool isEmail(String text) {
    return text.contains('@') && 
           text.contains('.') && 
           text.indexOf('@') < text.lastIndexOf('.') &&
           text.indexOf('@') > 0; // @ should not be at the beginning
  }
  
  /// Sanitize display name to remove email addresses
  static String sanitizeDisplayName(String displayName) {
    if (isEmail(displayName)) {
      // If it's an email, extract the username part before @
      final username = displayName.split('@').first;
      return username.isNotEmpty ? username : 'User';
    }
    // If it starts with @ but is not a valid email, remove the @
    if (displayName.startsWith('@') && !isEmail(displayName)) {
      return displayName.substring(1).isNotEmpty ? displayName.substring(1) : 'User';
    }
    return displayName;
  }
  
  /// Get a short display name for compact UI elements
  static String getShortDisplayName(UserModel user) {
    if (user.name != null && user.name!.isNotEmpty) {
      // Return first name only if it contains spaces
      final nameParts = user.name!.split(' ');
      return nameParts.first;
    }
    
    if (user.username != null && user.username!.isNotEmpty) {
      return '@${user.username}';
    }
    
    return 'User';
  }
  
  /// Get initials from display name for avatar fallbacks
  static String getInitials(UserModel user) {
    if (user.name != null && user.name!.isNotEmpty) {
      final nameParts = user.name!.split(' ');
      if (nameParts.length >= 2) {
        return '${nameParts.first[0]}${nameParts.last[0]}'.toUpperCase();
      } else if (nameParts.length == 1) {
        return nameParts.first[0].toUpperCase();
      }
    }
    
    if (user.username != null && user.username!.isNotEmpty) {
      return user.username![0].toUpperCase();
    }
    
    return 'U';
  }
} 