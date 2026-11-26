import 'package:todo_app/models/todo.dart';
import 'package:todo_app/repositories/todo_repository.dart';

/// Keeps todos in a list in memory. Data is lost when the app restarts.
class InMemoryTodoRepository implements TodoRepository {
  final List<Todo> _todos = [];

  @override
  Future<List<Todo>> getAll() async => List.unmodifiable(_todos);

  @override
  Future<Todo> add(String title) async {
    // Simple unique id based on timestamp – the database will generate ids later
    final todo = Todo(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
    );
    _todos.add(todo);
    return todo;
  }

  @override
  Future<Todo> update(Todo todo) async {
    final index = _todos.indexWhere((t) => t.id == todo.id);
    if (index == -1) {
      throw StateError('Todo ${todo.id} not found');
    }
    _todos[index] = todo;
    return todo;
  }

  @override
  Future<void> delete(String id) async {
    _todos.removeWhere((t) => t.id == id);
  }
}