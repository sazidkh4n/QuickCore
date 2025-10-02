import 'package:supabase_flutter/supabase_flutter.dart';

Future<AuthResponse> signInWithOAuth(OAuthProvider provider) async {
  return await Supabase.instance.client.auth.signInWithOAuth(provider);
} 