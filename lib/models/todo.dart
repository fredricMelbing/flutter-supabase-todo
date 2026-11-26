/// Immutable todo item – comparable to a C# record.
class Todo {
  final String id;
  final String title;
  final bool isDone;

  const Todo({
    required this.id,
    required this.title,
    this.isDone = false,
  });

  /// Returns a copy with the given fields replaced (like C# `with`).
  Todo copyWith({String? title, bool? isDone}) {
    return Todo(
      id: id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }

    /// Maps a database row (snake_case columns) to a Todo.
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String,
      title: json['title'] as String,
      isDone: json['is_done'] as bool,
    );
  }

  /// Columns we write to the database. id and created_at are set by Postgres.
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'is_done': isDone,
    };
  }
}