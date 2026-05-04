import 'package:flutter/foundation.dart';
import 'package:knowledge_graph/domain/use_cases/export_dataset_use_case.dart';

class HomeViewModel extends ChangeNotifier {
  final ExportDatasetUseCase _exportDatasetUseCase;

  HomeViewModel({required ExportDatasetUseCase exportDatasetUseCase})
      : _exportDatasetUseCase = exportDatasetUseCase;

  Future<String> exportJsonLd() async {
    return await _exportDatasetUseCase.execute();
  }
}
