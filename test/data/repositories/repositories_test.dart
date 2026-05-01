import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_graph/data/repositories/graph_repository.dart';
import 'package:knowledge_graph/domain/models/task.dart';
import 'package:knowledge_graph/domain/models/task_list.dart';
import 'package:knowledge_graph/domain/models/list_item.dart';

void main() {
  group('Repositories', () {
    test('GraphRepository saves and retrieves a task', () async {
      final repository = GraphRepository();

      final task = Task(
        id: 'urn:uuid:test-task',
        name: 'Do dishes',
        actionStatus: TaskStatus.potential,
      );

      final savedTask = await repository.setItem(task);
      expect(savedTask?.id, 'urn:uuid:test-task');

      final retrievedTask = await repository.getById('urn:uuid:test-task');
      expect(retrievedTask, isNotNull);
      expect((retrievedTask as Task).name, 'Do dishes');
    });

    test('GraphRepository saves and retrieves a task list', () async {
      final repository = GraphRepository();

      final taskList = TaskList(
        id: 'urn:uuid:test-list',
        name: 'My Tasks',
        numberOfItems: 1,
        itemListElement: [ListItem(position: 1, item: 'urn:uuid:test-task')],
      );

      await repository.setItem(taskList);

      final retrievedList = await repository.getById('urn:uuid:test-list');
      expect(retrievedList, isNotNull);
      expect((retrievedList as TaskList).name, 'My Tasks');
      expect(retrievedList.itemListElement.length, 1);
      expect(retrievedList.itemListElement[0].item, 'urn:uuid:test-task');
    });
  });
}
