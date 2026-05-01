import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_graph/data/repositories/graph_repository.dart';
import 'package:knowledge_graph/domain/use_cases/todo_use_cases.dart';

import 'package:knowledge_graph/domain/models/task_list.dart';
import 'package:knowledge_graph/ui/features/todo/view_models/todo_list_view_model.dart';
import 'package:knowledge_graph/ui/features/todo/views/todo_list_view.dart';

void main() {
  testWidgets('TodoListView toggle and remove task', (
    WidgetTester tester,
  ) async {
    // 1. Initialize real Repositories and UseCases for an integrated widget test
    final graphRepo = GraphRepository();
    final createTaskUseCase = CreateTaskUseCase(graphRepo);
    final deleteTaskUseCase = DeleteTaskUseCase(graphRepo);
    final editTaskUseCase = EditTaskUseCase(graphRepo);
    final hydrateUseCase = HydrateTaskListUseCase(graphRepo);
    final toggleStatusUseCase = ToggleTaskStatusUseCase(graphRepo);

    // Pre-seed a default list for testing
    final testList = TaskList(id: 'urn:uuid:test-list', name: 'Test Tasks');
    await graphRepo.setItem(testList);

    // Pre-seed a task for testing toggle and dismiss
    await createTaskUseCase.execute(testList, 'Buy groceries');

    final viewModel = TodoListViewModel(
      repository: graphRepo,
      createTaskUseCase: createTaskUseCase,
      deleteTaskUseCase: deleteTaskUseCase,
      editTaskUseCase: editTaskUseCase,
      hydrateUseCase: hydrateUseCase,
      toggleStatusUseCase: toggleStatusUseCase,
    );

    // 2. Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: TodoListView(viewModel: viewModel, listId: 'urn:uuid:test-list'),
      ),
    );

    // Allow initial data to load
    await tester.pumpAndSettle();

    // 7. Verify the item was added
    expect(find.text('Buy groceries'), findsOneWidget);

    // 8. Verify task starts as PotentialActionStatus (checkbox unchecked)
    var checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.value, false);

    // 9. Tap the checkbox to toggle status
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    // Verify the checkbox is now checked
    checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.value, true);

    // 10. Swipe the item to dismiss it
    await tester.drag(find.byType(Dismissible), const Offset(-500, 0));

    // 11. Build the widget until the dismiss animation ends
    await tester.pumpAndSettle();

    // 12. Verify the item was removed
    expect(find.text('Buy groceries'), findsNothing);
  });
}
