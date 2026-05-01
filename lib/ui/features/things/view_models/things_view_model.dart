import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:data_layer/data_layer.dart';
import 'package:knowledge_graph/domain/models/thing_instance.dart';
import 'package:knowledge_graph/domain/models/thing.dart';
import 'package:knowledge_graph/domain/use_cases/thing_instance_use_cases.dart';
import 'package:knowledge_graph/ui/shared/view_models/graph_view_model.dart';

class ThingsViewModel extends ChangeNotifier {
  static final _log = Logger('ThingsViewModel');

  final Repository<Thing> _repository;
  final CreateThingInstanceUseCase _createThingInstanceUseCase;
  final EditThingInstanceUseCase _editThingInstanceUseCase;
  final DeleteThingInstanceUseCase _deleteThingInstanceUseCase;
  final GraphViewModel _graphViewModel;

  ThingsViewModel({
    required Repository<Thing> repository,
    required CreateThingInstanceUseCase createThingInstanceUseCase,
    required EditThingInstanceUseCase editThingInstanceUseCase,
    required DeleteThingInstanceUseCase deleteThingInstanceUseCase,
    required GraphViewModel graphViewModel,
  }) : _repository = repository,
       _createThingInstanceUseCase = createThingInstanceUseCase,
       _editThingInstanceUseCase = editThingInstanceUseCase,
       _deleteThingInstanceUseCase = deleteThingInstanceUseCase,
       _graphViewModel = graphViewModel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<ThingInstance> _things = [];
  List<ThingInstance> get things => _things;

  Future<void> initialize() async {
    _log.info('Initializing ThingsViewModel');
    Future.microtask(() {
      _isLoading = true;
      notifyListeners();
    });

    try {
      final items = await _repository.getItems(
        details: RequestDetails.read(requestType: RequestType.allLocal),
      );
      _things = items.whereType<ThingInstance>().toList();
      _graphViewModel.merge(_things);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addThing({
    required String name,
    String? description,
    String? url,
  }) async {
    _log.info('Adding new thing instance');
    await _createThingInstanceUseCase.execute(
      name: name,
      description: description,
      url: url,
    );
    await initialize();
  }

  Future<void> editThing(
    ThingInstance thing, {
    String? name,
    String? description,
    String? url,
  }) async {
    _log.info('Editing thing instance: ${thing.id}');
    await _editThingInstanceUseCase.execute(
      thing,
      name: name,
      description: description,
      url: url,
    );
    await initialize();
  }

  Future<void> deleteThing(ThingInstance thing) async {
    _log.info('Deleting thing instance: ${thing.id}');
    await _deleteThingInstanceUseCase.execute(thing);
    await initialize();
  }
}
