import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:knowledge_graph/domain/models/task.dart';
import 'package:knowledge_graph/domain/models/task_list.dart';
import 'package:knowledge_graph/domain/models/thing.dart';
import 'package:data_layer/data_layer.dart';
import 'package:knowledge_graph/domain/use_cases/todo_use_cases.dart';

class TodoListViewModel extends ChangeNotifier {
  static final _log = Logger('TodoListViewModel');

  final Repository<Thing> _repository;
  final CreateTaskUseCase _createTaskUseCase;
  final DeleteTaskUseCase _deleteTaskUseCase;
  final EditTaskUseCase _editTaskUseCase;
  final HydrateTaskListUseCase _hydrateUseCase;
  final ToggleTaskStatusUseCase _toggleStatusUseCase;

  TodoListViewModel({
    required Repository<Thing> repository,
    required CreateTaskUseCase createTaskUseCase,
    required DeleteTaskUseCase deleteTaskUseCase,
    required EditTaskUseCase editTaskUseCase,
    required HydrateTaskListUseCase hydrateUseCase,
    required ToggleTaskStatusUseCase toggleStatusUseCase,
  }) : _repository = repository,
       _createTaskUseCase = createTaskUseCase,
       _deleteTaskUseCase = deleteTaskUseCase,
       _editTaskUseCase = editTaskUseCase,
       _hydrateUseCase = hydrateUseCase,
       _toggleStatusUseCase = toggleStatusUseCase;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  TaskList? _currentList;
  TaskList? get currentList => _currentList;

  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  Future<void> initialize(String listId) async {
    _log.info('Initializing ViewModel for list: $listId');
    Future.microtask(() {
      _isLoading = true;
      notifyListeners();
    });

    try {
      final thing = await _repository.getById(listId);
      _currentList = thing is TaskList ? thing : null;
      if (_currentList == null) {
        _log.warning('TaskList not found: $listId');
      } else {
        await _hydrateTasks();
      }
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

  Future<void> addTask(
    String name, {
    String? description,
    List<String>? agent,
    List<String>? participant,
  }) async {
    if (_currentList == null || name.isEmpty) return;

    _log.info('Adding new task: $name');
    _isLoading = true;
    notifyListeners();

    try {
      await _createTaskUseCase.execute(
        _currentList!,
        name,
        description: description,
        agent: agent,
        participant: participant,
      );
      final thing = await _repository.getById(_currentList!.id);
      _currentList = thing is TaskList ? thing : null;
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
      final thing = await _repository.getById(_currentList!.id);
      _currentList = thing is TaskList ? thing : null;
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

  Future<void> editTask(
    Task task,
    String newName, {
    String? newDescription,
    List<String>? newAgent,
    List<String>? newParticipant,
  }) async {
    if (newName.isEmpty) return;

    _log.info('Editing task: ${task.id}');
    _isLoading = true;
    notifyListeners();

    try {
      await _editTaskUseCase.execute(
        task,
        newName,
        newDescription: newDescription,
        newAgent: newAgent,
        newParticipant: newParticipant,
      );
      await _hydrateTasks();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
