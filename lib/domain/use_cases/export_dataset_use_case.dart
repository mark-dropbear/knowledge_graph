import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:data_layer/data_layer.dart';
import 'package:knowledge_graph/domain/models/thing.dart';

class ExportDatasetUseCase {
  static final _log = Logger('ExportDatasetUseCase');

  final Repository<Thing> _repository;

  ExportDatasetUseCase(this._repository);

  Future<String> execute() async {
    _log.info('Exporting full application dataset');
    final items = await _repository.getItems(
      details: RequestDetails.read(requestType: RequestType.allLocal),
    );

    final graph = items.map((t) {
      final json = t.toJson();
      json.remove('@context');
      return json;
    }).toList();

    final dataset = {'@context': 'https://schema.org', '@graph': graph};

    return const JsonEncoder.withIndent('  ').convert(dataset);
  }
}
