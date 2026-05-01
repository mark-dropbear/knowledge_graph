import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:data_layer/data_layer.dart';
import 'package:knowledge_graph/domain/models/organization.dart';
import 'package:knowledge_graph/domain/models/thing.dart';
import 'package:knowledge_graph/domain/use_cases/organization_use_cases.dart';
import 'package:knowledge_graph/ui/shared/view_models/graph_view_model.dart';

class OrganizationsViewModel extends ChangeNotifier {
  static final _log = Logger('OrganizationsViewModel');

  final Repository<Thing> _repository;
  final CreateOrganizationUseCase _createOrganizationUseCase;
  final EditOrganizationUseCase _editOrganizationUseCase;
  final DeleteOrganizationUseCase _deleteOrganizationUseCase;
  final GraphViewModel _graphViewModel;

  OrganizationsViewModel({
    required Repository<Thing> repository,
    required CreateOrganizationUseCase createOrganizationUseCase,
    required EditOrganizationUseCase editOrganizationUseCase,
    required DeleteOrganizationUseCase deleteOrganizationUseCase,
    required GraphViewModel graphViewModel,
  }) : _repository = repository,
       _createOrganizationUseCase = createOrganizationUseCase,
       _editOrganizationUseCase = editOrganizationUseCase,
       _deleteOrganizationUseCase = deleteOrganizationUseCase,
       _graphViewModel = graphViewModel;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Organization> _organizations = [];
  List<Organization> get organizations => _organizations;

  Future<void> initialize() async {
    _log.info('Initializing OrganizationsViewModel');
    Future.microtask(() {
      _isLoading = true;
      notifyListeners();
    });

    try {
      final items = await _repository.getItems(
        details: RequestDetails.read(requestType: RequestType.allLocal),
      );
      _organizations = items.whereType<Organization>().toList();
      _graphViewModel.merge(_organizations);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addOrganization({
    required String name,
    OrganizationType orgType = OrganizationType.organization,
    String? legalName,
    String? description,
    String? url,
    List<String>? employee,
  }) async {
    _log.info('Adding new organization');
    await _createOrganizationUseCase.execute(
      name: name,
      orgType: orgType,
      legalName: legalName,
      description: description,
      url: url,
      employee: employee,
    );
    await initialize();
  }

  Future<void> editOrganization(
    Organization organization, {
    String? name,
    OrganizationType? orgType,
    String? legalName,
    String? description,
    String? url,
    List<String>? employee,
  }) async {
    _log.info('Editing organization: ${organization.id}');
    await _editOrganizationUseCase.execute(
      organization,
      name: name,
      orgType: orgType,
      legalName: legalName,
      description: description,
      url: url,
      employee: employee,
    );
    await initialize();
  }

  Future<void> deleteOrganization(Organization organization) async {
    _log.info('Deleting organization: ${organization.id}');
    await _deleteOrganizationUseCase.execute(organization);
    await initialize();
  }
}
