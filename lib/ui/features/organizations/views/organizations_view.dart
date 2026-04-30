import 'package:flutter/material.dart';
import 'package:knowledge_graph/domain/models/organization.dart';
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

  void _showAddOrganizationModal(BuildContext context) {
    _showOrganizationModal(context);
  }

  void _showEditOrganizationModal(
    BuildContext context,
    Organization organization,
  ) {
    _showOrganizationModal(context, organization: organization);
  }

  void _showOrganizationModal(
    BuildContext context, {
    Organization? organization,
  }) {
    final nameController = TextEditingController(text: organization?.name);
    final legalNameController = TextEditingController(
      text: organization?.legalName,
    );
    final descriptionController = TextEditingController(
      text: organization?.description,
    );
    final urlController = TextEditingController(text: organization?.url);
    OrganizationType selectedType =
        organization?.orgType ?? OrganizationType.organization;

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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      organization == null
                          ? 'Add Organization'
                          : 'Edit Organization',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<OrganizationType>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Organization Type',
                        border: OutlineInputBorder(),
                      ),
                      items: OrganizationType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type.toSchemaString()),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name *',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => updateState(),
                      autofocus: organization == null,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: legalNameController,
                      decoration: const InputDecoration(
                        labelText: 'Legal Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: urlController,
                      decoration: const InputDecoration(
                        labelText: 'URL',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (organization != null)
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                            onPressed: () {
                              widget.viewModel.deleteOrganization(organization);
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.delete),
                            label: const Text('Delete'),
                          )
                        else
                          const SizedBox.shrink(),
                        ElevatedButton(
                          onPressed: nameController.text.trim().isEmpty
                              ? null
                              : () {
                                  final name = nameController.text.trim();
                                  final legalName = legalNameController.text
                                      .trim();
                                  final description = descriptionController.text
                                      .trim();
                                  final url = urlController.text.trim();

                                  if (organization == null) {
                                    widget.viewModel.addOrganization(
                                      name: name,
                                      orgType: selectedType,
                                      legalName: legalName.isEmpty
                                          ? null
                                          : legalName,
                                      description: description.isEmpty
                                          ? null
                                          : description,
                                      url: url.isEmpty ? null : url,
                                    );
                                  } else {
                                    widget.viewModel.editOrganization(
                                      organization,
                                      name: name,
                                      orgType: selectedType,
                                      legalName: legalName.isEmpty
                                          ? null
                                          : legalName,
                                      description: description.isEmpty
                                          ? null
                                          : description,
                                      url: url.isEmpty ? null : url,
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
                  onTap: () =>
                      _showEditOrganizationModal(context, organization),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrganizationModal(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}
