import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:knowledge_graph/domain/models/task_list.dart';
import 'package:knowledge_graph/data/repositories/task_list_repository.dart';
import 'package:knowledge_graph/domain/use_cases/todo_use_cases.dart';
import 'package:data_layer/data_layer.dart';
import 'package:knowledge_graph/domain/use_cases/export_dataset_use_case.dart';

class TaskListsViewModel extends ChangeNotifier {
  static final _log = Logger('TaskListsViewModel');

  final TaskListRepository _taskListRepository;
  final CreateTaskListUseCase _createTaskListUseCase;
  final DeleteTaskListUseCase _deleteTaskListUseCase;
  final EditTaskListUseCase _editTaskListUseCase;
  final ExportDatasetUseCase _exportDatasetUseCase;

  TaskListsViewModel({
    required TaskListRepository taskListRepository,
    required CreateTaskListUseCase createTaskListUseCase,
    required DeleteTaskListUseCase deleteTaskListUseCase,
    required EditTaskListUseCase editTaskListUseCase,
    required ExportDatasetUseCase exportDatasetUseCase,
  }) : _taskListRepository = taskListRepository,
       _createTaskListUseCase = createTaskListUseCase,
       _deleteTaskListUseCase = deleteTaskListUseCase,
       _editTaskListUseCase = editTaskListUseCase,
       _exportDatasetUseCase = exportDatasetUseCase;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<TaskList> _lists = [];
  List<TaskList> get lists => _lists;

  Future<void> initialize() async {
    _log.info('Initializing TaskListsViewModel');
    _isLoading = true;
    notifyListeners();

    try {
      _lists = await _taskListRepository.getItems(
        details: RequestDetails.read(requestType: RequestType.allLocal),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addList(String name, {String? description}) async {
    if (name.isEmpty) return;

    _log.info('Adding new TaskList: $name');
    _isLoading = true;
    notifyListeners();

    try {
      await _createTaskListUseCase.execute(name, description: description);
      _lists = await _taskListRepository.getItems(
        details: RequestDetails.read(requestType: RequestType.allLocal),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteList(TaskList list) async {
    _log.info('Deleting TaskList: ${list.id}');
    _isLoading = true;
    notifyListeners();

    try {
      await _deleteTaskListUseCase.execute(list);
      _lists = await _taskListRepository.getItems(
        details: RequestDetails.read(requestType: RequestType.allLocal),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> editList(TaskList list, String newName, {String? newDescription}) async {
    if (newName.isEmpty) return;

    _log.info('Editing TaskList: ${list.id}');
    _isLoading = true;
    notifyListeners();

    try {
      await _editTaskListUseCase.execute(list, newName, newDescription: newDescription);
      _lists = await _taskListRepository.getItems(
        details: RequestDetails.read(requestType: RequestType.allLocal),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> exportJsonLd() async {
    _log.info('Exporting dataset');
    return await _exportDatasetUseCase.execute();
  }
}
