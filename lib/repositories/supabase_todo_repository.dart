import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:todo_app/models/todo.dart';
import 'package:todo_app/repositories/todo_repository.dart';

/// Stores todos in the Supabase `todos` table.
class SupabaseTodoRepository implements TodoRepository {
  static const _table = 'todos';

  final SupabaseClient _client;

  SupabaseTodoRepository(this._client);

  @override
  Future<List<Todo>> getAll() async {
    // RLS decides what we MAY see; this filter decides what we WANT to see.
    // Without it, an admin would get everyone's todos in their own list.
    final userId = _client.auth.currentUser!.id;
    final rows = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('created_at');
    return rows.map(Todo.fromJson).toList();
  }

  @override
  Future<Todo> add(String title) async {
    // .select().single() returns the inserted row, including the generated id
    final row = await _client
        .from(_table)
        .insert({'title': title})
        .select()
        .single();
    return Todo.fromJson(row);
  }

  @override
  Future<Todo> update(Todo todo) async {
    final row = await _client
        .from(_table)
        .update(todo.toJson())
        .eq('id', todo.id)
        .select()
        .single();
    return Todo.fromJson(row);
  }

  @override
  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}