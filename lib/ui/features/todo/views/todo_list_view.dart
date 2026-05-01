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
                            decoration: isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: task.description != null
                            ? Text(task.description!)
                            : null,
                        onTap: () => context.push(
                          '/lists/${Uri.encodeComponent(widget.listId)}/tasks/${Uri.encodeComponent(task.id)}',
                        ),
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push(
              '/lists/${Uri.encodeComponent(widget.listId)}/tasks/create',
            ),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
