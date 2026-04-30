import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:knowledge_graph/data/repositories/task_list_repository.dart';
import 'package:knowledge_graph/data/repositories/task_repository.dart';
import 'package:knowledge_graph/domain/use_cases/todo_use_cases.dart';
import 'package:knowledge_graph/domain/use_cases/export_dataset_use_case.dart';
import 'package:knowledge_graph/ui/features/todo/view_models/todo_list_view_model.dart';
import 'package:knowledge_graph/ui/features/todo/view_models/task_lists_view_model.dart';
import 'package:knowledge_graph/ui/features/todo/views/todo_list_view.dart';
import 'package:knowledge_graph/ui/features/todo/views/task_lists_view.dart';
import 'package:knowledge_graph/ui/layout/main_layout.dart';

void _setupLogging() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      print(
        '${record.level.name}: ${record.time}: [${record.loggerName}] ${record.message}',
      );
    }
  });
}

void main() {
  _setupLogging();
  usePathUrlStrategy();

  // 1. Initialize Repositories (Singletons)
  final taskRepo = TaskRepository();
  final taskListRepo = TaskListRepository();

  // 2. Initialize Use Cases
  final createTaskUseCase = CreateTaskUseCase(taskRepo, taskListRepo);
  final deleteTaskUseCase = DeleteTaskUseCase(taskRepo, taskListRepo);
  final editTaskUseCase = EditTaskUseCase(taskRepo);
  final hydrateUseCase = HydrateTaskListUseCase(taskRepo);
  final toggleStatusUseCase = ToggleTaskStatusUseCase(taskRepo);
  final createTaskListUseCase = CreateTaskListUseCase(taskListRepo);
  final deleteTaskListUseCase = DeleteTaskListUseCase(taskListRepo, taskRepo);
  final editTaskListUseCase = EditTaskListUseCase(taskListRepo);
  final exportDatasetUseCase = ExportDatasetUseCase(taskListRepo, taskRepo);

  // 3. Initialize ViewModels (Singletons)
  final taskListsViewModel = TaskListsViewModel(
    taskListRepository: taskListRepo,
    createTaskListUseCase: createTaskListUseCase,
    deleteTaskListUseCase: deleteTaskListUseCase,
    editTaskListUseCase: editTaskListUseCase,
    exportDatasetUseCase: exportDatasetUseCase,
  );

  final todoListViewModel = TodoListViewModel(
    taskListRepository: taskListRepo,
    createTaskUseCase: createTaskUseCase,
    deleteTaskUseCase: deleteTaskUseCase,
    editTaskUseCase: editTaskUseCase,
    hydrateUseCase: hydrateUseCase,
    toggleStatusUseCase: toggleStatusUseCase,
  );

  // 4. Configure GoRouter
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                TaskListsView(viewModel: taskListsViewModel),
          ),
          GoRoute(
            path: '/lists/:id',
            builder: (context, state) {
              final listId = state.pathParameters['id']!;
              return TodoListView(listId: listId, viewModel: todoListViewModel);
            },
          ),
        ],
      ),
    ],
  );

  runApp(MainApp(router: router));
}

class MainApp extends StatelessWidget {
  final GoRouter router;

  const MainApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      routerConfig: router,
    );
  }
}
