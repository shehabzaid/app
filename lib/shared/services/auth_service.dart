import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client = Supabase.instance.client;

  // Admin login
  Future<User?> adminLogin(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // TODO: Verify if the user has admin role
        return response.user;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Admin logout
  Future<void> adminLogout() async {
    await _client.auth.signOut();
  }

  // Get current admin user
  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _client.auth.currentUser != null;
  }

  // Check if user is admin
  Future<bool> isAdmin() async {
    final user = _client.auth.currentUser;
    if (user == null) return false;

    // TODO: Implement admin role check with Supabase
    return true;
  }
}
