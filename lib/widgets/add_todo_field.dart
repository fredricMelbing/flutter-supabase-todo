import 'package:material_ui/material_ui.dart';

/// Text field + button for adding a new todo.
class AddTodoField extends StatefulWidget {
  final ValueChanged<String> onAdd;

  const AddTodoField({super.key, required this.onAdd});

  @override
  State<AddTodoField> createState() => _AddTodoFieldState();
}

class _AddTodoFieldState extends State<AddTodoField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    // Release the controller's resources when the widget is removed
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _controller.text.trim();
    if (title.isEmpty) return;
    widget.onAdd(title);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Vad behöver göras?',
                border: OutlineInputBorder(),
              ),
              // Pressing Enter also adds the todo
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(onPressed: _submit, child: const Text('Lägg till')),
        ],
      ),
    );
  }
}