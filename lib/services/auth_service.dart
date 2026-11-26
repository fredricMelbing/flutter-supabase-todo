import 'package:supabase_flutter/supabase_flutter.dart';

/// Wraps Supabase Auth so the app can use usernames instead of emails.
class AuthService {
  // Supabase Auth requires an email, so usernames are mapped to a fake domain.
  // If Supabase rejects this domain, change it here – nothing else depends on it.
  static const _emailDomain = 'todo.local';

  final GoTrueClient _auth;

  AuthService(this._auth);

  /// Emits an event every time the user signs in, signs out or the token refreshes.
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  Session? get currentSession => _auth.currentSession;

  /// The username part of the stored email, e.g. "kalle" from "kalle@todo.local".
  String? get currentUsername => _auth.currentUser?.email?.split('@').first;

  Future<void> signUp(String username, String password) async {
    // With "Confirm email" disabled, the user is signed in immediately
    await _auth.signUp(email: _toEmail(username), password: password);
  }

  Future<void> signIn(String username, String password) async {
    await _auth.signInWithPassword(email: _toEmail(username), password: password);
  }

  Future<void> signOut() => _auth.signOut();

  /// Form validator: 3–20 chars, only a–z, digits and underscore (valid in an email).
  static String? validateUsername(String? value) {
    final username = value?.trim() ?? '';
    if (!RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(username)) {
      return '3–20 tecken: a–z, siffror eller _';
    }
    return null;
  }

  String _toEmail(String username) =>
      '${username.trim().toLowerCase()}@$_emailDomain';
}