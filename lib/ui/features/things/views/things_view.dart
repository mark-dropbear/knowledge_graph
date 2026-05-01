import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge_graph/ui/features/things/view_models/things_view_model.dart';

class ThingsView extends StatefulWidget {
  final ThingsViewModel viewModel;

  const ThingsView({super.key, required this.viewModel});

  @override
  State<ThingsView> createState() => _ThingsViewState();
}

class _ThingsViewState extends State<ThingsView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Things')),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          if (widget.viewModel.isLoading && widget.viewModel.things.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (widget.viewModel.things.isEmpty) {
            return const Center(child: Text('No things found. Add one!'));
          }

          return ListView.builder(
            itemCount: widget.viewModel.things.length,
            itemBuilder: (context, index) {
              final thing = widget.viewModel.things[index];
              return ListTile(
                title: Text(thing.name),
                subtitle: thing.description != null
                    ? Text(thing.description!)
                    : null,
                onTap: () {
                  context.push('/things/${Uri.encodeComponent(thing.id)}');
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/things/add'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
