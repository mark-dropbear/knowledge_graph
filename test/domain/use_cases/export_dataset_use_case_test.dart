import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:knowledge_graph/domain/models/task.dart';
import 'package:knowledge_graph/domain/models/list_item.dart';
import 'package:knowledge_graph/domain/models/task_list.dart';
import 'package:knowledge_graph/domain/models/person.dart';
import 'package:knowledge_graph/data/repositories/task_repository.dart';
import 'package:knowledge_graph/data/repositories/task_list_repository.dart';
import 'package:knowledge_graph/data/repositories/person_repository.dart';
import 'package:knowledge_graph/domain/use_cases/export_dataset_use_case.dart';

@GenerateNiceMocks([
  MockSpec<TaskRepository>(),
  MockSpec<TaskListRepository>(),
  MockSpec<PersonRepository>(),
])
import 'export_dataset_use_case_test.mocks.dart';

void main() {
  group('ExportDatasetUseCase', () {
    late MockTaskRepository mockTaskRepo;
    late MockTaskListRepository mockTaskListRepo;
    late MockPersonRepository mockPersonRepo;
    late ExportDatasetUseCase useCase;

    setUp(() {
      mockTaskRepo = MockTaskRepository();
      mockTaskListRepo = MockTaskListRepository();
      mockPersonRepo = MockPersonRepository();
      useCase = ExportDatasetUseCase(
        mockTaskListRepo,
        mockTaskRepo,
        mockPersonRepo,
      );
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

      final person = Person(
        id: 'urn:uuid:p1',
        givenName: 'John',
        familyName: 'Doe',
      );

      when(
        mockTaskListRepo.getItems(details: anyNamed('details')),
      ).thenAnswer((_) async => [taskList]);
      when(
        mockTaskRepo.getByIds(any),
      ).thenAnswer((_) async => ([task1, task2], <String>{}));
      when(
        mockPersonRepo.getItems(details: anyNamed('details')),
      ).thenAnswer((_) async => [person]);

      final jsonString = await useCase.execute();
      final dataset = jsonDecode(jsonString) as Map<String, dynamic>;

      expect(dataset['@context'], 'https://schema.org');
      expect(dataset['@graph'], isA<List>());

      final graph = dataset['@graph'] as List;
      expect(graph.length, 4); // 1 list + 2 tasks + 1 person

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

      final personNode = graph.firstWhere((n) => n['@id'] == 'urn:uuid:p1');
      expect(personNode['@type'], 'Person');
      expect(personNode['givenName'], 'John');
      expect(personNode.containsKey('@context'), isFalse);
    });
  });
}
