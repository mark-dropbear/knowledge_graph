import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:knowledge_graph/domain/models/task.dart';
import 'package:knowledge_graph/domain/models/list_item.dart';
import 'package:knowledge_graph/domain/models/task_list.dart';
import 'package:knowledge_graph/domain/models/person.dart';
import 'package:knowledge_graph/domain/models/organization.dart';
import 'package:knowledge_graph/data/repositories/graph_repository.dart';
import 'package:knowledge_graph/domain/use_cases/export_dataset_use_case.dart';

@GenerateNiceMocks([MockSpec<GraphRepository>()])
import 'export_dataset_use_case_test.mocks.dart';

void main() {
  group('ExportDatasetUseCase', () {
    late MockGraphRepository mockGraphRepo;
    late ExportDatasetUseCase useCase;

    setUp(() {
      mockGraphRepo = MockGraphRepository();
      useCase = ExportDatasetUseCase(mockGraphRepo);
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

      final organization = Organization(
        id: 'urn:uuid:o1',
        name: 'Acme Corp',
        orgType: OrganizationType.corporation,
      );

      when(
        mockGraphRepo.getItems(details: anyNamed('details')),
      ).thenAnswer((_) async => [taskList, task1, task2, person, organization]);

      final jsonString = await useCase.execute();
      final dataset = jsonDecode(jsonString) as Map<String, dynamic>;

      expect(dataset['@context'], 'https://schema.org');
      expect(dataset['@graph'], isA<List>());

      final graph = dataset['@graph'] as List;
      expect(graph.length, 5); // 1 list + 2 tasks + 1 person + 1 org

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

      final orgNode = graph.firstWhere((n) => n['@id'] == 'urn:uuid:o1');
      expect(orgNode['@type'], 'Corporation');
      expect(orgNode['name'], 'Acme Corp');
      expect(orgNode.containsKey('@context'), isFalse);
    });
  });
}
