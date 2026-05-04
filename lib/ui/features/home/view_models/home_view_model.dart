import 'package:flutter/foundation.dart';
import 'package:knowledge_graph/domain/use_cases/export_dataset_use_case.dart';
import 'package:knowledge_graph/domain/use_cases/import_dataset_use_case.dart';

class HomeViewModel extends ChangeNotifier {
  final ExportDatasetUseCase _exportDatasetUseCase;
  final ImportDatasetUseCase _importDatasetUseCase;

  HomeViewModel({
    required ExportDatasetUseCase exportDatasetUseCase,
    required ImportDatasetUseCase importDatasetUseCase,
  })  : _exportDatasetUseCase = exportDatasetUseCase,
        _importDatasetUseCase = importDatasetUseCase;

  Future<String> exportJsonLd() async {
    return await _exportDatasetUseCase.execute();
  }

  Future<void> importJsonLd(String jsonLd) async {
    await _importDatasetUseCase.execute(jsonLd);
    notifyListeners();
  }
}
