import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:data_layer/data_layer.dart';
import 'package:knowledge_graph/domain/models/person.dart';
import 'package:knowledge_graph/domain/models/thing.dart';
import 'package:knowledge_graph/domain/use_cases/person_use_cases.dart';
import 'package:knowledge_graph/ui/shared/view_models/graph_view_model.dart';

class PeopleViewModel extends ChangeNotifier {
  static final _log = Logger('PeopleViewModel');

  final Repository<Thing> _repository;
  final CreatePersonUseCase _createPersonUseCase;
  final EditPersonUseCase _editPersonUseCase;
  final DeletePersonUseCase _deletePersonUseCase;
  final GraphViewModel _graphViewModel;

  PeopleViewModel({
    required Repository<Thing> repository,
    required CreatePersonUseCase createPersonUseCase,
    required EditPersonUseCase editPersonUseCase,
    required DeletePersonUseCase deletePersonUseCase,
    required GraphViewModel graphViewModel,
  }) : _repository = repository,
       _createPersonUseCase = createPersonUseCase,
       _editPersonUseCase = editPersonUseCase,
       _deletePersonUseCase = deletePersonUseCase,
       _graphViewModel = graphViewModel;

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
      final items = await _repository.getItems(
        details: RequestDetails.read(requestType: RequestType.allLocal),
      );
      _people = items.whereType<Person>().toList();
      _graphViewModel.merge(_people);
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
    List<String>? colleague,
  }) async {
    _log.info('Adding new person');
    await _createPersonUseCase.execute(
      givenName: givenName,
      familyName: familyName,
      jobTitle: jobTitle,
      birthDate: birthDate,
      worksFor: worksFor,
      colleague: colleague,
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
    List<String>? colleague,
  }) async {
    _log.info('Editing person: ${person.id}');
    await _editPersonUseCase.execute(
      person,
      givenName: givenName,
      familyName: familyName,
      jobTitle: jobTitle,
      birthDate: birthDate,
      worksFor: worksFor,
      colleague: colleague,
    );
    await initialize();
  }

  Future<void> deletePerson(Person person) async {
    _log.info('Deleting person: ${person.id}');
    await _deletePersonUseCase.execute(person);
    await initialize();
  }
}
