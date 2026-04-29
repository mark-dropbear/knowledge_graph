import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_graph/data/repositories/task_list_repository.dart';
import 'package:knowledge_graph/data/repositories/task_repository.dart';
import 'package:knowledge_graph/domain/use_cases/todo_use_cases.dart';

import 'package:knowledge_graph/domain/models/task_list.dart';
import 'package:knowledge_graph/ui/features/todo/view_models/todo_list_view_model.dart';
import 'package:knowledge_graph/ui/features/todo/views/todo_list_view.dart';

void main() {
  testWidgets('TodoListView add, toggle, and remove task', (
    WidgetTester tester,
  ) async {
    // 1. Initialize real Repositories and UseCases for an integrated widget test
    final taskRepo = TaskRepository();
    final taskListRepo = TaskListRepository();
    final createTaskUseCase = CreateTaskUseCase(taskRepo, taskListRepo);
    final deleteTaskUseCase = DeleteTaskUseCase(taskRepo, taskListRepo);
    final hydrateUseCase = HydrateTaskListUseCase(taskRepo);
    final toggleStatusUseCase = ToggleTaskStatusUseCase(taskRepo);

    // Pre-seed a default list for testing
    final testList = TaskList(id: 'urn:uuid:test-list', name: 'Test Tasks');
    await taskListRepo.setItem(testList);

    final viewModel = TodoListViewModel(
      taskListRepository: taskListRepo,
      createTaskUseCase: createTaskUseCase,
      deleteTaskUseCase: deleteTaskUseCase,
      hydrateUseCase: hydrateUseCase,
      toggleStatusUseCase: toggleStatusUseCase,
    );

    // 2. Build the widget
    await tester.pumpWidget(
      MaterialApp(home: TodoListView(viewModel: viewModel, listId: 'urn:uuid:test-list')),
    );

    // Allow initial data to load
    await tester.pumpAndSettle();

    // Verify initial state
    expect(find.text('Test Tasks'), findsOneWidget); // Appbar title
    expect(find.byType(ListTile), findsNothing);

    // 3. Tap the FAB to open the modal
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // 4. Enter text into the Name TextField
    await tester.enterText(find.byType(TextField).first, 'Buy groceries');

    // 5. Tap the Create/Add button
    await tester.tap(find.widgetWithText(ElevatedButton, 'Add Task'));

    // 6. Rebuild the widget to reflect the new state (adding task is async and modal closes)
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
