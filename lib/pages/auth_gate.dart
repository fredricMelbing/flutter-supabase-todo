import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/pages/login_page.dart';
import 'package:todo_app/pages/todo_page.dart';
import 'package:todo_app/repositories/todo_repository.dart';
import 'package:todo_app/services/auth_service.dart';
import 'package:todo_app/repositories/admin_repository.dart';

/// Shows LoginPage or TodoPage depending on whether a user is signed in.
class AuthGate extends StatelessWidget {
  final AuthService authService;
  final TodoRepository repository;
  final AdminRepository adminRepository;

  const AuthGate({
    super.key,
    required this.authService,
    required this.repository,
    required this.adminRepository,
  });

  @override
  Widget build(BuildContext context) {
    // Rebuilds every time the auth state changes (sign in, sign out, refresh)
    return StreamBuilder<AuthState>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // Before the first event arrives, fall back to the cached session
        final session = snapshot.hasData
            ? snapshot.data!.session
            : authService.currentSession;

        if (session == null) {
          return LoginPage(authService: authService);
        }

        return TodoPage(
          // New key per user => fresh page state, no todos leaking between users
          key: ValueKey(session.user.id),
          repository: repository,
          adminRepository: adminRepository,
          username: authService.currentUsername ?? '',
          onSignOut: authService.signOut,
        );
      },
    );
  }
}