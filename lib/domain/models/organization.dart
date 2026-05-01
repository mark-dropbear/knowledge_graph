import 'package:data_layer/data_layer.dart';
import 'package:uuid/uuid.dart';
import 'thing.dart';

enum OrganizationType {
  organization,
  corporation,
  ngo,
  localBusiness;

  String toSchemaString() {
    switch (this) {
      case OrganizationType.organization:
        return 'Organization';
      case OrganizationType.corporation:
        return 'Corporation';
      case OrganizationType.ngo:
        return 'NGO';
      case OrganizationType.localBusiness:
        return 'LocalBusiness';
    }
  }

  static OrganizationType fromSchemaString(String type) {
    switch (type) {
      case 'Corporation':
        return OrganizationType.corporation;
      case 'NGO':
        return OrganizationType.ngo;
      case 'LocalBusiness':
        return OrganizationType.localBusiness;
      case 'Organization':
      default:
        return OrganizationType.organization;
    }
  }
}

class Organization implements Thing {
  @override
  final String id;

  final OrganizationType orgType;

  @override
  String get type => orgType.toSchemaString();

  final String name;
  final String? legalName;
  final String? description;
  final String? url;
  final List<String> employee;

  Organization({
    required this.id,
    this.orgType = OrganizationType.organization,
    required this.name,
    this.legalName,
    this.description,
    this.url,
    List<String>? employee,
  }) : employee = employee ?? [] {
    if (name.trim().isEmpty) {
      throw ArgumentError('An Organization must have a name.');
    }
  }

  Organization copyWith({
    String? id,
    OrganizationType? orgType,
    String? name,
    String? legalName,
    String? description,
    String? url,
    List<String>? employee,
    bool clearLegalName = false,
    bool clearDescription = false,
    bool clearUrl = false,
  }) {
    return Organization(
      id: id ?? this.id,
      orgType: orgType ?? this.orgType,
      name: name ?? this.name,
      legalName: clearLegalName ? null : (legalName ?? this.legalName),
      description: clearDescription ? null : (description ?? this.description),
      url: clearUrl ? null : (url ?? this.url),
      employee: employee ?? List.from(this.employee),
    );
  }

  factory Organization.fromJson(Map<String, dynamic> json) {
    List<String> parsedEmployee = [];
    if (json['employee'] != null) {
      if (json['employee'] is List) {
        parsedEmployee = (json['employee'] as List)
            .map((e) => (e as Map<String, dynamic>)['@id'] as String)
            .toList();
      } else if (json['employee'] is Map) {
        parsedEmployee = [json['employee']['@id'] as String];
      }
    }

    return Organization(
      id: json['@id'] as String,
      orgType: OrganizationType.fromSchemaString(
        json['@type'] as String? ?? 'Organization',
      ),
      name: json['name'] as String,
      legalName: json['legalName'] as String?,
      description: json['description'] as String?,
      url: json['url'] as String?,
      employee: parsedEmployee,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '@type': type,
      '@id': id,
      'name': name,
      if (legalName != null && legalName!.isNotEmpty) 'legalName': legalName,
      if (description != null && description!.isNotEmpty)
        'description': description,
      if (url != null && url!.isNotEmpty) 'url': url,
      if (employee.isNotEmpty)
        'employee': employee.map((id) => {'@id': id}).toList(),
    };
  }

  static final bindings = CreationBindings<Organization>(
    fromJson: Organization.fromJson,
    toJson: (org) => org.toJson(),
    getId: (org) => org.id.isEmpty ? null : org.id,
    save: (org) => org.copyWith(
      id: org.id.isEmpty ? 'urn:uuid:${const Uuid().v4()}' : org.id,
    ),
  );
}
