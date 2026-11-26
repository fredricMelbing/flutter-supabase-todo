import 'package:material_ui/material_ui.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/repositories/todo_repository.dart';
import 'package:todo_app/widgets/add_todo_field.dart';
import 'package:todo_app/widgets/todo_item.dart';
import 'package:todo_app/pages/admin_page.dart';
import 'package:todo_app/repositories/admin_repository.dart';

/// Main page that owns the list state and talks to the repository.
class TodoPage extends StatefulWidget {
  final TodoRepository repository;
  final AdminRepository adminRepository;
  final String username;
  final VoidCallback onSignOut;

  const TodoPage({
    super.key, 
    required this.repository,
    required this.adminRepository,
    required this.username,
    required this.onSignOut,
    });

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<Todo> _todos = [];
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    // Runs once when the widget is created (like useEffect with [] in React)
    _loadTodos();
    _checkAdmin();
  }

    Future<void> _loadTodos() async {
    try {
      final todos = await widget.repository.getAll();
      if (!mounted) return;
      setState(() => _todos = todos);
    } catch (e) {
      _showError('Kunde inte hämta todos', e);
    } finally {
      // Always stop the spinner, even if loading failed
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _checkAdmin() async {
    try {
      final isAdmin = await widget.adminRepository.isCurrentUserAdmin();
      if (mounted) setState(() => _isAdmin = isAdmin);
    } catch (e) {
      // Not critical – the admin button simply stays hidden
      debugPrint('Admin check failed: $e');
    }
  }

  Future<void> _addTodo(String title) async {
    try {
      final todo = await widget.repository.add(title);
      if (!mounted) return;
      setState(() => _todos = [..._todos, todo]);
    } catch (e) {
      _showError('Kunde inte spara', e);
    }
  }

  Future<void> _toggleTodo(Todo todo, bool isDone) async {
    try {
      final updated = await widget.repository.update(todo.copyWith(isDone: isDone));
      if (!mounted) return;
      setState(() {
        _todos = [for (final t in _todos) t.id == updated.id ? updated : t];
      });
    } catch (e) {
      _showError('Kunde inte uppdatera', e);
    }
  }

  Future<void> _deleteTodo(Todo todo) async {
    // Optimistic update: remove from the UI first (required by Dismissible)
    setState(() => _todos = _todos.where((t) => t.id != todo.id).toList());
    try {
      await widget.repository.delete(todo.id);
    } catch (e) {
      _showError('Kunde inte ta bort', e);
      // Roll back by reloading the real state from the database
      await _loadTodos();
    }
  }

  void _showError(String message, Object error) {
    // Log full error to the debug console, show a short message to the user
    debugPrint('$message: $error');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _todos.where((t) => !t.isDone).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.username} – $remaining kvar'),
        actions: [
          // Hiding the button is only UX – the real protection is RLS
          if (_isAdmin)
          IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Alla listor',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AdminPage(adminRepository: widget.adminRepository),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logga ut',
            onPressed: widget.onSignOut,
          ),
        ],
      ),
      body: Column(
        children: [
          AddTodoField(onAdd: _addTodo),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  Widget _buildList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_todos.isEmpty) {
      return const Center(child: Text('Inga todos ännu'));
    }
    return ListView.builder(
      itemCount: _todos.length,
      itemBuilder: (context, index) {
        final todo = _todos[index];
        return TodoItem(
          todo: todo,
          onToggle: (isDone) => _toggleTodo(todo, isDone),
          onDelete: () => _deleteTodo(todo),
        );
      },
    );
  }
}