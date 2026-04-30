import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge_graph/ui/features/people/view_models/people_view_model.dart';

class PeopleView extends StatefulWidget {
  final PeopleViewModel viewModel;

  const PeopleView({super.key, required this.viewModel});

  @override
  State<PeopleView> createState() => _PeopleViewState();
}

class _PeopleViewState extends State<PeopleView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('People'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          if (widget.viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (widget.viewModel.people.isEmpty) {
            return const Center(
              child: Text('No people found. Click + to add one.'),
            );
          }

          return ListView.builder(
            itemCount: widget.viewModel.people.length,
            itemBuilder: (context, index) {
              final person = widget.viewModel.people[index];
              final displayName = [
                person.givenName,
                person.familyName,
              ].where((n) => n != null && n.isNotEmpty).join(' ');

              return Dismissible(
                key: Key(person.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  widget.viewModel.deletePerson(person);
                },
                child: ListTile(
                  title: Text(displayName),
                  subtitle: person.jobTitle != null
                      ? Text(person.jobTitle!)
                      : null,
                  onTap: () => context.go('/people/${person.id}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () =>
                            context.go('/people/${person.id}/edit'),
                        tooltip: 'Edit Person',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
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
                            widget.viewModel.deletePerson(person);
                          }
                        },
                        tooltip: 'Delete Person',
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
        onPressed: () => context.go('/people/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
