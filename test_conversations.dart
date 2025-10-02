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

  // Check existing conversations
  try {
    final conversations = await client
        .from('conversations')
        .select()
        .or('user_id.eq.${user.id},other_user_id.eq.${user.id}')
        .order('last_message_time', ascending: false);

    print('Found ${conversations.length} conversations:');
    for (final conv in conversations) {
      print('- ID: ${conv['id']}');
      print('  User ID: ${conv['user_id']}');
      print('  Other User ID: ${conv['other_user_id']}');
      print('  Other User Name: ${conv['other_user_name']}');
      print('  Last Message: ${conv['last_message']}');
      print('  Unread Count: ${conv['unread_count']}');
      print('---');
    }

    if (conversations.isEmpty) {
      print('No conversations found. Creating test conversation...');
      
      // Get some other users to create conversations with
      final otherUsers = await client
          .from('profiles')
          .select('id, username')
          .neq('id', user.id)
          .limit(3);

      print('Found ${otherUsers.length} other users:');
      for (final otherUser in otherUsers) {
        print('- ${otherUser['username']} (${otherUser['id']})');
        
        // Create a conversation
        final conversation = await client
            .from('conversations')
            .insert({
              'user_id': user.id,
              'other_user_id': otherUser['id'],
              'other_user_name': otherUser['username'],
              'last_message': 'Hello! This is a test conversation.',
              'last_message_time': DateTime.now().toIso8601String(),
              'unread_count': 0,
            })
            .select()
            .single();

        print('Created conversation: ${conversation['id']}');
        
        // Add a test message
        final message = await client
            .from('messages')
            .insert({
              'sender_id': user.id,
              'receiver_id': otherUser['id'],
              'message': 'Hello! This is a test message.',
              'status': 0, // sent
            })
            .select()
            .single();

        print('Created message: ${message['id']}');
      }
    }

  } catch (e) {
    print('Error: $e');
  }
} 