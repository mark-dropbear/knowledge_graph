import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge_graph/domain/models/task.dart';
import 'package:knowledge_graph/domain/models/person.dart';
import 'package:knowledge_graph/domain/models/organization.dart';
import 'package:knowledge_graph/ui/features/todo/view_models/todo_list_view_model.dart';
import 'package:knowledge_graph/ui/shared/view_models/graph_view_model.dart';
import 'package:knowledge_graph/ui/shared/widgets/multi_type_resource_selection_modal.dart';

class TaskFormView extends StatefulWidget {
  final TodoListViewModel viewModel;
  final GraphViewModel graphViewModel;
  final String listId;
  final String? taskId;

  const TaskFormView({
    super.key,
    required this.viewModel,
    required this.graphViewModel,
    required this.listId,
    this.taskId,
  });

  @override
  State<TaskFormView> createState() => _TaskFormViewState();
}

class _TaskFormViewState extends State<TaskFormView> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  List<String> _selectedAgentIds = [];
  List<String> _selectedParticipantIds = [];
  Task? _existingTask;

  @override
  void initState() {
    super.initState();
    if (widget.taskId != null) {
      try {
        _existingTask = widget.viewModel.tasks.firstWhere(
          (t) => t.id == widget.taskId,
        );
      } catch (e) {
        _existingTask = null;
      }
    }

    _nameController = TextEditingController(text: _existingTask?.name);
    _descriptionController = TextEditingController(
      text: _existingTask?.description,
    );
    _selectedAgentIds = List.from(_existingTask?.agent ?? []);
    _selectedParticipantIds = List.from(_existingTask?.participant ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  bool _isValid() {
    return _nameController.text.trim().isNotEmpty;
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();

    if (_existingTask == null) {
      await widget.viewModel.addTask(
        name,
        description: description.isEmpty ? null : description,
        agent: _selectedAgentIds,
        participant: _selectedParticipantIds,
      );
    } else {
      await widget.viewModel.editTask(
        _existingTask!,
        name,
        newDescription: description.isEmpty ? null : description,
        newAgent: _selectedAgentIds,
        newParticipant: _selectedParticipantIds,
      );
    }

    if (mounted) {
      context.pop();
    }
  }

  Future<void> _selectAssignees() async {
    await MultiTypeResourceSelectionModal.show(
      context: context,
      title: 'Select Assignees',
      initialSelectedIds: _selectedAgentIds,
      tabs: [
        ResourceTab(
          label: 'People',
          fetchItems: () async {
            // Read from the unified graph!
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
            // Read from the unified graph!
            final organizations = widget.graphViewModel
                .getItems<Organization>();
            return Map.fromEntries(
              organizations.map((o) => MapEntry(o.id, o.name)),
            );
          },
        ),
      ],
      onSelectionSaved: (selectedIds) {
        setState(() {
          _selectedAgentIds = selectedIds;
        });
      },
    );
  }

  Future<void> _selectParticipants() async {
    await MultiTypeResourceSelectionModal.show(
      context: context,
      title: 'Select Participants',
      initialSelectedIds: _selectedParticipantIds,
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
            final organizations = widget.graphViewModel
                .getItems<Organization>();
            return Map.fromEntries(
              organizations.map((o) => MapEntry(o.id, o.name)),
            );
          },
        ),
      ],
      onSelectionSaved: (selectedIds) {
        setState(() {
          _selectedParticipantIds = selectedIds;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_existingTask == null ? 'Add Task' : 'Edit Task'),
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
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Task Name *',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
              autofocus: _existingTask == null,
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
            const SizedBox(height: 24),
            Text('Assignees', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('${_selectedAgentIds.length} assignees selected'),
              trailing: FilledButton.tonal(
                onPressed: _selectAssignees,
                child: const Text('Edit Assignees'),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Participants',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                '${_selectedParticipantIds.length} participants selected',
              ),
              trailing: FilledButton.tonal(
                onPressed: _selectParticipants,
                child: const Text('Edit Participants'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
