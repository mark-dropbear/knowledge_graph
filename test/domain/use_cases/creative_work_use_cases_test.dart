import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:knowledge_graph/domain/models/creative_work.dart';
import 'package:knowledge_graph/data/repositories/graph_repository.dart';
import 'package:knowledge_graph/domain/use_cases/creative_work_use_cases.dart';

@GenerateNiceMocks([MockSpec<GraphRepository>()])
import 'creative_work_use_cases_test.mocks.dart';

void main() {
  group('CreativeWork Use Cases', () {
    late MockGraphRepository mockGraphRepo;

    setUp(() {
      mockGraphRepo = MockGraphRepository();
    });

    test('CreateCreativeWorkUseCase saves new creative work', () async {
      final useCase = CreateCreativeWorkUseCase(mockGraphRepo);

      await useCase.execute(
        name: 'The Matrix',
        workType: CreativeWorkType.creativeWork,
        url: 'https://thematrix.com',
      );

      final capture = verify(mockGraphRepo.setItem(captureAny)).captured;
      final savedCreativeWork = capture.first as CreativeWork;

      expect(savedCreativeWork.name, 'The Matrix');
      expect(savedCreativeWork.workType, CreativeWorkType.creativeWork);
      expect(savedCreativeWork.url, 'https://thematrix.com');
      expect(savedCreativeWork.description, isNull);
    });

    test('EditCreativeWorkUseCase updates creative work fields', () async {
      final useCase = EditCreativeWorkUseCase(mockGraphRepo);
      final initialCreativeWork = CreativeWork(
        id: 'urn:uuid:123',
        name: 'The Lord of the Rings',
        workType: CreativeWorkType.book,
      );

      await useCase.execute(
        initialCreativeWork,
        name: 'The Lord of the Rings: The Fellowship of the Ring',
        workType: CreativeWorkType.book,
      );

      final capture = verify(mockGraphRepo.setItem(captureAny)).captured;
      final updatedCreativeWork = capture.first as CreativeWork;

      expect(updatedCreativeWork.name, 'The Lord of the Rings: The Fellowship of the Ring');
      expect(updatedCreativeWork.workType, CreativeWorkType.book);
    });

    test('DeleteCreativeWorkUseCase deletes creative work', () async {
      final useCase = DeleteCreativeWorkUseCase(mockGraphRepo);
      final creativeWork = CreativeWork(id: 'urn:uuid:123', name: 'Inception');

      await useCase.execute(creativeWork);

      verify(mockGraphRepo.delete('urn:uuid:123')).called(1);
    });
  });
}
