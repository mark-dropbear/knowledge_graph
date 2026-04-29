import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:knowledge_graph/domain/models/task.dart';
import 'package:knowledge_graph/domain/models/list_item.dart';
import 'package:knowledge_graph/domain/models/task_list.dart';
import 'package:knowledge_graph/domain/use_cases/export_dataset_use_case.dart';

import 'todo_use_cases_test.mocks.dart'; // Reusing the same mocks

void main() {
  group('ExportDatasetUseCase', () {
    late MockTaskRepository mockTaskRepo;
    late MockTaskListRepository mockTaskListRepo;
    late ExportDatasetUseCase useCase;

    setUp(() {
      mockTaskRepo = MockTaskRepository();
      mockTaskListRepo = MockTaskListRepository();
      useCase = ExportDatasetUseCase(mockTaskListRepo, mockTaskRepo);
    });

    test('exports canonical JSON-LD dataset with @graph', () async {
      final task1 = Task(
        id: 'urn:uuid:t1',
        name: 'Task 1',
        actionStatus: TaskStatus.completed,
      );
      final task2 = Task(
        id: 'urn:uuid:t2',
        name: 'Task 2',
        actionStatus: TaskStatus.potential,
      );

      final taskList = TaskList(
        id: 'urn:uuid:l1',
        name: 'List 1',
        numberOfItems: 2,
        itemListElement: [
          ListItem(position: 1, item: 'urn:uuid:t1'),
          ListItem(position: 2, item: 'urn:uuid:t2'),
        ],
      );

      when(
        mockTaskListRepo.getItems(details: anyNamed('details')),
      ).thenAnswer((_) async => [taskList]);
      when(
        mockTaskRepo.getByIds(any),
      ).thenAnswer((_) async => ([task1, task2], <String>{}));

      final jsonString = await useCase.execute();
      final dataset = jsonDecode(jsonString) as Map<String, dynamic>;

      expect(dataset['@context'], 'https://schema.org');
      expect(dataset['@graph'], isA<List>());

      final graph = dataset['@graph'] as List;
      expect(graph.length, 3); // 1 list + 2 tasks

      final listNode = graph.firstWhere((n) => n['@type'] == 'ItemList');
      expect(listNode['@id'], 'urn:uuid:l1');
      expect(listNode.containsKey('@context'), isFalse);

      final task1Node = graph.firstWhere((n) => n['@id'] == 'urn:uuid:t1');
      expect(task1Node['@type'], 'Action');
      expect(
        task1Node['actionStatus'],
        'https://schema.org/CompletedActionStatus',
      );
      expect(task1Node.containsKey('@context'), isFalse);

      final task2Node = graph.firstWhere((n) => n['@id'] == 'urn:uuid:t2');
      expect(task2Node['@type'], 'Action');
      expect(
        task2Node['actionStatus'],
        'https://schema.org/PotentialActionStatus',
      );
      expect(task2Node.containsKey('@context'), isFalse);
    });
  });
}
