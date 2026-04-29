import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:knowledge_graph/domain/models/task.dart';
import 'package:knowledge_graph/domain/models/task_list.dart';
import 'package:knowledge_graph/data/repositories/task_list_repository.dart';
import 'package:knowledge_graph/domain/use_cases/todo_use_cases.dart';
import 'package:knowledge_graph/domain/use_cases/export_dataset_use_case.dart';

class TodoListViewModel extends ChangeNotifier {
  static final _log = Logger('TodoListViewModel');

  final TaskListRepository _taskListRepository;
  final CreateTaskUseCase _createTaskUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;
  final HydrateTaskListUseCase _hydrateUseCase;
  final ToggleTaskStatusUseCase _toggleStatusUseCase;
  final ExportDatasetUseCase _exportDatasetUseCase;

  TodoListViewModel({
    required TaskListRepository taskListRepository,
    required CreateTaskUseCase createTaskUseCase,
    required DeleteTaskUseCase deleteTaskUseCase,
    required HydrateTaskListUseCase hydrateUseCase,
    required ToggleTaskStatusUseCase toggleStatusUseCase,
    required ExportDatasetUseCase exportDatasetUseCase,
  }) : _taskListRepository = taskListRepository,
       _createTaskUseCase = createTaskUseCase,
       _deleteTaskUseCase = deleteTaskUseCase,
       _hydrateUseCase = hydrateUseCase,
       _toggleStatusUseCase = toggleStatusUseCase,
       _exportDatasetUseCase = exportDatasetUseCase;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  TaskList? _currentList;
  TaskList? get currentList => _currentList;

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  Future<void> initialize() async {
    _log.info('Initializing ViewModel');
    _isLoading = true;
    notifyListeners();

    try {
      final lists = await _taskListRepository.getItems();
      if (lists.isNotEmpty) {
        _log.info('Loaded existing TaskList');
        _currentList = lists.first;
      } else {
        _log.info('No existing TaskList found, creating default');
        _currentList = TaskList(id: 'urn:uuid:default-list', name: 'My Tasks');
        await _taskListRepository.setItem(_currentList!);
      }
      await _hydrateTasks();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _hydrateTasks() async {
    if (_currentList != null) {
      _tasks = await _hydrateUseCase.execute(_currentList!);
    }
  }

  Future<void> addTask(String name) async {
    if (_currentList == null || name.isEmpty) return;

    _log.info('Adding new task: $name');
    _isLoading = true;
    notifyListeners();

    try {
      await _createTaskUseCase.execute(_currentList!, name);
      _currentList = await _taskListRepository.getById(_currentList!.id);
      await _hydrateTasks();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTask(Task task) async {
    if (_currentList == null) return;

    _log.info('Deleting task: ${task.id}');
    _isLoading = true;
    notifyListeners();

    try {
      await _deleteTaskUseCase.execute(_currentList!, task.id);
      _currentList = await _taskListRepository.getById(_currentList!.id);
      await _hydrateTasks();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleTask(Task task) async {
    if (_currentList == null) return;

    _log.info('Toggling task: ${task.id}');
    _isLoading = true;
    notifyListeners();

    try {
      await _toggleStatusUseCase.execute(task);
      await _hydrateTasks();
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
