import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Initialize Supabase
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  final client = Supabase.instance.client;
  
  // Check if user is authenticated
  final user = client.auth.currentUser;
  if (user == null) {
    print('No user authenticated');
    return;
  }

  print('Current user: ${user.id}');

  try {
    // Find test conversations (those with "Hello! This is a test message")
    final testConversations = await client
        .from('conversations')
        .select()
        .or('user_id.eq.${user.id},other_user_id.eq.${user.id}')
        .ilike('last_message', '%Hello! This is a test message%');

    print('Found ${testConversations.length} test conversations to clean up');

    for (final conv in testConversations) {
      print('Cleaning up conversation: ${conv['id']}');
      
      // Delete the conversation
      await client
          .from('conversations')
          .delete()
          .eq('id', conv['id']);
      
      print('Deleted conversation: ${conv['id']}');
    }

    // Also clean up test messages from enhanced_messages table
    final testMessages = await client
        .from('enhanced_messages')
        .select()
        .or('sender_id.eq.${user.id},receiver_id.eq.${user.id}')
        .ilike('message', '%Hello! This is a test message%');

    print('Found ${testMessages.length} test messages to clean up');

    for (final msg in testMessages) {
      print('Cleaning up message: ${msg['id']}');
      
      // Delete the message
      await client
          .from('enhanced_messages')
          .delete()
          .eq('id', msg['id']);
      
      print('Deleted message: ${msg['id']}');
    }

    // Also clean up test messages from regular messages table
    final testRegularMessages = await client
        .from('messages')
        .select()
        .or('sender_id.eq.${user.id},receiver_id.eq.${user.id}')
        .ilike('message', '%Hello! This is a test message%');

    print('Found ${testRegularMessages.length} test regular messages to clean up');

    for (final msg in testRegularMessages) {
      print('Cleaning up regular message: ${msg['id']}');
      
      // Delete the message
      await client
          .from('messages')
          .delete()
          .eq('id', msg['id']);
      
      print('Deleted regular message: ${msg['id']}');
    }

    print('Cleanup completed successfully!');

  } catch (e) {
    print('Error during cleanup: $e');
  }
} 