import 'package:get_it/get_it.dart';
import 'package:data_layer/data_layer.dart';
import 'package:knowledge_graph/data/repositories/graph_repository.dart';
import 'package:knowledge_graph/domain/models/thing.dart';

import 'package:knowledge_graph/domain/use_cases/export_dataset_use_case.dart';
import 'package:knowledge_graph/domain/use_cases/import_dataset_use_case.dart';
import 'package:knowledge_graph/domain/use_cases/organization_use_cases.dart';
import 'package:knowledge_graph/domain/use_cases/person_use_cases.dart';
import 'package:knowledge_graph/domain/use_cases/thing_instance_use_cases.dart';
import 'package:knowledge_graph/domain/use_cases/todo_use_cases.dart';

import 'package:knowledge_graph/ui/features/organizations/view_models/organizations_view_model.dart';
import 'package:knowledge_graph/ui/features/people/view_models/people_view_model.dart';
import 'package:knowledge_graph/ui/features/things/view_models/things_view_model.dart';
import 'package:knowledge_graph/ui/features/todo/view_models/task_lists_view_model.dart';
import 'package:knowledge_graph/ui/features/todo/view_models/todo_list_view_model.dart';
import 'package:knowledge_graph/ui/shared/view_models/graph_view_model.dart';
import 'package:knowledge_graph/ui/features/home/view_models/home_view_model.dart';

final sl = GetIt.instance;

void init() {
  // 1. Repositories
  sl.registerLazySingleton<Repository<Thing>>(() => GraphRepository());

  // 2. Use Cases
  // Todo / Task
  sl.registerLazySingleton(() => CreateTaskUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTaskUseCase(sl()));
  sl.registerLazySingleton(() => EditTaskUseCase(sl()));
  sl.registerLazySingleton(() => HydrateTaskListUseCase(sl()));
  sl.registerLazySingleton(() => ToggleTaskStatusUseCase(sl()));
  sl.registerLazySingleton(() => CreateTaskListUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTaskListUseCase(sl()));
  sl.registerLazySingleton(() => EditTaskListUseCase(sl()));
  sl.registerLazySingleton(() => ExportDatasetUseCase(sl()));
  sl.registerLazySingleton(() => ImportDatasetUseCase(sl()));

  // Person
  sl.registerLazySingleton(() => CreatePersonUseCase(sl()));
  sl.registerLazySingleton(() => EditPersonUseCase(sl()));
  sl.registerLazySingleton(() => DeletePersonUseCase(sl()));

  // Organization
  sl.registerLazySingleton(() => CreateOrganizationUseCase(sl()));
  sl.registerLazySingleton(() => EditOrganizationUseCase(sl()));
  sl.registerLazySingleton(() => DeleteOrganizationUseCase(sl()));

  // ThingInstance
  sl.registerLazySingleton(() => CreateThingInstanceUseCase(sl()));
  sl.registerLazySingleton(() => EditThingInstanceUseCase(sl()));
  sl.registerLazySingleton(() => DeleteThingInstanceUseCase(sl()));

  // 3. ViewModels
  sl.registerLazySingleton(() => GraphViewModel());

  sl.registerLazySingleton(
    () => TaskListsViewModel(
      repository: sl(),
      createTaskListUseCase: sl(),
      deleteTaskListUseCase: sl(),
      editTaskListUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => TodoListViewModel(
      repository: sl(),
      createTaskUseCase: sl(),
      deleteTaskUseCase: sl(),
      editTaskUseCase: sl(),
      hydrateUseCase: sl(),
      toggleStatusUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => PeopleViewModel(
      repository: sl(),
      createPersonUseCase: sl(),
      editPersonUseCase: sl(),
      deletePersonUseCase: sl(),
      graphViewModel: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => OrganizationsViewModel(
      repository: sl(),
      createOrganizationUseCase: sl(),
      editOrganizationUseCase: sl(),
      deleteOrganizationUseCase: sl(),
      graphViewModel: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => ThingsViewModel(
      repository: sl(),
      createThingInstanceUseCase: sl(),
      editThingInstanceUseCase: sl(),
      deleteThingInstanceUseCase: sl(),
      graphViewModel: sl(),
    ),
  );

  sl.registerLazySingleton(
    () => HomeViewModel(
      exportDatasetUseCase: sl(),
      importDatasetUseCase: sl(),
    ),
  );
}
