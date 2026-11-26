import 'package:material_ui/material_ui.dart';
import 'package:todo_app/models/todo.dart';

/// A single row in the list. Stateless: all data and callbacks come from the parent.
class TodoItem extends StatelessWidget {
  final Todo todo;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const TodoItem({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Dismissible enables swipe-to-delete
    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: CheckboxListTile(
        value: todo.isDone,
        onChanged: (value) => onToggle(value ?? false),
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isDone ? TextDecoration.lineThrough : null,
            color: todo.isDone ? Colors.grey : null,
          ),
        ),
        secondary: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
      ),
    );
  }
}