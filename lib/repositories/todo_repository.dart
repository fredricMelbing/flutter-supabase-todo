import 'package:todo_app/models/todo.dart';

/// Abstraction over todo storage – implemented in memory now, Supabase later.
abstract class TodoRepository {
  Future<List<Todo>> getAll();
  Future<Todo> add(String title);
  Future<Todo> update(Todo todo);
  Future<void> delete(String id);
}