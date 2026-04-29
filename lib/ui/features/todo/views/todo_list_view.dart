import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge_graph/domain/models/task.dart';
import 'package:knowledge_graph/ui/features/todo/view_models/todo_list_view_model.dart';

class TodoListView extends StatefulWidget {
  final TodoListViewModel viewModel;
  final String listId;

  const TodoListView({
    super.key, 
    required this.viewModel,
    required this.listId,
  });

  @override
  State<TodoListView> createState() => _TodoListViewState();
}

class _TodoListViewState extends State<TodoListView> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.initialize(widget.listId);
  }

  @override
  void didUpdateWidget(TodoListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listId != widget.listId) {
      widget.viewModel.initialize(widget.listId);
    }
  }

  void _showAddTaskModal(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Create New Task', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Task Name',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  if (name.isNotEmpty) {
                    widget.viewModel.addTask(
                      name,
                      description: descriptionController.text.trim().isEmpty 
                          ? null 
                          : descriptionController.text.trim(),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add Task'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showEditTaskModal(BuildContext context, Task task) {
    final nameController = TextEditingController(text: task.name);
    final descriptionController = TextEditingController(text: task.description);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Edit Task', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Task Name',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () {
                      widget.viewModel.deleteTask(task);
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final name = nameController.text.trim();
                      if (name.isNotEmpty) {
                        widget.viewModel.editTask(
                          task,
                          name,
                          newDescription: descriptionController.text.trim().isEmpty 
                              ? null 
                              : descriptionController.text.trim(),
                        );
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
            ),
            title: Text(widget.viewModel.currentList?.name ?? 'Loading...'),
          ),
          body: widget.viewModel.isLoading && widget.viewModel.tasks.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: widget.viewModel.tasks.length,
                  itemBuilder: (context, index) {
                    final task = widget.viewModel.tasks[index];
                    final isCompleted =
                        task.actionStatus == TaskStatus.completed;

                    return Dismissible(
                      key: Key(task.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
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
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: task.description != null ? Text(task.description!) : null,
                        onTap: () => _showEditTaskModal(context, task),
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _showAddTaskModal(context),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
