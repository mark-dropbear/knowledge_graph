import 'package:flutter/foundation.dart';
import 'package:data_layer/data_layer.dart';
import 'package:knowledge_graph/domain/models/thing.dart';
import 'package:knowledge_graph/domain/use_cases/export_dataset_use_case.dart';
import 'package:knowledge_graph/domain/use_cases/import_dataset_use_case.dart';
import 'package:knowledge_graph/ui/shared/view_models/graph_view_model.dart';

class HomeViewModel extends ChangeNotifier {
  final ExportDatasetUseCase _exportDatasetUseCase;
  final ImportDatasetUseCase _importDatasetUseCase;
  final GraphViewModel _graphViewModel;
  final Repository<Thing> _repository;

  HomeViewModel({
    required ExportDatasetUseCase exportDatasetUseCase,
    required ImportDatasetUseCase importDatasetUseCase,
    required GraphViewModel graphViewModel,
    required Repository<Thing> repository,
  })  : _exportDatasetUseCase = exportDatasetUseCase,
        _importDatasetUseCase = importDatasetUseCase,
        _graphViewModel = graphViewModel,
        _repository = repository;

  Future<String> exportJsonLd() async {
    return await _exportDatasetUseCase.execute();
  }

  Future<void> importJsonLd(String jsonLd) async {
    await _importDatasetUseCase.execute(jsonLd);
    
    final allItems = await _repository.getItems(
      details: RequestDetails.read(requestType: RequestType.allLocal),
    );
    _graphViewModel.merge(allItems);

    notifyListeners();
  }
}
