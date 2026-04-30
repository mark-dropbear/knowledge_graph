import 'package:data_layer/data_layer.dart';
import 'package:knowledge_graph/domain/models/organization.dart';

class OrganizationRepository extends Repository<Organization> {
  OrganizationRepository()
      : super(
          SourceList<Organization>(
            bindings: Organization.bindings,
            sources: [LocalMemorySource<Organization>(bindings: Organization.bindings)],
          ),
        );
}
