import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/services/auth_service.dart';

/// Combined sign-in / register page.
class LoginPage extends StatefulWidget {
  final AuthService authService;

  const LoginPage({super.key, required this.authService});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isRegisterMode = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Run all field validators; stop if any of them fails
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final username = _usernameController.text;
      final password = _passwordController.text;

      if (_isRegisterMode) {
        await widget.authService.signUp(username, password);
      } else {
        await widget.authService.signIn(username, password);
      }
      // No navigation here – AuthGate reacts to the auth state change
    } on AuthException catch (e) {
      if (mounted) setState(() => _errorMessage = _translateError(e));
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Något gick fel: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Maps Supabase error codes to Swedish messages (like a C# switch expression).
  String _translateError(AuthException e) => switch (e.code) {
        'invalid_credentials' => 'Fel användarnamn eller lösenord',
        'user_already_exists' => 'Användarnamnet är redan taget',
        'weak_password' => 'Lösenordet är för svagt (minst 6 tecken)',
        'email_address_invalid' =>
          'Supabase godkänner inte e-postdomänen – byt _emailDomain i AuthService',
        _ => e.message,
      };

  void _toggleMode() {
    setState(() {
      _isRegisterMode = !_isRegisterMode;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final title = _isRegisterMode ? 'Skapa konto' : 'Logga in';

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          // Keep the form narrow on wide screens (web/desktop)
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Användarnamn',
                      border: OutlineInputBorder(),
                    ),
                    autofillHints: const [AutofillHints.username],
                    validator: AuthService.validateUsername,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Lösenord',
                      border: OutlineInputBorder(),
                    ),
                    autofillHints: const [AutofillHints.password],
                    validator: (value) =>
                        (value == null || value.length < 6) ? 'Minst 6 tecken' : null,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  // Collection-if: only add these widgets when there is an error
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    // null disables the button while a request is running
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(title),
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : _toggleMode,
                    child: Text(_isRegisterMode
                        ? 'Har du redan ett konto? Logga in'
                        : 'Inget konto? Skapa ett'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}