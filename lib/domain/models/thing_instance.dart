import 'package:data_layer/data_layer.dart';
import 'package:uuid/uuid.dart';
import 'thing.dart';

class ThingInstance implements Thing {
  @override
  final String id;
  @override
  final String type = 'Thing';

  final String name;
  final String? description;
  final String? url;

  ThingInstance({
    required this.id,
    required this.name,
    this.description,
    this.url,
  });

  ThingInstance copyWith({
    String? id,
    String? name,
    String? description,
    String? url,
    bool clearDescription = false,
    bool clearUrl = false,
  }) {
    return ThingInstance(
      id: id ?? this.id,
      name: name ?? this.name,
      description: clearDescription ? null : (description ?? this.description),
      url: clearUrl ? null : (url ?? this.url),
    );
  }

  factory ThingInstance.fromJson(Map<String, dynamic> json) {
    return ThingInstance(
      id: json['@id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      url: json['url'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '@type': type,
      '@id': id,
      'name': name,
      if (description != null && description!.isNotEmpty)
        'description': description,
      if (url != null && url!.isNotEmpty) 'url': url,
    };
  }

  static final bindings = CreationBindings<ThingInstance>(
    fromJson: ThingInstance.fromJson,
    toJson: (thing) => thing.toJson(),
    getId: (thing) => thing.id.isEmpty ? null : thing.id,
    save: (thing) => thing.copyWith(
      id: thing.id.isEmpty ? 'urn:uuid:${const Uuid().v4()}' : thing.id,
    ),
  );
}
