import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge_graph/domain/models/organization.dart';
import 'package:knowledge_graph/domain/models/person.dart';
import 'package:knowledge_graph/ui/features/organizations/view_models/organizations_view_model.dart';
import 'package:knowledge_graph/ui/shared/view_models/graph_view_model.dart';
import 'package:knowledge_graph/ui/shared/widgets/person_card.dart';

class OrganizationDetailView extends StatelessWidget {
  final OrganizationsViewModel viewModel;
  final GraphViewModel graphViewModel;
  final String organizationId;

  const OrganizationDetailView({
    super.key,
    required this.viewModel,
    required this.graphViewModel,
    required this.organizationId,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([viewModel, graphViewModel]),
      builder: (context, _) {
        Organization? organization;
        try {
          organization = viewModel.organizations.firstWhere(
            (o) => o.id == organizationId,
          );
        } catch (e) {
          return Scaffold(
            appBar: AppBar(title: const Text('Organization Details')),
            body: const Center(child: Text('Organization not found.')),
          );
        }

        final allPeople = graphViewModel.getItems<Person>();
        final linkedPeople = organization.employee
            .map((personId) {
              try {
                return allPeople.firstWhere((p) => p.id == personId);
              } catch (e) {
                return null;
              }
            })
            .whereType<Person>()
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(organization.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () =>
                    context.go('/organizations/${organization!.id}/edit'),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Organization?'),
                      content: Text(
                        'Are you sure you want to delete ${organization!.name}?',
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
                    await viewModel.deleteOrganization(organization!);
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
              _buildDetailRow(
                context,
                'Organization Type',
                organization.orgType.toSchemaString(),
              ),
              _buildDetailRow(context, 'Name', organization.name),
              _buildDetailRow(context, 'Legal Name', organization.legalName),
              _buildDetailRow(context, 'Description', organization.description),
              _buildDetailRow(context, 'URL', organization.url),
              if (linkedPeople.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Employees',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                ...linkedPeople.map(
                  (person) => PersonCard(
                    person: person,
                    onTap: () => context.push('/people/${person.id}'),
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
