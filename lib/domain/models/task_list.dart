import 'package:data_layer/data_layer.dart';
import 'package:uuid/uuid.dart';
import 'thing.dart';
import 'list_item.dart';

class TaskList implements Thing {
  @override
  final String id;
  @override
  final String type = 'ItemList';
  final String name;
  final String? description;
  final int numberOfItems;
  final List<ListItem> itemListElement;

  TaskList({
    required this.id,
    required this.name,
    this.description,
    this.numberOfItems = 0,
    List<ListItem>? itemListElement,
  }) : itemListElement = itemListElement ?? [];

  TaskList copyWith({
    String? id,
    String? name,
    String? description,
    int? numberOfItems,
    List<ListItem>? itemListElement,
  }) {
    return TaskList(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      numberOfItems: numberOfItems ?? this.numberOfItems,
      itemListElement: itemListElement ?? List.from(this.itemListElement),
    );
  }

  factory TaskList.fromJson(Map<String, dynamic> json) {
    return TaskList(
      id: json['@id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      numberOfItems: json['numberOfItems'] as int? ?? 0,
      itemListElement:
          (json['itemListElement'] as List<dynamic>?)
              ?.map((e) => ListItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '@context': 'https://schema.org',
      '@type': type,
      '@id': id,
      'name': name,
      if (description != null) 'description': description,
      'numberOfItems': numberOfItems,
      if (itemListElement.isNotEmpty)
        'itemListElement': itemListElement.map((e) => e.toJson()).toList(),
    };
  }

  static final bindings = CreationBindings<TaskList>(
    fromJson: TaskList.fromJson,
    toJson: (list) => list.toJson(),
    getId: (list) => list.id.isEmpty ? null : list.id,
    save: (list) => list.copyWith(
      id: list.id.isEmpty ? 'urn:uuid:${const Uuid().v4()}' : list.id,
    ),
  );
}
