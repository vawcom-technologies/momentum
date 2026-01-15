import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // ============================================
  // PUT YOUR SUPABASE CREDENTIALS HERE:
  // ============================================
  // 1. Go to https://app.supabase.com
  // 2. Create a new project or select existing one
  // 3. Go to: Settings (gear icon) -> API
  // 4. Copy "Project URL" and paste below as supabaseUrl
  // 5. Copy "anon public" key and paste below as supabaseAnonKey
  // ============================================
  static const String supabaseUrl = 'https://vnwpmagotjeeprdqcrdm.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZud3BtYWdvdGplZXByZHFjcmRtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg1MDIxODMsImV4cCI6MjA4NDA3ODE4M30.FGmy5fK_yMts-MYlkE3fdp8btkV0DIzWYu_sQqVlBr4';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  // Auth methods
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: name != null ? {'name': name} : null,
    );
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static User? get currentUser => client.auth.currentUser;
  static Session? get currentSession => client.auth.currentSession;
  static Stream<AuthState> get authStateChanges => client.auth.onAuthStateChange;
}
