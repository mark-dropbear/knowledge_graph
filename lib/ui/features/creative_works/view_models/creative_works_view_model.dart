import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:data_layer/data_layer.dart';
import 'package:knowledge_graph/domain/models/creative_work.dart';
import 'package:knowledge_graph/domain/models/thing.dart';
import 'package:knowledge_graph/domain/use_cases/creative_work_use_cases.dart';
import 'package:knowledge_graph/ui/shared/view_models/graph_view_model.dart';

class CreativeWorksViewModel extends ChangeNotifier {
  static final _log = Logger('CreativeWorksViewModel');

  final Repository<Thing> _repository;
  final CreateCreativeWorkUseCase _createCreativeWorkUseCase;
  final EditCreativeWorkUseCase _editCreativeWorkUseCase;
  final DeleteCreativeWorkUseCase _deleteCreativeWorkUseCase;
  final GraphViewModel _graphViewModel;

  CreativeWorksViewModel({
    required Repository<Thing> repository,
    required CreateCreativeWorkUseCase createCreativeWorkUseCase,
    required EditCreativeWorkUseCase editCreativeWorkUseCase,
    required DeleteCreativeWorkUseCase deleteCreativeWorkUseCase,
    required GraphViewModel graphViewModel,
  }) : _repository = repository,
       _createCreativeWorkUseCase = createCreativeWorkUseCase,
       _editCreativeWorkUseCase = editCreativeWorkUseCase,
       _deleteCreativeWorkUseCase = deleteCreativeWorkUseCase,
       _graphViewModel = graphViewModel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<CreativeWork> _creativeWorks = [];
  List<CreativeWork> get creativeWorks => _creativeWorks;

  Future<void> initialize() async {
    _log.info('Initializing CreativeWorksViewModel');
    Future.microtask(() {
      _isLoading = true;
      notifyListeners();
    });

    try {
      final items = await _repository.getItems(
        details: RequestDetails.read(requestType: RequestType.allLocal),
      );
      _creativeWorks = items.whereType<CreativeWork>().toList();
      _graphViewModel.merge(_creativeWorks);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCreativeWork({
    required String name,
    CreativeWorkType workType = CreativeWorkType.creativeWork,
    String? description,
    String? url,
    List<String>? author,
  }) async {
    _log.info('Adding new creative work');
    await _createCreativeWorkUseCase.execute(
      name: name,
      workType: workType,
      description: description,
      url: url,
      author: author,
    );
    await initialize();
  }

  Future<void> editCreativeWork(
    CreativeWork creativeWork, {
    String? name,
    CreativeWorkType? workType,
    String? description,
    String? url,
    List<String>? author,
  }) async {
    _log.info('Editing creative work: ${creativeWork.id}');
    await _editCreativeWorkUseCase.execute(
      creativeWork,
      name: name,
      workType: workType,
      description: description,
      url: url,
      author: author,
    );
    await initialize();
  }

  Future<void> deleteCreativeWork(CreativeWork creativeWork) async {
    _log.info('Deleting creative work: ${creativeWork.id}');
    await _deleteCreativeWorkUseCase.execute(creativeWork);
    await initialize();
  }
}
