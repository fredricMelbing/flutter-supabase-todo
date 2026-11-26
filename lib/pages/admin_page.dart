import 'package:material_ui/material_ui.dart';
import 'package:todo_app/models/user_todos.dart';
import 'package:todo_app/repositories/admin_repository.dart';

/// Read-only overview of every user's todo list.
class AdminPage extends StatefulWidget {
  final AdminRepository adminRepository;

  const AdminPage({super.key, required this.adminRepository});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late Future<List<UserTodos>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.adminRepository.getAllUserTodos();
  }

  Future<void> _refresh() async {
    final future = widget.adminRepository.getAllUserTodos();
    setState(() => _future = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alla listor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Uppdatera',
            onPressed: _refresh,
          ),
        ],
      ),
      // FutureBuilder: rebuilds when the Future completes (loading / error / data)
      body: FutureBuilder<List<UserTodos>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Kunde inte hämta: ${snapshot.error}'));
          }

          final users = snapshot.data!;
          if (users.isEmpty) {
            return const Center(child: Text('Inga användare'));
          }

          return ListView(
            children: [
              for (final user in users)
                ExpansionTile(
                  leading: const Icon(Icons.person),
                  title: Text(user.username),
                  subtitle: Text('${user.doneCount}/${user.todos.length} klara'),
                  children: [
                    if (user.todos.isEmpty)
                      const ListTile(title: Text('Inga todos')),
                    for (final todo in user.todos)
                      ListTile(
                        leading: Icon(
                          todo.isDone ? Icons.check_box : Icons.check_box_outline_blank,
                        ),
                        title: Text(
                          todo.title,
                          style: TextStyle(
                            decoration: todo.isDone ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}