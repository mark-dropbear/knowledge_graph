import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:knowledge_graph/domain/models/task.dart';
import 'package:knowledge_graph/domain/models/task_list.dart';
import 'package:knowledge_graph/domain/models/list_item.dart';
import 'package:knowledge_graph/data/repositories/graph_repository.dart';
import 'package:knowledge_graph/domain/use_cases/todo_use_cases.dart';

@GenerateNiceMocks([MockSpec<GraphRepository>()])
import 'todo_use_cases_test.mocks.dart';

void main() {
  group('TodoUseCases', () {
    late MockGraphRepository mockGraphRepo;

    setUp(() {
      mockGraphRepo = MockGraphRepository();
    });

    test('CreateTaskUseCase generates task and updates list', () async {
      final useCase = CreateTaskUseCase(mockGraphRepo);
      final initialList = TaskList(id: 'list-1', name: 'My List');

      // Mock setItem to simulate data layer ID generation
      when(mockGraphRepo.setItem(any)).thenAnswer((invocation) async {
        final item = invocation.positionalArguments[0];
        if (item is Task) {
          return item.id.isEmpty
              ? item.copyWith(id: 'urn:uuid:mock-1234')
              : item;
        }
        return item;
      });

      await useCase.execute(initialList, 'New Task');

      // Verify task and list were saved
      verify(mockGraphRepo.setItem(any)).called(2);
    });

    test('DeleteTaskUseCase removes task and updates list positions', () async {
      final useCase = DeleteTaskUseCase(mockGraphRepo);
      final initialList = TaskList(
        id: 'list-1',
        name: 'My List',
        numberOfItems: 3,
        itemListElement: [
          ListItem(position: 1, item: 'task-1'),
          ListItem(position: 2, item: 'task-to-delete'),
          ListItem(position: 3, item: 'task-3'),
        ],
      );

      await useCase.execute(initialList, 'task-to-delete');

      // Verify task was deleted
      verify(mockGraphRepo.delete('task-to-delete')).called(1);

      // Verify list was updated
      final listCapture = verify(mockGraphRepo.setItem(captureAny)).captured;
      final updatedList = listCapture.first as TaskList;

      expect(updatedList.itemListElement.length, 2);
      expect(updatedList.itemListElement[0].item, 'task-1');
      expect(updatedList.itemListElement[0].position, 1);
      expect(updatedList.itemListElement[1].item, 'task-3');
      expect(updatedList.itemListElement[1].position, 2);
    });

    test('HydrateTaskListUseCase resolves tasks in correct order', () async {
      final useCase = HydrateTaskListUseCase(mockGraphRepo);
      final list = TaskList(
        id: 'list-1',
        name: 'My List',
        itemListElement: [
          ListItem(position: 2, item: 'task-2'),
          ListItem(position: 1, item: 'task-1'),
        ],
      );

      final task1 = Task(
        id: 'task-1',
        name: 'Task 1',
        actionStatus: TaskStatus.potential,
      );
      final task2 = Task(
        id: 'task-2',
        name: 'Task 2',
        actionStatus: TaskStatus.potential,
      );

      when(
        mockGraphRepo.getByIds(any),
      ).thenAnswer((_) async => ([task1, task2], <String>{}));

      final hydrated = await useCase.execute(list);

      expect(hydrated.length, 2);
      expect(hydrated[0].id, 'task-1'); // Correctly ordered by position
      expect(hydrated[1].id, 'task-2');
    });

    test('EditTaskListUseCase updates name and description', () async {
      final useCase = EditTaskListUseCase(mockGraphRepo);
      final list = TaskList(id: 'list-1', name: 'Old Name');

      await useCase.execute(list, 'New Name', newDescription: 'New Desc');

      final listCapture = verify(mockGraphRepo.setItem(captureAny)).captured;
      final updatedList = listCapture.first as TaskList;

      expect(updatedList.name, 'New Name');
      expect(updatedList.description, 'New Desc');
      expect(updatedList.id, 'list-1');
    });

    test('EditTaskUseCase updates name and description', () async {
      final useCase = EditTaskUseCase(mockGraphRepo);
      final task = Task(
        id: 'task-1',
        name: 'Old Name',
        actionStatus: TaskStatus.potential,
      );

      await useCase.execute(task, 'New Name', newDescription: 'New Desc');

      final taskCapture = verify(mockGraphRepo.setItem(captureAny)).captured;
      final updatedTask = taskCapture.first as Task;

      expect(updatedTask.name, 'New Name');
      expect(updatedTask.description, 'New Desc');
      expect(updatedTask.id, 'task-1');
    });
  });
}
