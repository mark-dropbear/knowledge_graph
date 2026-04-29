import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:knowledge_graph/domain/models/task.dart';
import 'package:knowledge_graph/ui/features/todo/view_models/todo_list_view_model.dart';

class TodoListView extends StatefulWidget {
  final TodoListViewModel viewModel;

  const TodoListView({super.key, required this.viewModel});

  @override
  State<TodoListView> createState() => _TodoListViewState();
}

class _TodoListViewState extends State<TodoListView> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.viewModel.currentList?.name ?? 'Loading...'),
            actions: [
              if (widget.viewModel.currentList != null)
                IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: 'Export JSON-LD',
                  onPressed: () {
                    final jsonString = widget.viewModel.exportJsonLd();
                    Clipboard.setData(ClipboardData(text: jsonString));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('JSON-LD copied to clipboard')),
                    );
                  },
                ),
            ],
          ),
          body: widget.viewModel.isLoading && widget.viewModel.tasks.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              decoration: const InputDecoration(
                                hintText: 'Add a new task...',
                                border: OutlineInputBorder(),
                              ),
                              onSubmitted: (value) {
                                widget.viewModel.addTask(value);
                                _controller.clear();
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              widget.viewModel.addTask(_controller.text);
                              _controller.clear();
                            },
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: widget.viewModel.tasks.length,
                        itemBuilder: (context, index) {
                          final task = widget.viewModel.tasks[index];
                          final isCompleted = task.actionStatus == TaskStatus.completed;

                          return Dismissible(
                            key: Key(task.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) {
                              widget.viewModel.deleteTask(task);
                            },
                            child: ListTile(
                              leading: Checkbox(
                                value: isCompleted,
                                onChanged: (_) => widget.viewModel.toggleTask(task),
                              ),
                              title: Text(
                                task.name,
                                style: TextStyle(
                                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
