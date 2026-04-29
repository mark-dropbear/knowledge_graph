import 'package:flutter_test/flutter_test.dart';
import 'package:knowledge_graph/domain/models/task.dart';
import 'package:knowledge_graph/domain/models/list_item.dart';
import 'package:knowledge_graph/domain/models/task_list.dart';

void main() {
  group('JSON-LD Serialization', () {
    test('Task (Action) serialization', () {
      final task = Task(
        id: 'urn:uuid:test-task',
        name: 'Do dishes',
        description: 'Clean the kitchen',
        actionStatus: TaskStatus.potential,
        endTime: '2026-04-18T11:12:42Z',
      );

      final json = task.toJson();

      expect(json['@type'], 'Action');
      expect(json['@id'], 'urn:uuid:test-task');
      expect(json['name'], 'Do dishes');
      expect(json['description'], 'Clean the kitchen');
      expect(json['actionStatus'], 'https://schema.org/PotentialActionStatus');
      expect(json['endTime'], '2026-04-18T11:12:42Z');

      final deserialized = Task.fromJson(json);
      expect(deserialized.id, task.id);
      expect(deserialized.name, task.name);
      expect(deserialized.description, task.description);
      expect(deserialized.actionStatus, task.actionStatus);
      expect(deserialized.endTime, task.endTime);
    });

    test('ListItem serialization with reference', () {
      final listItem = ListItem(position: 1, item: 'urn:uuid:test-task');

      final json = listItem.toJson();
      expect(json['@type'], 'ListItem');
      expect(json['position'], 1);
      expect((json['item'] as Map)['@id'], 'urn:uuid:test-task');

      final deserialized = ListItem.fromJson(json);
      expect(deserialized.position, listItem.position);
      expect(deserialized.item, listItem.item);
    });

    test('ListItem deserialization supports inline item (legacy/external)', () {
      final json = {
        '@type': 'ListItem',
        'position': 2,
        'item': {
          '@type': 'Action',
          '@id': 'urn:uuid:inline-task',
          'name': 'Inline task',
        },
      };

      final deserialized = ListItem.fromJson(json);
      expect(deserialized.position, 2);
      expect(deserialized.item, 'urn:uuid:inline-task');
    });

    test('TaskList (ItemList) serialization', () {
      final taskList = TaskList(
        id: 'urn:uuid:test-list',
        name: 'My Tasks',
        numberOfItems: 1,
        itemListElement: [ListItem(position: 1, item: 'urn:uuid:task-1')],
      );

      final json = taskList.toJson();
      expect(json['@type'], 'ItemList');
      expect(json['@id'], 'urn:uuid:test-list');
      expect(json['name'], 'My Tasks');
      expect(json['numberOfItems'], 1);
      expect((json['itemListElement'] as List).length, 1);
      expect(json['itemListElement'][0]['position'], 1);

      final deserialized = TaskList.fromJson(json);
      expect(deserialized.id, taskList.id);
      expect(deserialized.name, taskList.name);
      expect(deserialized.numberOfItems, taskList.numberOfItems);
      expect(deserialized.itemListElement.length, 1);
      expect(deserialized.itemListElement[0].item, 'urn:uuid:task-1');
    });
  });
}
