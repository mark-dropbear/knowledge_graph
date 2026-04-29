import 'package:data_layer/data_layer.dart';
import 'package:knowledge_graph/domain/models/task.dart';

class TaskRepository extends Repository<Task> {
  TaskRepository()
      : super(
          SourceList<Task>(
            bindings: Task.bindings,
            sources: [
              LocalMemorySource<Task>(bindings: Task.bindings),
            ],
          ),
        );
}
