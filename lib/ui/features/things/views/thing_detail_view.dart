import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge_graph/domain/models/thing_instance.dart';
import 'package:knowledge_graph/ui/features/things/view_models/things_view_model.dart';
import 'package:knowledge_graph/ui/shared/view_models/graph_view_model.dart';

class ThingDetailView extends StatelessWidget {
  final ThingsViewModel viewModel;
  final GraphViewModel graphViewModel;
  final String thingId;

  const ThingDetailView({
    super.key,
    required this.viewModel,
    required this.graphViewModel,
    required this.thingId,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([viewModel, graphViewModel]),
      builder: (context, _) {
        ThingInstance? thing;
        try {
          thing = viewModel.things.firstWhere((t) => t.id == thingId);
        } catch (e) {
          return Scaffold(
            appBar: AppBar(title: const Text('Thing Details')),
            body: const Center(child: Text('Thing not found.')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(thing.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.go(
                  '/things/${Uri.encodeComponent(thing!.id)}/edit',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Thing?'),
                      content: Text(
                        'Are you sure you want to delete ${thing!.name}?',
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
                    await viewModel.deleteThing(thing!);
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
              _buildDetailRow(context, 'Name', thing.name),
              _buildDetailRow(context, 'Description', thing.description),
              _buildDetailRow(context, 'URL', thing.url),
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
