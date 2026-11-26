import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/models/user_todos.dart';

/// Admin-only queries. RLS makes these return only the caller's own data
/// for non-admins, so the database – not this class – enforces security.
class AdminRepository {
  final SupabaseClient _client;

  AdminRepository(this._client);

  /// Calls the SQL function public.is_admin() via RPC.
  Future<bool> isCurrentUserAdmin() async {
    final result = await _client.rpc('is_admin');
    return result == true;
  }

  Future<List<UserTodos>> getAllUserTodos() async {
    // Run both queries in parallel (like Task.WhenAll in C#)
    final results = await Future.wait([
      _client.from('profiles').select('id, username').order('username'),
      _client.from('todos').select().order('created_at'),
    ]);
    final profileRows = results[0];
    final todoRows = results[1];

    // Group todos by user_id (like GroupBy + ToDictionary in LINQ)
    final todosByUser = <String, List<Todo>>{};
    for (final row in todoRows) {
      todosByUser
          .putIfAbsent(row['user_id'] as String, () => [])
          .add(Todo.fromJson(row));
    }

    return [
      for (final profile in profileRows)
        UserTodos(
          username: profile['username'] as String,
          todos: todosByUser[profile['id']] ?? [],
        ),
    ];
  }
}