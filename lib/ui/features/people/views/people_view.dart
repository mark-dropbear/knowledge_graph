import 'package:flutter/material.dart';
import 'package:knowledge_graph/domain/models/person.dart';
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

  void _showAddPersonModal(BuildContext context) {
    _showPersonModal(context);
  }

  void _showEditPersonModal(BuildContext context, Person person) {
    _showPersonModal(context, person: person);
  }

  void _showPersonModal(BuildContext context, {Person? person}) {
    final givenNameController = TextEditingController(text: person?.givenName);
    final familyNameController = TextEditingController(
      text: person?.familyName,
    );
    final jobTitleController = TextEditingController(text: person?.jobTitle);
    final birthDateController = TextEditingController(text: person?.birthDate);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void updateState() {
              setState(() {});
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      person == null ? 'Add Person' : 'Edit Person',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: givenNameController,
                      decoration: const InputDecoration(
                        labelText: 'Given Name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => updateState(),
                      autofocus: person == null,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: familyNameController,
                      decoration: const InputDecoration(
                        labelText: 'Family Name',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => updateState(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: jobTitleController,
                      decoration: const InputDecoration(
                        labelText: 'Job Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: birthDateController,
                      decoration: const InputDecoration(
                        labelText: 'Birth Date (e.g. YYYY-MM-DD)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (person != null)
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            onPressed: () {
                              widget.viewModel.deletePerson(person);
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.delete),
                            label: const Text('Delete'),
                          )
                        else
                          const SizedBox.shrink(),
                        ElevatedButton(
                          onPressed:
                              (givenNameController.text.trim().isEmpty &&
                                  familyNameController.text.trim().isEmpty)
                              ? null
                              : () {
                                  final givenName = givenNameController.text
                                      .trim();
                                  final familyName = familyNameController.text
                                      .trim();
                                  final jobTitle = jobTitleController.text
                                      .trim();
                                  final birthDate = birthDateController.text
                                      .trim();

                                  if (person == null) {
                                    widget.viewModel.addPerson(
                                      givenName: givenName.isEmpty
                                          ? null
                                          : givenName,
                                      familyName: familyName.isEmpty
                                          ? null
                                          : familyName,
                                      jobTitle: jobTitle.isEmpty
                                          ? null
                                          : jobTitle,
                                      birthDate: birthDate.isEmpty
                                          ? null
                                          : birthDate,
                                    );
                                  } else {
                                    widget.viewModel.editPerson(
                                      person,
                                      givenName: givenName.isEmpty
                                          ? null
                                          : givenName,
                                      familyName: familyName.isEmpty
                                          ? null
                                          : familyName,
                                      jobTitle: jobTitle.isEmpty
                                          ? null
                                          : jobTitle,
                                      birthDate: birthDate.isEmpty
                                          ? null
                                          : birthDate,
                                    );
                                  }
                                  Navigator.pop(context);
                                },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
                  onTap: () => _showEditPersonModal(context, person),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPersonModal(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
