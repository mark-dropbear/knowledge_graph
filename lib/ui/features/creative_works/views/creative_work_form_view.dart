import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge_graph/domain/models/creative_work.dart';
import 'package:knowledge_graph/ui/features/creative_works/view_models/creative_works_view_model.dart';
import 'package:knowledge_graph/domain/models/person.dart';
import 'package:knowledge_graph/domain/models/organization.dart';
import 'package:knowledge_graph/ui/shared/view_models/graph_view_model.dart';
import 'package:knowledge_graph/ui/shared/widgets/multi_type_resource_selection_modal.dart';

class CreativeWorkFormView extends StatefulWidget {
  final CreativeWorksViewModel viewModel;
  final GraphViewModel graphViewModel;
  final String? creativeWorkId;

  const CreativeWorkFormView({
    super.key,
    required this.viewModel,
    required this.graphViewModel,
    this.creativeWorkId,
  });

  @override
  State<CreativeWorkFormView> createState() => _CreativeWorkFormViewState();
}

class _CreativeWorkFormViewState extends State<CreativeWorkFormView> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _urlController;
  CreativeWorkType _selectedType = CreativeWorkType.creativeWork;
  List<String> _selectedAuthors = [];
  CreativeWork? _existingCreativeWork;

  @override
  void initState() {
    super.initState();
    if (widget.creativeWorkId != null) {
      try {
        _existingCreativeWork = widget.viewModel.creativeWorks.firstWhere(
          (cw) => cw.id == widget.creativeWorkId,
        );
      } catch (e) {
        _existingCreativeWork = null;
      }
    }

    _nameController = TextEditingController(text: _existingCreativeWork?.name);
    _descriptionController = TextEditingController(
      text: _existingCreativeWork?.description,
    );
    _urlController = TextEditingController(text: _existingCreativeWork?.url);
    _selectedType = _existingCreativeWork?.workType ?? CreativeWorkType.creativeWork;
    _selectedAuthors = List.from(_existingCreativeWork?.author ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  bool _isValid() {
    if (_nameController.text.trim().isEmpty) return false;
    if ((_selectedType == CreativeWorkType.website || _selectedType == CreativeWorkType.webPage) && 
        _urlController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final url = _urlController.text.trim();

    if (_existingCreativeWork == null) {
      await widget.viewModel.addCreativeWork(
        name: name,
        workType: _selectedType,
        description: description.isEmpty ? null : description,
        url: url.isEmpty ? null : url,
        author: _selectedAuthors,
      );
    } else {
      await widget.viewModel.editCreativeWork(
        _existingCreativeWork!,
        name: name,
        workType: _selectedType,
        description: description.isEmpty ? null : description,
        url: url.isEmpty ? null : url,
        author: _selectedAuthors,
      );
    }

    if (mounted) {
      context.pop();
    }
  }

  Future<void> _selectAuthors() async {
    await MultiTypeResourceSelectionModal.show(
      context: context,
      title: 'Select Authors',
      initialSelectedIds: _selectedAuthors,
      tabs: [
        ResourceTab(
          label: 'People',
          fetchItems: () async {
            final people = widget.graphViewModel.getItems<Person>();
            return Map.fromEntries(
              people.map(
                (p) => MapEntry(
                  p.id,
                  '${p.givenName ?? ''} ${p.familyName ?? ''}'.trim(),
                ),
              ),
            );
          },
        ),
        ResourceTab(
          label: 'Organizations',
          fetchItems: () async {
            final organizations = widget.graphViewModel.getItems<Organization>();
            return Map.fromEntries(
              organizations.map(
                (o) => MapEntry(o.id, o.name),
              ),
            );
          },
        ),
      ],
      onSelectionSaved: (selectedIds) {
        setState(() {
          _selectedAuthors = selectedIds;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _existingCreativeWork == null
              ? 'Add Creative Work'
              : 'Edit Creative Work',
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
            DropdownButtonFormField<CreativeWorkType>(
              initialValue: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Creative Work Type',
                border: OutlineInputBorder(),
              ),
              items: CreativeWorkType.values.map((type) {
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
              autofocus: _existingCreativeWork == null,
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
              decoration: InputDecoration(
                labelText: (_selectedType == CreativeWorkType.website || _selectedType == CreativeWorkType.webPage) ? 'URL *' : 'URL',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            Text('Authors', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('${_selectedAuthors.length} authors selected'),
              trailing: FilledButton.tonal(
                onPressed: _selectAuthors,
                child: const Text('Edit Links'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
