import 'package:flutter/material.dart';
import 'package:knowledge_graph/data/repositories/task_list_repository.dart';
import 'package:knowledge_graph/data/repositories/task_repository.dart';
import 'package:knowledge_graph/domain/use_cases/todo_use_cases.dart';
import 'package:knowledge_graph/ui/features/todo/view_models/todo_list_view_model.dart';
import 'package:knowledge_graph/ui/features/todo/views/todo_list_view.dart';

void main() {
  // 1. Initialize Repositories
  final taskRepo = TaskRepository();
  final taskListRepo = TaskListRepository();

  // 2. Initialize Use Cases
  final createTaskUseCase = CreateTaskUseCase(taskRepo, taskListRepo);
  final deleteTaskUseCase = DeleteTaskUseCase(taskRepo, taskListRepo);
  final hydrateUseCase = HydrateTaskListUseCase(taskRepo);
  final toggleStatusUseCase = ToggleTaskStatusUseCase(taskRepo);

  // 3. Initialize ViewModel
  final viewModel = TodoListViewModel(
    taskListRepository: taskListRepo,
    createTaskUseCase: createTaskUseCase,
    deleteTaskUseCase: deleteTaskUseCase,
    hydrateUseCase: hydrateUseCase,
    toggleStatusUseCase: toggleStatusUseCase,
  );

  runApp(MainApp(viewModel: viewModel));
}

class MainApp extends StatelessWidget {
  final TodoListViewModel viewModel;

  const MainApp({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: TodoListView(viewModel: viewModel),
    );
  }
}
