import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge_graph/ui/features/organizations/view_models/organizations_view_model.dart';

class OrganizationsView extends StatefulWidget {
  final OrganizationsViewModel viewModel;

  const OrganizationsView({super.key, required this.viewModel});

  @override
  State<OrganizationsView> createState() => _OrganizationsViewState();
}

class _OrganizationsViewState extends State<OrganizationsView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizations'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          if (widget.viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (widget.viewModel.organizations.isEmpty) {
            return const Center(
              child: Text('No organizations found. Click + to add one.'),
            );
          }

          return ListView.builder(
            itemCount: widget.viewModel.organizations.length,
            itemBuilder: (context, index) {
              final organization = widget.viewModel.organizations[index];
              return Dismissible(
                key: Key(organization.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  widget.viewModel.deleteOrganization(organization);
                },
                child: ListTile(
                  title: Text(organization.name),
                  subtitle: Text(organization.orgType.toSchemaString()),
                  onTap: () => context.go('/organizations/${organization.id}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () => context.go(
                          '/organizations/${organization.id}/edit',
                        ),
                        tooltip: 'Edit Organization',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Organization?'),
                              content: Text(
                                'Are you sure you want to delete ${organization.name}?',
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
                            widget.viewModel.deleteOrganization(organization);
                          }
                        },
                        tooltip: 'Delete Organization',
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
        onPressed: () => context.go('/organizations/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
