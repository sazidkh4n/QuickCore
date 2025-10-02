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
  print('Current user email: ${user.email}');

  try {
    // Check all conversations in the database
    final allConversations = await client
        .from('conversations')
        .select()
        .order('last_message_time', ascending: false);

    print('\n=== ALL CONVERSATIONS IN DATABASE ===');
    print('Total conversations: ${allConversations.length}');
    
    for (final conv in allConversations) {
      print('- ID: ${conv['id']}');
      print('  User ID: ${conv['user_id']}');
      print('  Other User ID: ${conv['other_user_id']}');
      print('  Other User Name: ${conv['other_user_name']}');
      print('  Last Message: ${conv['last_message']}');
      print('  Last Message Time: ${conv['last_message_time']}');
      print('  Unread Count: ${conv['unread_count']}');
      print('---');
    }

    // Check conversations for current user specifically
    final userConversations = await client
        .from('conversations')
        .select()
        .or('user_id.eq.${user.id},other_user_id.eq.${user.id}')
        .order('last_message_time', ascending: false);

    print('\n=== CONVERSATIONS FOR CURRENT USER ===');
    print('User conversations: ${userConversations.length}');
    
    for (final conv in userConversations) {
      print('- ID: ${conv['id']}');
      print('  User ID: ${conv['user_id']}');
      print('  Other User ID: ${conv['other_user_id']}');
      print('  Other User Name: ${conv['other_user_name']}');
      print('  Last Message: ${conv['last_message']}');
      print('  Last Message Time: ${conv['last_message_time']}');
      print('  Unread Count: ${conv['unread_count']}');
      print('---');
    }

    // Check if there are any messages
    final allMessages = await client
        .from('enhanced_messages')
        .select()
        .or('sender_id.eq.${user.id},receiver_id.eq.${user.id}')
        .order('created_at', ascending: false)
        .limit(10);

    print('\n=== RECENT MESSAGES FOR CURRENT USER ===');
    print('Recent messages: ${allMessages.length}');
    
    for (final msg in allMessages) {
      print('- ID: ${msg['id']}');
      print('  Sender: ${msg['sender_id']}');
      print('  Receiver: ${msg['receiver_id']}');
      print('  Message: ${msg['message']}');
      print('  Type: ${msg['message_type']}');
      print('  Created: ${msg['created_at']}');
      print('---');
    }

    // Check profiles table
    final profiles = await client
        .from('profiles')
        .select('id, username, email')
        .limit(10);

    print('\n=== PROFILES IN DATABASE ===');
    print('Profiles: ${profiles.length}');
    
    for (final profile in profiles) {
      print('- ID: ${profile['id']}');
      print('  Username: ${profile['username']}');
      print('  Email: ${profile['email']}');
      print('---');
    }

  } catch (e) {
    print('Error: $e');
  }
} 