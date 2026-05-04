import 'package:go_router/go_router.dart';
import 'package:knowledge_graph/injection_container.dart' as di;

import 'package:knowledge_graph/ui/features/todo/view_models/todo_list_view_model.dart';
import 'package:knowledge_graph/ui/features/todo/view_models/task_lists_view_model.dart';
import 'package:knowledge_graph/ui/features/todo/views/todo_list_view.dart';
import 'package:knowledge_graph/ui/features/todo/views/task_lists_view.dart';
import 'package:knowledge_graph/ui/features/todo/views/task_detail_view.dart';
import 'package:knowledge_graph/ui/features/todo/views/task_form_view.dart';
import 'package:knowledge_graph/ui/shared/view_models/graph_view_model.dart';
import 'package:knowledge_graph/ui/layout/main_layout.dart';

import 'package:knowledge_graph/ui/features/people/view_models/people_view_model.dart';
import 'package:knowledge_graph/ui/features/people/views/people_view.dart';

import 'package:knowledge_graph/ui/features/organizations/view_models/organizations_view_model.dart';
import 'package:knowledge_graph/ui/features/organizations/views/organizations_view.dart';
import 'package:knowledge_graph/ui/features/people/views/person_form_view.dart';
import 'package:knowledge_graph/ui/features/people/views/person_detail_view.dart';
import 'package:knowledge_graph/ui/features/organizations/views/organization_form_view.dart';
import 'package:knowledge_graph/ui/features/organizations/views/organization_detail_view.dart';

import 'package:knowledge_graph/ui/features/things/view_models/things_view_model.dart';
import 'package:knowledge_graph/ui/features/things/views/things_view.dart';
import 'package:knowledge_graph/ui/features/things/views/thing_form_view.dart';
import 'package:knowledge_graph/ui/features/things/views/thing_detail_view.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainLayout(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              TaskListsView(viewModel: di.sl<TaskListsViewModel>()),
        ),
        GoRoute(
          path: '/lists/:id',
          builder: (context, state) {
            final listId = state.pathParameters['id']!;
            return TodoListView(
              listId: listId,
              viewModel: di.sl<TodoListViewModel>(),
            );
          },
          routes: [
            GoRoute(
              path: 'tasks/create',
              builder: (context, state) {
                final listId = state.pathParameters['id']!;
                return TaskFormView(
                  viewModel: di.sl<TodoListViewModel>(),
                  graphViewModel: di.sl<GraphViewModel>(),
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
                  viewModel: di.sl<TodoListViewModel>(),
                  graphViewModel: di.sl<GraphViewModel>(),
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
                      viewModel: di.sl<TodoListViewModel>(),
                      graphViewModel: di.sl<GraphViewModel>(),
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
          builder: (context, state) =>
              PeopleView(viewModel: di.sl<PeopleViewModel>()),
          routes: [
            GoRoute(
              path: 'create',
              builder: (context, state) => PersonFormView(
                viewModel: di.sl<PeopleViewModel>(),
                graphViewModel: di.sl<GraphViewModel>(),
              ),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return PersonDetailView(
                  viewModel: di.sl<PeopleViewModel>(),
                  graphViewModel: di.sl<GraphViewModel>(),
                  personId: id,
                );
              },
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return PersonFormView(
                      viewModel: di.sl<PeopleViewModel>(),
                      graphViewModel: di.sl<GraphViewModel>(),
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
              OrganizationsView(viewModel: di.sl<OrganizationsViewModel>()),
          routes: [
            GoRoute(
              path: 'create',
              builder: (context, state) => OrganizationFormView(
                viewModel: di.sl<OrganizationsViewModel>(),
                graphViewModel: di.sl<GraphViewModel>(),
              ),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return OrganizationDetailView(
                  viewModel: di.sl<OrganizationsViewModel>(),
                  graphViewModel: di.sl<GraphViewModel>(),
                  organizationId: id,
                );
              },
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return OrganizationFormView(
                      viewModel: di.sl<OrganizationsViewModel>(),
                      graphViewModel: di.sl<GraphViewModel>(),
                      organizationId: id,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/things',
          builder: (context, state) =>
              ThingsView(viewModel: di.sl<ThingsViewModel>()),
          routes: [
            GoRoute(
              path: 'add',
              builder: (context, state) =>
                  ThingFormView(viewModel: di.sl<ThingsViewModel>()),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return ThingDetailView(
                  viewModel: di.sl<ThingsViewModel>(),
                  graphViewModel: di.sl<GraphViewModel>(),
                  thingId: id,
                );
              },
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return ThingFormView(
                      viewModel: di.sl<ThingsViewModel>(),
                      thingId: id,
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
