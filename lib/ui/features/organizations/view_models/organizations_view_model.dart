import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:data_layer/data_layer.dart';
import 'package:knowledge_graph/domain/models/organization.dart';
import 'package:knowledge_graph/data/repositories/organization_repository.dart';
import 'package:knowledge_graph/domain/use_cases/organization_use_cases.dart';

class OrganizationsViewModel extends ChangeNotifier {
  static final _log = Logger('OrganizationsViewModel');

  final OrganizationRepository _organizationRepository;
  final CreateOrganizationUseCase _createOrganizationUseCase;
  final EditOrganizationUseCase _editOrganizationUseCase;
  final DeleteOrganizationUseCase _deleteOrganizationUseCase;

  OrganizationsViewModel({
    required OrganizationRepository organizationRepository,
    required CreateOrganizationUseCase createOrganizationUseCase,
    required EditOrganizationUseCase editOrganizationUseCase,
    required DeleteOrganizationUseCase deleteOrganizationUseCase,
  }) : _organizationRepository = organizationRepository,
       _createOrganizationUseCase = createOrganizationUseCase,
       _editOrganizationUseCase = editOrganizationUseCase,
       _deleteOrganizationUseCase = deleteOrganizationUseCase;

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
      _organizations = await _organizationRepository.getItems(
        details: RequestDetails.read(requestType: RequestType.allLocal),
      );
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
