import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge_graph/domain/models/organization.dart';
import 'package:knowledge_graph/ui/features/organizations/view_models/organizations_view_model.dart';

class OrganizationFormView extends StatefulWidget {
  final OrganizationsViewModel viewModel;
  final String? organizationId;

  const OrganizationFormView({
    super.key,
    required this.viewModel,
    this.organizationId,
  });

  @override
  State<OrganizationFormView> createState() => _OrganizationFormViewState();
}

class _OrganizationFormViewState extends State<OrganizationFormView> {
  late final TextEditingController _nameController;
  late final TextEditingController _legalNameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _urlController;
  OrganizationType _selectedType = OrganizationType.organization;
  Organization? _existingOrganization;

  @override
  void initState() {
    super.initState();
    if (widget.organizationId != null) {
      try {
        _existingOrganization = widget.viewModel.organizations.firstWhere(
          (o) => o.id == widget.organizationId,
        );
      } catch (e) {
        _existingOrganization = null;
      }
    }

    _nameController = TextEditingController(text: _existingOrganization?.name);
    _legalNameController = TextEditingController(
      text: _existingOrganization?.legalName,
    );
    _descriptionController = TextEditingController(
      text: _existingOrganization?.description,
    );
    _urlController = TextEditingController(text: _existingOrganization?.url);
    _selectedType =
        _existingOrganization?.orgType ?? OrganizationType.organization;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _legalNameController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  bool _isValid() {
    return _nameController.text.trim().isNotEmpty;
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final legalName = _legalNameController.text.trim();
    final description = _descriptionController.text.trim();
    final url = _urlController.text.trim();

    if (_existingOrganization == null) {
      await widget.viewModel.addOrganization(
        name: name,
        orgType: _selectedType,
        legalName: legalName.isEmpty ? null : legalName,
        description: description.isEmpty ? null : description,
        url: url.isEmpty ? null : url,
      );
    } else {
      await widget.viewModel.editOrganization(
        _existingOrganization!,
        name: name,
        orgType: _selectedType,
        legalName: legalName.isEmpty ? null : legalName,
        description: description.isEmpty ? null : description,
        url: url.isEmpty ? null : url,
      );
    }

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _existingOrganization == null
              ? 'Add Organization'
              : 'Edit Organization',
        ),
        actions: [
          TextButton(
            onPressed: _isValid() ? _save : null,
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<OrganizationType>(
              initialValue: _selectedType,
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
                    _selectedType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name *',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
              autofocus: _existingOrganization == null,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _legalNameController,
              decoration: const InputDecoration(
                labelText: 'Legal Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'URL',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
      ),
    );
  }
}
