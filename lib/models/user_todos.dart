import 'package:todo_app/models/todo.dart';

/// One user's todos, used by the admin overview.
class UserTodos {
  final String username;
  final List<Todo> todos;

  const UserTodos({required this.username, required this.todos});

  int get doneCount => todos.where((t) => t.isDone).length;
}