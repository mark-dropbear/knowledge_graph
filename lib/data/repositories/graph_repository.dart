import 'package:data_layer/data_layer.dart';
import 'package:uuid/uuid.dart';
import 'package:knowledge_graph/domain/models/thing.dart';
import 'package:knowledge_graph/domain/models/person.dart';
import 'package:knowledge_graph/domain/models/organization.dart';
import 'package:knowledge_graph/domain/models/task.dart';
import 'package:knowledge_graph/domain/models/task_list.dart';

class GraphRepository extends Repository<Thing> {
  GraphRepository()
    : super(
        SourceList<Thing>(
          bindings: _bindings,
          sources: [LocalMemorySource<Thing>(bindings: _bindings)],
        ),
      );

  static final CreationBindings<Thing> _bindings = CreationBindings<Thing>(
    fromJson: (json) {
      final type = json['@type'];
      switch (type) {
        case 'Person':
          return Person.fromJson(json);
        case 'Organization':
          return Organization.fromJson(json);
        case 'Action':
          return Task.fromJson(json);
        case 'ItemList':
          return TaskList.fromJson(json);
        default:
          throw Exception('GraphRepository: Unknown type: $type');
      }
    },
    toJson: (thing) {
      if (thing is Person) return thing.toJson();
      if (thing is Organization) return thing.toJson();
      if (thing is Task) return thing.toJson();
      if (thing is TaskList) return thing.toJson();
      throw Exception('GraphRepository: Cannot serialize ${thing.runtimeType}');
    },
    getId: (thing) => thing.id.isEmpty ? null : thing.id,
    save: (thing) {
      if (thing.id.isNotEmpty) return thing;
      final newId = 'urn:uuid:${const Uuid().v4()}';

      if (thing is Person) return thing.copyWith(id: newId);
      if (thing is Organization) return thing.copyWith(id: newId);
      if (thing is Task) return thing.copyWith(id: newId);
      if (thing is TaskList) return thing.copyWith(id: newId);

      return thing; // Fallback
    },
  );
}
