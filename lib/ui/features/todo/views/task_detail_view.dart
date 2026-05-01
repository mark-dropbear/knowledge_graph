import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge_graph/domain/models/task.dart';
import 'package:knowledge_graph/domain/models/person.dart';
import 'package:knowledge_graph/domain/models/organization.dart';
import 'package:knowledge_graph/ui/features/todo/view_models/todo_list_view_model.dart';
import 'package:knowledge_graph/ui/shared/view_models/graph_view_model.dart';
import 'package:knowledge_graph/ui/shared/widgets/person_card.dart';
import 'package:knowledge_graph/ui/shared/widgets/organization_card.dart';

class TaskDetailView extends StatelessWidget {
  final TodoListViewModel viewModel;
  final GraphViewModel graphViewModel;
  final String listId;
  final String taskId;

  const TaskDetailView({
    super.key,
    required this.viewModel,
    required this.graphViewModel,
    required this.listId,
    required this.taskId,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([viewModel, graphViewModel]),
      builder: (context, _) {
        Task? task;
        try {
          task = viewModel.tasks.firstWhere((t) => t.id == taskId);
        } catch (e) {
          return Scaffold(
            appBar: AppBar(title: const Text('Task Details')),
            body: const Center(child: Text('Task not found.')),
          );
        }

        final linkedPeople = task.agent
            .map((agentId) => graphViewModel.resolve<Person>(agentId))
            .whereType<Person>()
            .toList();

        final linkedOrganizations = task.agent
            .map((agentId) => graphViewModel.resolve<Organization>(agentId))
            .whereType<Organization>()
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(task.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.go(
                  '/lists/${Uri.encodeComponent(listId)}/tasks/${Uri.encodeComponent(taskId)}/edit',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Task?'),
                      content: Text(
                        'Are you sure you want to delete ${task!.name}?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await viewModel.deleteTask(task!);
                    if (context.mounted) {
                      context.pop();
                    }
                  }
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildDetailRow(context, 'Name', task.name),
              _buildDetailRow(context, 'Status', task.actionStatus.name),
              _buildDetailRow(context, 'Description', task.description),
              _buildDetailRow(context, 'End Time', task.endTime),
              if (linkedPeople.isNotEmpty ||
                  linkedOrganizations.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Assignees',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                ...linkedPeople.map(
                  (person) => PersonCard(
                    person: person,
                    onTap: () => context.push(
                      '/people/${Uri.encodeComponent(person.id)}',
                    ),
                  ),
                ),
                ...linkedOrganizations.map(
                  (org) => OrganizationCard(
                    organization: org,
                    onTap: () => context.push(
                      '/organizations/${Uri.encodeComponent(org.id)}',
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String? value) {
    if (value == null || value.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
          const Divider(),
        ],
      ),
    );
  }
}
