import 'package:data_layer/data_layer.dart';
import 'package:uuid/uuid.dart';
import 'thing.dart';

class Person implements Thing {
  @override
  final String id;
  @override
  final String type = 'Person';

  final String? givenName;
  final String? familyName;
  final String? jobTitle;
  final String? birthDate;

  Person({
    required this.id,
    this.givenName,
    this.familyName,
    this.jobTitle,
    this.birthDate,
  }) : assert(
         (givenName != null && givenName.trim().isNotEmpty) ||
             (familyName != null && familyName.trim().isNotEmpty),
         'A Person must have at least a givenName or familyName.',
       );

  Person copyWith({
    String? id,
    String? givenName,
    String? familyName,
    String? jobTitle,
    String? birthDate,
    bool clearGivenName = false,
    bool clearFamilyName = false,
    bool clearJobTitle = false,
    bool clearBirthDate = false,
  }) {
    return Person(
      id: id ?? this.id,
      givenName: clearGivenName ? null : (givenName ?? this.givenName),
      familyName: clearFamilyName ? null : (familyName ?? this.familyName),
      jobTitle: clearJobTitle ? null : (jobTitle ?? this.jobTitle),
      birthDate: clearBirthDate ? null : (birthDate ?? this.birthDate),
    );
  }

  factory Person.fromJson(Map<String, dynamic> json) {
    return Person(
      id: json['@id'] as String,
      givenName: json['givenName'] as String?,
      familyName: json['familyName'] as String?,
      jobTitle: json['jobTitle'] as String?,
      birthDate: json['birthDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '@type': type,
      '@id': id,
      if (givenName != null && givenName!.isNotEmpty) 'givenName': givenName,
      if (familyName != null && familyName!.isNotEmpty)
        'familyName': familyName,
      if (jobTitle != null && jobTitle!.isNotEmpty) 'jobTitle': jobTitle,
      if (birthDate != null && birthDate!.isNotEmpty) 'birthDate': birthDate,
    };
  }

  static final bindings = CreationBindings<Person>(
    fromJson: Person.fromJson,
    toJson: (person) => person.toJson(),
    getId: (person) => person.id.isEmpty ? null : person.id,
    save: (person) => person.copyWith(
      id: person.id.isEmpty ? 'urn:uuid:${const Uuid().v4()}' : person.id,
    ),
  );
}
