import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge_graph/ui/features/creative_works/view_models/creative_works_view_model.dart';

class CreativeWorksView extends StatefulWidget {
  final CreativeWorksViewModel viewModel;

  const CreativeWorksView({super.key, required this.viewModel});

  @override
  State<CreativeWorksView> createState() => _CreativeWorksViewState();
}

class _CreativeWorksViewState extends State<CreativeWorksView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Creative Works'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          if (widget.viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (widget.viewModel.creativeWorks.isEmpty) {
            return const Center(
              child: Text('No creative works found. Click + to add one.'),
            );
          }

          return ListView.builder(
            itemCount: widget.viewModel.creativeWorks.length,
            itemBuilder: (context, index) {
              final creativeWork = widget.viewModel.creativeWorks[index];
              return Dismissible(
                key: Key(creativeWork.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  widget.viewModel.deleteCreativeWork(creativeWork);
                },
                child: ListTile(
                  title: Text(creativeWork.name),
                  subtitle: Text(creativeWork.workType.toSchemaString()),
                  onTap: () => context.go('/creative-works/${creativeWork.id}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => context.go(
                          '/creative-works/${creativeWork.id}/edit',
                        ),
                        tooltip: 'Edit Creative Work',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Creative Work?'),
                              content: Text(
                                'Are you sure you want to delete ${creativeWork.name}?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
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
                            widget.viewModel.deleteCreativeWork(creativeWork);
                          }
                        },
                        tooltip: 'Delete Creative Work',
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/creative-works/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
