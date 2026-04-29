import 'package:data_layer/data_layer.dart';
import 'package:knowledge_graph/domain/models/task_list.dart';

class TaskListRepository extends Repository<TaskList> {
  TaskListRepository()
    : super(
        SourceList<TaskList>(
          bindings: TaskList.bindings,
          sources: [LocalMemorySource<TaskList>(bindings: TaskList.bindings)],
        ),
      );
}
