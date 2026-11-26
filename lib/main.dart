import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/pages/auth_gate.dart';
import 'package:todo_app/repositories/supabase_todo_repository.dart';
import 'package:todo_app/repositories/todo_repository.dart';
import 'package:todo_app/services/auth_service.dart';
import 'package:todo_app/repositories/admin_repository.dart';

// Values injected at build time via --dart-define-from-file
const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    throw StateError(
      'Missing Supabase config. Run with --dart-define-from-file=config/dev.json',
    );
  }

  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseKey);

  final client = Supabase.instance.client;
  final authService = AuthService(client.auth);
  final TodoRepository repository = SupabaseTodoRepository(client);
  final adminRepository = AdminRepository(client);

  runApp(TodoApp(
    authService: authService, 
    repository: repository, 
    adminRepository: adminRepository,
    ));
}

class TodoApp extends StatelessWidget {
  final AuthService authService;
  final TodoRepository repository;
  final AdminRepository adminRepository;

  const TodoApp({
    super.key,
    required this.authService,
    required this.repository,
    required this.adminRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo',
      theme: ThemeData(colorSchemeSeed: Colors.indigo),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('sv'), Locale('en')],
      home: AuthGate(authService: authService, repository: repository, adminRepository: adminRepository),
    );
  }
}