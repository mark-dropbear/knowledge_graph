import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge_graph/domain/models/creative_work.dart';
import 'package:knowledge_graph/domain/models/person.dart';
import 'package:knowledge_graph/domain/models/organization.dart';
import 'package:knowledge_graph/domain/models/thing.dart';
import 'package:knowledge_graph/ui/features/creative_works/view_models/creative_works_view_model.dart';
import 'package:knowledge_graph/ui/shared/view_models/graph_view_model.dart';
import 'package:knowledge_graph/ui/shared/widgets/person_card.dart';
import 'package:knowledge_graph/ui/shared/widgets/organization_card.dart';

class CreativeWorkDetailView extends StatelessWidget {
  final CreativeWorksViewModel viewModel;
  final GraphViewModel graphViewModel;
  final String creativeWorkId;

  const CreativeWorkDetailView({
    super.key,
    required this.viewModel,
    required this.graphViewModel,
    required this.creativeWorkId,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([viewModel, graphViewModel]),
      builder: (context, _) {
        CreativeWork? creativeWork;
        try {
          creativeWork = viewModel.creativeWorks.firstWhere(
            (cw) => cw.id == creativeWorkId,
          );
        } catch (e) {
          return Scaffold(
            appBar: AppBar(title: const Text('Creative Work Details')),
            body: const Center(child: Text('Creative work not found.')),
          );
        }

        final allPeople = graphViewModel.getItems<Person>();
        final allOrganizations = graphViewModel.getItems<Organization>();
        
        final linkedAuthors = creativeWork.author
            .map((authorId) {
              try {
                return allPeople.firstWhere((p) => p.id == authorId) as Thing;
              } catch (e) {
                try {
                  return allOrganizations.firstWhere((o) => o.id == authorId) as Thing;
                } catch (e) {
                  return null;
                }
              }
            })
            .whereType<Thing>()
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(creativeWork.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () =>
                    context.go('/creative-works/${creativeWork!.id}/edit'),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Creative Work?'),
                      content: Text(
                        'Are you sure you want to delete ${creativeWork!.name}?',
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
                    await viewModel.deleteCreativeWork(creativeWork!);
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
                'Creative Work Type',
                creativeWork.workType.toSchemaString(),
              ),
              _buildDetailRow(context, 'Name', creativeWork.name),
              _buildDetailRow(context, 'Description', creativeWork.description),
              _buildDetailRow(context, 'URL', creativeWork.url),
              if (linkedAuthors.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Authors',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                ...linkedAuthors.map((author) {
                  if (author is Person) {
                    return PersonCard(
                      person: author,
                      onTap: () => context.push('/people/${author.id}'),
                    );
                  } else if (author is Organization) {
                    return OrganizationCard(
                      organization: author,
                      onTap: () => context.push('/organizations/${author.id}'),
                    );
                  }
                  return const SizedBox.shrink();
                }),
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
