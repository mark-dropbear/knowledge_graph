import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_graph/data/repositories/task_repository.dart';
import 'package:knowledge_graph/data/repositories/task_list_repository.dart';
import 'package:knowledge_graph/domain/models/task.dart';
import 'package:knowledge_graph/domain/models/task_list.dart';
import 'package:knowledge_graph/domain/models/list_item.dart';

void main() {
  group('Repositories', () {
    test('TaskRepository saves and retrieves a task', () async {
      final repository = TaskRepository();

      final task = Task(
        id: 'urn:uuid:test-task',
        name: 'Do dishes',
        actionStatus: 'https://schema.org/PotentialActionStatus',
      );

      final savedTask = await repository.setItem(task);
      expect(savedTask!.id, 'urn:uuid:test-task');

      final retrievedTask = await repository.getById('urn:uuid:test-task');
      expect(retrievedTask, isNotNull);
      expect(retrievedTask!.name, 'Do dishes');
    });

    test('TaskListRepository saves and retrieves a task list', () async {
      final repository = TaskListRepository();

      final taskList = TaskList(
        id: 'urn:uuid:test-list',
        name: 'My Tasks',
        numberOfItems: 1,
        itemListElement: [
          ListItem(position: 1, item: 'urn:uuid:test-task')
        ],
      );

      await repository.setItem(taskList);

      final retrievedList = await repository.getById('urn:uuid:test-list');
      expect(retrievedList, isNotNull);
      expect(retrievedList!.name, 'My Tasks');
      expect(retrievedList.itemListElement.length, 1);
      expect(retrievedList.itemListElement[0].item, 'urn:uuid:test-task');
    });
  });
}
