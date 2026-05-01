import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge_graph/domain/models/person.dart';
import 'package:knowledge_graph/ui/features/people/view_models/people_view_model.dart';
import 'package:knowledge_graph/ui/features/organizations/view_models/organizations_view_model.dart';
import 'package:knowledge_graph/ui/shared/widgets/resource_selection_modal.dart';

class PersonFormView extends StatefulWidget {
  final PeopleViewModel viewModel;
  final OrganizationsViewModel organizationsViewModel;
  final String? personId;

  const PersonFormView({
    super.key,
    required this.viewModel,
    required this.organizationsViewModel,
    this.personId,
  });

  @override
  State<PersonFormView> createState() => _PersonFormViewState();
}

class _PersonFormViewState extends State<PersonFormView> {
  late final TextEditingController _givenNameController;
  late final TextEditingController _familyNameController;
  late final TextEditingController _jobTitleController;
  late final TextEditingController _birthDateController;
  List<String> _selectedWorksFor = [];
  Person? _existingPerson;

  @override
  void initState() {
    super.initState();
    if (widget.personId != null) {
      try {
        _existingPerson = widget.viewModel.people.firstWhere(
          (p) => p.id == widget.personId,
        );
      } catch (e) {
        _existingPerson = null;
      }
    }

    _givenNameController = TextEditingController(
      text: _existingPerson?.givenName,
    );
    _familyNameController = TextEditingController(
      text: _existingPerson?.familyName,
    );
    _jobTitleController = TextEditingController(
      text: _existingPerson?.jobTitle,
    );
    _birthDateController = TextEditingController(
      text: _existingPerson?.birthDate,
    );
    _selectedWorksFor = List.from(_existingPerson?.worksFor ?? []);
  }

  @override
  void dispose() {
    _givenNameController.dispose();
    _familyNameController.dispose();
    _jobTitleController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  bool _isValid() {
    final givenName = _givenNameController.text.trim();
    final familyName = _familyNameController.text.trim();
    return givenName.isNotEmpty || familyName.isNotEmpty;
  }

  Future<void> _save() async {
    final givenName = _givenNameController.text.trim();
    final familyName = _familyNameController.text.trim();
    final jobTitle = _jobTitleController.text.trim();
    final birthDateStr = _birthDateController.text.trim();

    if (_existingPerson == null) {
      await widget.viewModel.addPerson(
        givenName: givenName.isEmpty ? null : givenName,
        familyName: familyName.isEmpty ? null : familyName,
        jobTitle: jobTitle.isEmpty ? null : jobTitle,
        birthDate: birthDateStr.isEmpty ? null : birthDateStr,
        worksFor: _selectedWorksFor,
      );
    } else {
      await widget.viewModel.editPerson(
        _existingPerson!,
        givenName: givenName.isEmpty ? null : givenName,
        familyName: familyName.isEmpty ? null : familyName,
        jobTitle: jobTitle.isEmpty ? null : jobTitle,
        birthDate: birthDateStr.isEmpty ? null : birthDateStr,
        worksFor: _selectedWorksFor,
      );
    }

    if (mounted) {
      context.pop();
    }
  }

  Future<void> _selectOrganizations() async {
    await ResourceSelectionModal.show(
      context: context,
      title: 'Select Organizations',
      initialSelectedIds: _selectedWorksFor,
      fetchItems: () async {
        await widget.organizationsViewModel.initialize();
        return Map.fromEntries(
          widget.organizationsViewModel.organizations.map(
            (o) => MapEntry(o.id, o.name),
          ),
        );
      },
      onSelectionSaved: (selectedIds) {
        setState(() {
          _selectedWorksFor = selectedIds;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_existingPerson == null ? 'Add Person' : 'Edit Person'),
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
            TextField(
              controller: _givenNameController,
              decoration: const InputDecoration(
                labelText: 'Given Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
              autofocus: _existingPerson == null,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _familyNameController,
              decoration: const InputDecoration(
                labelText: 'Family Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _jobTitleController,
              decoration: const InputDecoration(
                labelText: 'Job Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _birthDateController,
              decoration: const InputDecoration(
                labelText: 'Birth Date (YYYY-MM-DD)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 24),
            Text('Works For', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('${_selectedWorksFor.length} organizations selected'),
              trailing: FilledButton.tonal(
                onPressed: _selectOrganizations,
                child: const Text('Edit Links'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
