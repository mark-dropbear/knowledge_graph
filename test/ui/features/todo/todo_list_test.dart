import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_graph/data/repositories/task_list_repository.dart';
import 'package:knowledge_graph/data/repositories/task_repository.dart';
import 'package:knowledge_graph/domain/use_cases/todo_use_cases.dart';
import 'package:knowledge_graph/ui/features/todo/view_models/todo_list_view_model.dart';
import 'package:knowledge_graph/ui/features/todo/views/todo_list_view.dart';

void main() {
  testWidgets('TodoListView add, toggle, and remove task', (WidgetTester tester) async {
    // 1. Initialize real Repositories and UseCases for an integrated widget test
    final taskRepo = TaskRepository();
    final taskListRepo = TaskListRepository();
    final createTaskUseCase = CreateTaskUseCase(taskRepo, taskListRepo);
    final deleteTaskUseCase = DeleteTaskUseCase(taskRepo, taskListRepo);
    final hydrateUseCase = HydrateTaskListUseCase(taskRepo);
    final toggleStatusUseCase = ToggleTaskStatusUseCase(taskRepo);

    final viewModel = TodoListViewModel(
      taskListRepository: taskListRepo,
      createTaskUseCase: createTaskUseCase,
      deleteTaskUseCase: deleteTaskUseCase,
      hydrateUseCase: hydrateUseCase,
      toggleStatusUseCase: toggleStatusUseCase,
    );

    // 2. Build the widget
    await tester.pumpWidget(MaterialApp(
      home: TodoListView(viewModel: viewModel),
    ));

    // Allow initial data to load (creates default list)
    await tester.pumpAndSettle();

    // Verify initial state
    expect(find.text('My Tasks'), findsOneWidget); // Appbar title
    expect(find.byType(ListTile), findsNothing);

    // 3. Enter text into the TextField
    await tester.enterText(find.byType(TextField), 'Buy groceries');

    // 4. Tap the add button
    await tester.tap(find.byIcon(Icons.add));

    // 5. Rebuild the widget to reflect the new state (adding task is async)
    await tester.pumpAndSettle();

    // 6. Verify the item was added
    expect(find.text('Buy groceries'), findsOneWidget);

    // 7. Verify task starts as PotentialActionStatus (checkbox unchecked)
    var checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.value, false);

    // 8. Tap the checkbox to toggle status
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    // Verify the checkbox is now checked
    checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.value, true);

    // 9. Swipe the item to dismiss it
    await tester.drag(find.byType(Dismissible), const Offset(-500, 0));

    // 10. Build the widget until the dismiss animation ends
    await tester.pumpAndSettle();

    // 11. Verify the item was removed
    expect(find.text('Buy groceries'), findsNothing);
  });
}
