import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:data_layer/data_layer.dart';
import 'package:knowledge_graph/domain/models/thing.dart';
import 'package:knowledge_graph/data/repositories/graph_repository.dart';

class ImportDatasetUseCase {
  static final _log = Logger('ImportDatasetUseCase');

  final Repository<Thing> _repository;

  ImportDatasetUseCase(this._repository);

  Future<void> execute(String jsonLd) async {
    _log.info('Importing application dataset');
    try {
      final dataset = jsonDecode(jsonLd) as Map<String, dynamic>;
      final graph = dataset['@graph'] as List<dynamic>?;
      if (graph == null) {
        _log.warning('No @graph found in JSON-LD');
        return;
      }

      for (final item in graph) {
        if (item is Map<String, dynamic>) {
          try {
            final thing = GraphRepository.fromJson(item);
            await _repository.setItem(thing);
          } catch (e) {
            _log.warning('Skipped item due to parsing error: $e');
          }
        }
      }
    } catch (e, st) {
      _log.severe('Failed to import dataset', e, st);
      rethrow;
    }
  }
}
