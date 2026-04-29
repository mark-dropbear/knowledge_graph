import 'package:data_layer/data_layer.dart';
import 'package:uuid/uuid.dart';
import 'thing.dart';

enum TaskStatus {
  potential,
  active,
  completed,
  failed,
  cancelled;

  String toSchemaUrl() {
    switch (this) {
      case TaskStatus.potential:
        return 'https://schema.org/PotentialActionStatus';
      case TaskStatus.active:
        return 'https://schema.org/ActiveActionStatus';
      case TaskStatus.completed:
        return 'https://schema.org/CompletedActionStatus';
      case TaskStatus.failed:
        return 'https://schema.org/FailedActionStatus';
      case TaskStatus.cancelled:
        return 'https://schema.org/CancelledActionStatus';
    }
  }

  static TaskStatus fromSchemaUrl(String url) {
    switch (url) {
      case 'https://schema.org/ActiveActionStatus':
        return TaskStatus.active;
      case 'https://schema.org/CompletedActionStatus':
        return TaskStatus.completed;
      case 'https://schema.org/FailedActionStatus':
        return TaskStatus.failed;
      case 'https://schema.org/CancelledActionStatus':
        return TaskStatus.cancelled;
      case 'https://schema.org/PotentialActionStatus':
      default:
        return TaskStatus.potential;
    }
  }
}

class Task implements Thing {
  @override
  final String id;
  @override
  final String type = 'Action';
  final String name;
  final String? description;
  final TaskStatus actionStatus;
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
    TaskStatus? actionStatus,
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
      actionStatus: TaskStatus.fromSchemaUrl(json['actionStatus'] as String),
      endTime: json['endTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '@type': type,
      '@id': id,
      'name': name,
      if (description != null) 'description': description,
      'actionStatus': actionStatus.toSchemaUrl(),
      if (endTime != null) 'endTime': endTime,
    };
  }

  static final bindings = CreationBindings<Task>(
    fromJson: Task.fromJson,
    toJson: (task) => task.toJson(),
    getId: (task) => task.id,
    save: (task) => task.copyWith(
      id: task.id.isEmpty ? 'urn:uuid:${const Uuid().v4()}' : task.id,
    ),
  );
}
