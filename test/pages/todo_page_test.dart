import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:todo_app/models/user_todos.dart';
import 'package:todo_app/pages/todo_page.dart';
import 'package:todo_app/repositories/admin_repository.dart';
import 'package:todo_app/repositories/in_memory_todo_repository.dart';

/// Test double. In Dart every class is also an implicit interface,
/// so we can implement AdminRepository without touching app code.
class FakeAdminRepository implements AdminRepository {
  final bool isAdmin;

  FakeAdminRepository({this.isAdmin = false});

  @override
  Future<bool> isCurrentUserAdmin() async => isAdmin;

  @override
  Future<List<UserTodos>> getAllUserTodos() async => [];
}

/// Builds TodoPage with in-memory data – no Supabase involved.
Widget buildTodoPage({bool isAdmin = false}) {
  return MaterialApp(
    home: TodoPage(
      repository: InMemoryTodoRepository(),
      adminRepository: FakeAdminRepository(isAdmin: isAdmin),
      username: 'kalle',
      onSignOut: () {},
    ),
  );
}

void main() {
  testWidgets('shows empty state when there are no todos', (tester) async {
    await tester.pumpWidget(buildTodoPage());
    // Let async loading finish and the UI rebuild
    await tester.pumpAndSettle();

    expect(find.text('Inga todos ännu'), findsOneWidget);
  });

  testWidgets('adds a todo and updates the remaining count', (tester) async {
    await tester.pumpWidget(buildTodoPage());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Köpa mjölk');
    await tester.tap(find.text('Lägg till'));
    await tester.pumpAndSettle();

    expect(find.text('Köpa mjölk'), findsOneWidget);
    expect(find.text('kalle – 1 kvar'), findsOneWidget);
  });

  testWidgets('checking a todo decreases the remaining count', (tester) async {
    await tester.pumpWidget(buildTodoPage());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Köpa mjölk');
    await tester.tap(find.text('Lägg till'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    expect(find.text('kalle – 0 kvar'), findsOneWidget);
  });

  testWidgets('admin button is hidden for normal users', (tester) async {
    await tester.pumpWidget(buildTodoPage(isAdmin: false));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.admin_panel_settings), findsNothing);
  });

  testWidgets('admin button is shown for admins', (tester) async {
    await tester.pumpWidget(buildTodoPage(isAdmin: true));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.admin_panel_settings), findsOneWidget);
  });
}