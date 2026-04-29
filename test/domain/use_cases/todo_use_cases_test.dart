import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:knowledge_graph/domain/models/task.dart';
import 'package:knowledge_graph/domain/models/task_list.dart';
import 'package:knowledge_graph/domain/models/list_item.dart';
import 'package:knowledge_graph/data/repositories/task_repository.dart';
import 'package:knowledge_graph/data/repositories/task_list_repository.dart';
import 'package:knowledge_graph/domain/use_cases/todo_use_cases.dart';

@GenerateNiceMocks([MockSpec<TaskRepository>(), MockSpec<TaskListRepository>()])
import 'todo_use_cases_test.mocks.dart';

void main() {
  group('TodoUseCases', () {
    late MockTaskRepository mockTaskRepo;
    late MockTaskListRepository mockTaskListRepo;

    setUp(() {
      mockTaskRepo = MockTaskRepository();
      mockTaskListRepo = MockTaskListRepository();
    });

    test('CreateTaskUseCase generates task and updates list', () async {
      final useCase = CreateTaskUseCase(mockTaskRepo, mockTaskListRepo);
      final initialList = TaskList(id: 'list-1', name: 'My List');

      // Mock setItem to return the exact task it was given
      when(mockTaskRepo.setItem(any)).thenAnswer((invocation) async {
        return invocation.positionalArguments[0] as Task;
      });

      await useCase.execute(initialList, 'New Task');

      // Verify task was saved
      verify(mockTaskRepo.setItem(any)).called(1);

      // Verify list was updated
      final listCapture = verify(mockTaskListRepo.setItem(captureAny)).captured;
      final updatedList = listCapture.first as TaskList;

      expect(updatedList.itemListElement.length, 1);
      expect(
        updatedList.itemListElement.first.item.startsWith('urn:uuid:'),
        isTrue,
      );
      expect(updatedList.numberOfItems, 1);
    });

    test('DeleteTaskUseCase removes task and updates list positions', () async {
      final useCase = DeleteTaskUseCase(mockTaskRepo, mockTaskListRepo);
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
      verify(mockTaskRepo.delete('task-to-delete')).called(1);

      // Verify list was updated
      final listCapture = verify(mockTaskListRepo.setItem(captureAny)).captured;
      final updatedList = listCapture.first as TaskList;

      expect(updatedList.itemListElement.length, 2);
      expect(updatedList.itemListElement[0].item, 'task-1');
      expect(updatedList.itemListElement[0].position, 1);
      expect(updatedList.itemListElement[1].item, 'task-3');
      expect(updatedList.itemListElement[1].position, 2);
    });

    test('HydrateTaskListUseCase resolves tasks in correct order', () async {
      final useCase = HydrateTaskListUseCase(mockTaskRepo);
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
        mockTaskRepo.getByIds(any),
      ).thenAnswer((_) async => ([task1, task2], <String>{}));

      final hydrated = await useCase.execute(list);

      expect(hydrated.length, 2);
      expect(hydrated[0].id, 'task-1'); // Correctly ordered by position
      expect(hydrated[1].id, 'task-2');
    });
  });
}
