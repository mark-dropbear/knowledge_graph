import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:data_layer/data_layer.dart';
import 'package:knowledge_graph/domain/models/person.dart';
import 'package:knowledge_graph/data/repositories/person_repository.dart';
import 'package:knowledge_graph/domain/use_cases/person_use_cases.dart';

class PeopleViewModel extends ChangeNotifier {
  static final _log = Logger('PeopleViewModel');

  final PersonRepository _personRepository;
  final CreatePersonUseCase _createPersonUseCase;
  final EditPersonUseCase _editPersonUseCase;
  final DeletePersonUseCase _deletePersonUseCase;

  PeopleViewModel({
    required PersonRepository personRepository,
    required CreatePersonUseCase createPersonUseCase,
    required EditPersonUseCase editPersonUseCase,
    required DeletePersonUseCase deletePersonUseCase,
  }) : _personRepository = personRepository,
       _createPersonUseCase = createPersonUseCase,
       _editPersonUseCase = editPersonUseCase,
       _deletePersonUseCase = deletePersonUseCase;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Person> _people = [];
  List<Person> get people => _people;

  Future<void> initialize() async {
    _log.info('Initializing PeopleViewModel');
    Future.microtask(() {
      _isLoading = true;
      notifyListeners();
    });

    try {
      _people = await _personRepository.getItems(
        details: RequestDetails.read(requestType: RequestType.allLocal),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPerson({
    String? givenName,
    String? familyName,
    String? jobTitle,
    String? birthDate,
    List<String>? worksFor,
  }) async {
    _log.info('Adding new person');
    await _createPersonUseCase.execute(
      givenName: givenName,
      familyName: familyName,
      jobTitle: jobTitle,
      birthDate: birthDate,
      worksFor: worksFor,
    );
    await initialize();
  }

  Future<void> editPerson(
    Person person, {
    String? givenName,
    String? familyName,
    String? jobTitle,
    String? birthDate,
    List<String>? worksFor,
  }) async {
    _log.info('Editing person: ${person.id}');
    await _editPersonUseCase.execute(
      person,
      givenName: givenName,
      familyName: familyName,
      jobTitle: jobTitle,
      birthDate: birthDate,
      worksFor: worksFor,
    );
    await initialize();
  }

  Future<void> deletePerson(Person person) async {
    _log.info('Deleting person: ${person.id}');
    await _deletePersonUseCase.execute(person);
    await initialize();
  }
}
