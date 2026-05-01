import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge_graph/domain/models/thing_instance.dart';
import 'package:knowledge_graph/ui/features/things/view_models/things_view_model.dart';

class ThingFormView extends StatefulWidget {
  final ThingsViewModel viewModel;
  final String? thingId;

  const ThingFormView({super.key, required this.viewModel, this.thingId});

  @override
  State<ThingFormView> createState() => _ThingFormViewState();
}

class _ThingFormViewState extends State<ThingFormView> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _urlController;
  ThingInstance? _existingThing;

  @override
  void initState() {
    super.initState();
    if (widget.thingId != null) {
      try {
        _existingThing = widget.viewModel.things.firstWhere(
          (t) => t.id == widget.thingId,
        );
      } catch (e) {
        _existingThing = null;
      }
    }

    _nameController = TextEditingController(text: _existingThing?.name);
    _descriptionController = TextEditingController(
      text: _existingThing?.description,
    );
    _urlController = TextEditingController(text: _existingThing?.url);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  bool _isValid() {
    return _nameController.text.trim().isNotEmpty;
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final url = _urlController.text.trim();

    if (_existingThing == null) {
      await widget.viewModel.addThing(
        name: name,
        description: description.isEmpty ? null : description,
        url: url.isEmpty ? null : url,
      );
    } else {
      await widget.viewModel.editThing(
        _existingThing!,
        name: name,
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
        title: Text(_existingThing == null ? 'Add Thing' : 'Edit Thing'),
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
                labelText: 'Name *',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
              autofocus: _existingThing == null,
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
