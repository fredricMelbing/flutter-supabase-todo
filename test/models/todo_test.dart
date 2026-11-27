import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/models/todo.dart';

void main() {
  group('Todo', () {
    test('copyWith changes only the given fields', () {
      const todo = Todo(id: '1', title: 'Handla');

      final updated = todo.copyWith(isDone: true);

      expect(updated.id, '1');
      expect(updated.title, 'Handla');
      expect(updated.isDone, isTrue);
      // The original is immutable and must be unchanged
      expect(todo.isDone, isFalse);
    });

    test('fromJson maps snake_case database columns', () {
      final todo = Todo.fromJson({
        'id': 'abc',
        'title': 'Handla',
        'is_done': true,
        // Extra columns from the database must be ignored
        'user_id': 'user-1',
        'created_at': '2026-11-27T09:00:00Z',
      });

      expect(todo.id, 'abc');
      expect(todo.title, 'Handla');
      expect(todo.isDone, isTrue);
    });

    test('toJson only contains columns the app is allowed to write', () {
      const todo = Todo(id: '1', title: 'Handla');

      expect(todo.toJson(), {'title': 'Handla', 'is_done': false});
    });
  });
}