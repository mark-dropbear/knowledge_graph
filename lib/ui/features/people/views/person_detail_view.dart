import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge_graph/domain/models/person.dart';
import 'package:knowledge_graph/ui/features/people/view_models/people_view_model.dart';

class PersonDetailView extends StatelessWidget {
  final PeopleViewModel viewModel;
  final String personId;

  const PersonDetailView({
    super.key,
    required this.viewModel,
    required this.personId,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        Person? person;
        try {
          person = viewModel.people.firstWhere((p) => p.id == personId);
        } catch (e) {
          return Scaffold(
            appBar: AppBar(title: const Text('Person Details')),
            body: const Center(child: Text('Person not found.')),
          );
        }

        final displayName = [
          person.givenName,
          person.familyName,
        ].whereType<String>().join(' ');

        return Scaffold(
          appBar: AppBar(
            title: Text(displayName),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.go('/people/${person!.id}/edit'),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Person?'),
                      content: Text(
                        'Are you sure you want to delete $displayName?',
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
                    await viewModel.deletePerson(person!);
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
              _buildDetailRow(context, 'Given Name', person.givenName),
              _buildDetailRow(context, 'Family Name', person.familyName),
              _buildDetailRow(context, 'Job Title', person.jobTitle),
              _buildDetailRow(
                context,
                'Birth Date',
                person.birthDate,
              ),
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
