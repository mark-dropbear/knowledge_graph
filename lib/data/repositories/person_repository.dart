import 'package:data_layer/data_layer.dart';
import 'package:knowledge_graph/domain/models/person.dart';

class PersonRepository extends Repository<Person> {
  PersonRepository()
    : super(
        SourceList<Person>(
          bindings: Person.bindings,
          sources: [LocalMemorySource<Person>(bindings: Person.bindings)],
        ),
      );
}
