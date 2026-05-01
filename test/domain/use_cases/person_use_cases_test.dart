import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:knowledge_graph/domain/models/person.dart';
import 'package:knowledge_graph/data/repositories/graph_repository.dart';
import 'package:knowledge_graph/domain/use_cases/person_use_cases.dart';

@GenerateNiceMocks([MockSpec<GraphRepository>()])
import 'person_use_cases_test.mocks.dart';

void main() {
  group('Person Use Cases', () {
    late MockGraphRepository mockGraphRepo;

    setUp(() {
      mockGraphRepo = MockGraphRepository();
    });

    test('CreatePersonUseCase saves new person', () async {
      final useCase = CreatePersonUseCase(mockGraphRepo);

      await useCase.execute(
        givenName: 'John',
        familyName: 'Doe',
        jobTitle: 'Developer',
      );

      final capture = verify(mockGraphRepo.setItem(captureAny)).captured;
      final savedPerson = capture.first as Person;

      expect(savedPerson.givenName, 'John');
      expect(savedPerson.familyName, 'Doe');
      expect(savedPerson.jobTitle, 'Developer');
      expect(savedPerson.birthDate, isNull);
    });

    test('EditPersonUseCase updates person fields', () async {
      final useCase = EditPersonUseCase(mockGraphRepo);
      final initialPerson = Person(
        id: 'urn:uuid:123',
        givenName: 'John',
        familyName: 'Doe',
      );

      await useCase.execute(
        initialPerson,
        givenName: 'Jane',
        familyName: 'Doe',
      );

      final capture = verify(mockGraphRepo.setItem(captureAny)).captured;
      final updatedPerson = capture.first as Person;

      expect(updatedPerson.givenName, 'Jane');
      expect(updatedPerson.familyName, 'Doe');
    });

    test('DeletePersonUseCase deletes person', () async {
      final useCase = DeletePersonUseCase(mockGraphRepo);
      final person = Person(id: 'urn:uuid:123', givenName: 'John');

      await useCase.execute(person);

      verify(mockGraphRepo.delete('urn:uuid:123')).called(1);
    });
  });
}
