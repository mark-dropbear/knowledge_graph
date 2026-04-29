import 'package:data_layer/data_layer.dart';
import 'package:uuid/uuid.dart';
import 'thing.dart';

class Task implements Thing {
  @override
  final String id;
  @override
  final String type = 'Action';
  final String name;
  final String? description;
  final String actionStatus;
  final String? endTime;

  Task({
    required this.id,
    required this.name,
    this.description,
    required this.actionStatus,
    this.endTime,
  });

  Task copyWith({
    String? id,
    String? name,
    String? description,
    String? actionStatus,
    String? endTime,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      actionStatus: actionStatus ?? this.actionStatus,
      endTime: endTime ?? this.endTime,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['@id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      actionStatus: json['actionStatus'] as String,
      endTime: json['endTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '@type': type,
      '@id': id,
      'name': name,
      if (description != null) 'description': description,
      'actionStatus': actionStatus,
      if (endTime != null) 'endTime': endTime,
    };
  }

  static final bindings = CreationBindings<Task>(
    fromJson: Task.fromJson,
    toJson: (task) => task.toJson(),
    getId: (task) => task.id,
    save: (task) => task.copyWith(id: task.id.isEmpty ? 'urn:uuid:${const Uuid().v4()}' : task.id),
  );
}
