import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:data_layer/data_layer.dart';
import 'package:knowledge_graph/data/repositories/task_list_repository.dart';
import 'package:knowledge_graph/data/repositories/task_repository.dart';
import 'package:knowledge_graph/data/repositories/person_repository.dart';
import 'package:knowledge_graph/data/repositories/organization_repository.dart';

class ExportDatasetUseCase {
  static final _log = Logger('ExportDatasetUseCase');

  final TaskListRepository _taskListRepository;
  final TaskRepository _taskRepository;
  final PersonRepository _personRepository;
  final OrganizationRepository _organizationRepository;

  ExportDatasetUseCase(
    this._taskListRepository,
    this._taskRepository,
    this._personRepository,
    this._organizationRepository,
  );

  Future<String> execute() async {
    _log.info('Exporting full application dataset');
    // Fetch all task lists from the local memory cache directly
    final taskLists = await _taskListRepository.getItems(
      details: RequestDetails.read(requestType: RequestType.allLocal),
    );

    final taskIds = <String>{};
    for (final list in taskLists) {
      for (final item in list.itemListElement) {
        taskIds.add(item.item);
      }
    }

    final tasks = taskIds.isNotEmpty
        ? (await _taskRepository.getByIds(taskIds)).$1
        : [];

    final people = await _personRepository.getItems(
      details: RequestDetails.read(requestType: RequestType.allLocal),
    );

    final organizations = await _organizationRepository.getItems(
      details: RequestDetails.read(requestType: RequestType.allLocal),
    );

    final graph = [
      ...taskLists.map((l) {
        final json = l.toJson();
        json.remove('@context');
        return json;
      }),
      ...tasks.map((t) {
        final json = t.toJson();
        json.remove('@context');
        return json;
      }),
      ...people.map((p) {
        final json = p.toJson();
        json.remove('@context');
        return json;
      }),
      ...organizations.map((o) {
        final json = o.toJson();
        json.remove('@context');
        return json;
      }),
    ];

    final dataset = {'@context': 'https://schema.org', '@graph': graph};

    return const JsonEncoder.withIndent('  ').convert(dataset);
  }
}
