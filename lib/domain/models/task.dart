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
  final List<String> agent;
  final List<String> participant;
  final List<String> instrument;

  Task({
    required this.id,
    required this.name,
    this.description,
    required this.actionStatus,
    this.endTime,
    List<String>? agent,
    List<String>? participant,
    List<String>? instrument,
  }) : agent = agent ?? [],
       participant = participant ?? [],
       instrument = instrument ?? [];

  Task copyWith({
    String? id,
    String? name,
    String? description,
    TaskStatus? actionStatus,
    String? endTime,
    List<String>? agent,
    List<String>? participant,
    List<String>? instrument,
  }) {
    return Task(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      actionStatus: actionStatus ?? this.actionStatus,
      endTime: endTime ?? this.endTime,
      agent: agent ?? List.from(this.agent),
      participant: participant ?? List.from(this.participant),
      instrument: instrument ?? List.from(this.instrument),
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    List<String> parsedAgent = [];
    if (json['agent'] != null) {
      if (json['agent'] is List) {
        parsedAgent = (json['agent'] as List)
            .map((e) => (e as Map<String, dynamic>)['@id'] as String)
            .toList();
      } else if (json['agent'] is Map) {
        parsedAgent = [json['agent']['@id'] as String];
      }
    }

    List<String> parsedParticipant = [];
    if (json['participant'] != null) {
      if (json['participant'] is List) {
        parsedParticipant = (json['participant'] as List)
            .map((e) => (e as Map<String, dynamic>)['@id'] as String)
            .toList();
      } else if (json['participant'] is Map) {
        parsedParticipant = [json['participant']['@id'] as String];
      }
    }

    List<String> parsedInstrument = [];
    if (json['instrument'] != null) {
      if (json['instrument'] is List) {
        parsedInstrument = (json['instrument'] as List)
            .map((e) => (e as Map<String, dynamic>)['@id'] as String)
            .toList();
      } else if (json['instrument'] is Map) {
        parsedInstrument = [json['instrument']['@id'] as String];
      }
    }

    return Task(
      id: json['@id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      actionStatus: TaskStatus.fromSchemaUrl(json['actionStatus'] as String),
      endTime: json['endTime'] as String?,
      agent: parsedAgent,
      participant: parsedParticipant,
      instrument: parsedInstrument,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '@type': type,
      '@id': id,
      'name': name,
      if (description != null) 'description': description,
      'actionStatus': actionStatus.toSchemaUrl(),
      if (endTime != null) 'endTime': endTime,
      if (agent.isNotEmpty) 'agent': agent.map((id) => {'@id': id}).toList(),
      if (participant.isNotEmpty)
        'participant': participant.map((id) => {'@id': id}).toList(),
      if (instrument.isNotEmpty)
        'instrument': instrument.map((id) => {'@id': id}).toList(),
    };
  }

  static final bindings = CreationBindings<Task>(
    fromJson: Task.fromJson,
    toJson: (task) => task.toJson(),
    getId: (task) => task.id.isEmpty ? null : task.id,
    save: (task) => task.copyWith(
      id: task.id.isEmpty ? 'urn:uuid:${const Uuid().v4()}' : task.id,
    ),
  );
}
