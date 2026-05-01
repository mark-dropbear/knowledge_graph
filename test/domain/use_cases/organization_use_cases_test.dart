import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:knowledge_graph/domain/models/organization.dart';
import 'package:knowledge_graph/data/repositories/graph_repository.dart';
import 'package:knowledge_graph/domain/use_cases/organization_use_cases.dart';

@GenerateNiceMocks([MockSpec<GraphRepository>()])
import 'organization_use_cases_test.mocks.dart';

void main() {
  group('Organization Use Cases', () {
    late MockGraphRepository mockGraphRepo;

    setUp(() {
      mockGraphRepo = MockGraphRepository();
    });

    test('CreateOrganizationUseCase saves new organization', () async {
      final useCase = CreateOrganizationUseCase(mockGraphRepo);

      await useCase.execute(
        name: 'Google',
        orgType: OrganizationType.corporation,
        url: 'https://google.com',
      );

      final capture = verify(mockGraphRepo.setItem(captureAny)).captured;
      final savedOrganization = capture.first as Organization;

      expect(savedOrganization.name, 'Google');
      expect(savedOrganization.orgType, OrganizationType.corporation);
      expect(savedOrganization.url, 'https://google.com');
      expect(savedOrganization.description, isNull);
    });

    test('EditOrganizationUseCase updates organization fields', () async {
      final useCase = EditOrganizationUseCase(mockGraphRepo);
      final initialOrganization = Organization(
        id: 'urn:uuid:123',
        name: 'OpenAI',
        orgType: OrganizationType.ngo,
      );

      await useCase.execute(
        initialOrganization,
        name: 'OpenAI LP',
        orgType: OrganizationType.corporation,
      );

      final capture = verify(mockGraphRepo.setItem(captureAny)).captured;
      final updatedOrganization = capture.first as Organization;

      expect(updatedOrganization.name, 'OpenAI LP');
      expect(updatedOrganization.orgType, OrganizationType.corporation);
    });

    test('DeleteOrganizationUseCase deletes organization', () async {
      final useCase = DeleteOrganizationUseCase(mockGraphRepo);
      final organization = Organization(id: 'urn:uuid:123', name: 'Alphabet');

      await useCase.execute(organization);

      verify(mockGraphRepo.delete('urn:uuid:123')).called(1);
    });
  });
}
