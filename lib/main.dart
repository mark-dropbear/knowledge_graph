import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'package:knowledge_graph/data/repositories/graph_repository.dart';
import 'package:knowledge_graph/domain/use_cases/todo_use_cases.dart';
import 'package:knowledge_graph/domain/use_cases/export_dataset_use_case.dart';
import 'package:knowledge_graph/ui/features/todo/view_models/todo_list_view_model.dart';
import 'package:knowledge_graph/ui/features/todo/view_models/task_lists_view_model.dart';
import 'package:knowledge_graph/ui/features/todo/views/todo_list_view.dart';
import 'package:knowledge_graph/ui/features/todo/views/task_lists_view.dart';
import 'package:knowledge_graph/ui/features/todo/views/task_detail_view.dart';
import 'package:knowledge_graph/ui/features/todo/views/task_form_view.dart';
import 'package:knowledge_graph/ui/shared/view_models/graph_view_model.dart';
import 'package:knowledge_graph/ui/layout/main_layout.dart';
import 'package:knowledge_graph/domain/use_cases/person_use_cases.dart';
import 'package:knowledge_graph/ui/features/people/view_models/people_view_model.dart';
import 'package:knowledge_graph/ui/features/people/views/people_view.dart';
import 'package:knowledge_graph/domain/use_cases/organization_use_cases.dart';
import 'package:knowledge_graph/ui/features/organizations/view_models/organizations_view_model.dart';
import 'package:knowledge_graph/ui/features/organizations/views/organizations_view.dart';
import 'package:knowledge_graph/ui/features/people/views/person_form_view.dart';
import 'package:knowledge_graph/ui/features/people/views/person_detail_view.dart';
import 'package:knowledge_graph/ui/features/organizations/views/organization_form_view.dart';
import 'package:knowledge_graph/ui/features/organizations/views/organization_detail_view.dart';

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
  final graphRepo = GraphRepository();

  // 2. Initialize Use Cases
  final createTaskUseCase = CreateTaskUseCase(graphRepo);
  final deleteTaskUseCase = DeleteTaskUseCase(graphRepo);
  final editTaskUseCase = EditTaskUseCase(graphRepo);
  final hydrateUseCase = HydrateTaskListUseCase(graphRepo);
  final toggleStatusUseCase = ToggleTaskStatusUseCase(graphRepo);
  final createTaskListUseCase = CreateTaskListUseCase(graphRepo);
  final deleteTaskListUseCase = DeleteTaskListUseCase(graphRepo);
  final editTaskListUseCase = EditTaskListUseCase(graphRepo);
  final exportDatasetUseCase = ExportDatasetUseCase(graphRepo);

  final createPersonUseCase = CreatePersonUseCase(graphRepo);
  final editPersonUseCase = EditPersonUseCase(graphRepo);
  final deletePersonUseCase = DeletePersonUseCase(graphRepo);

  final createOrganizationUseCase = CreateOrganizationUseCase(graphRepo);
  final editOrganizationUseCase = EditOrganizationUseCase(graphRepo);
  final deleteOrganizationUseCase = DeleteOrganizationUseCase(graphRepo);

  // 3. Initialize ViewModels (Singletons)
  final graphViewModel = GraphViewModel();

  final taskListsViewModel = TaskListsViewModel(
    repository: graphRepo,
    createTaskListUseCase: createTaskListUseCase,
    deleteTaskListUseCase: deleteTaskListUseCase,
    editTaskListUseCase: editTaskListUseCase,
    exportDatasetUseCase: exportDatasetUseCase,
  );

  final todoListViewModel = TodoListViewModel(
    repository: graphRepo,
    createTaskUseCase: createTaskUseCase,
    deleteTaskUseCase: deleteTaskUseCase,
    editTaskUseCase: editTaskUseCase,
    hydrateUseCase: hydrateUseCase,
    toggleStatusUseCase: toggleStatusUseCase,
  );

  final peopleViewModel = PeopleViewModel(
    repository: graphRepo,
    createPersonUseCase: createPersonUseCase,
    editPersonUseCase: editPersonUseCase,
    deletePersonUseCase: deletePersonUseCase,
    graphViewModel: graphViewModel,
  );

  final organizationsViewModel = OrganizationsViewModel(
    repository: graphRepo,
    createOrganizationUseCase: createOrganizationUseCase,
    editOrganizationUseCase: editOrganizationUseCase,
    deleteOrganizationUseCase: deleteOrganizationUseCase,
    graphViewModel: graphViewModel,
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
            routes: [
              GoRoute(
                path: 'tasks/create',
                builder: (context, state) {
                  final listId = state.pathParameters['id']!;
                  return TaskFormView(
                    viewModel: todoListViewModel,
                    graphViewModel: graphViewModel,
                    listId: listId,
                  );
                },
              ),
              GoRoute(
                path: 'tasks/:taskId',
                builder: (context, state) {
                  final listId = state.pathParameters['id']!;
                  final taskId = state.pathParameters['taskId']!;
                  return TaskDetailView(
                    viewModel: todoListViewModel,
                    graphViewModel: graphViewModel,
                    listId: listId,
                    taskId: taskId,
                  );
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) {
                      final listId = state.pathParameters['id']!;
                      final taskId = state.pathParameters['taskId']!;
                      return TaskFormView(
                        viewModel: todoListViewModel,
                        graphViewModel: graphViewModel,
                        listId: listId,
                        taskId: taskId,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/people',
            builder: (context, state) => PeopleView(viewModel: peopleViewModel),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => PersonFormView(
                  viewModel: peopleViewModel,
                  organizationsViewModel: organizationsViewModel,
                ),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return PersonDetailView(
                    viewModel: peopleViewModel,
                    organizationsViewModel: organizationsViewModel,
                    personId: id,
                  );
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return PersonFormView(
                        viewModel: peopleViewModel,
                        organizationsViewModel: organizationsViewModel,
                        personId: id,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/organizations',
            builder: (context, state) =>
                OrganizationsView(viewModel: organizationsViewModel),
            routes: [
              GoRoute(
                path: 'create',
                builder: (context, state) => OrganizationFormView(
                  viewModel: organizationsViewModel,
                  peopleViewModel: peopleViewModel,
                ),
              ),
              GoRoute(
                path: ':id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return OrganizationDetailView(
                    viewModel: organizationsViewModel,
                    peopleViewModel: peopleViewModel,
                    organizationId: id,
                  );
                },
                routes: [
                  GoRoute(
                    path: 'edit',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return OrganizationFormView(
                        viewModel: organizationsViewModel,
                        peopleViewModel: peopleViewModel,
                        organizationId: id,
                      );
                    },
                  ),
                ],
              ),
            ],
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
