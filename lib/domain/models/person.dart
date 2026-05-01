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
  final List<String> worksFor;
  final List<String> colleague;

  Person({
    required this.id,
    this.givenName,
    this.familyName,
    this.jobTitle,
    this.birthDate,
    List<String>? worksFor,
    List<String>? colleague,
  }) : worksFor = worksFor ?? [],
       colleague = colleague ?? [],
       assert(
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
    List<String>? worksFor,
    List<String>? colleague,
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
      worksFor: worksFor ?? List.from(this.worksFor),
      colleague: colleague ?? List.from(this.colleague),
    );
  }

  factory Person.fromJson(Map<String, dynamic> json) {
    List<String> parsedWorksFor = [];
    if (json['worksFor'] != null) {
      if (json['worksFor'] is List) {
        parsedWorksFor = (json['worksFor'] as List)
            .map((e) => (e as Map<String, dynamic>)['@id'] as String)
            .toList();
      } else if (json['worksFor'] is Map) {
        parsedWorksFor = [json['worksFor']['@id'] as String];
      }
    }

    List<String> parsedColleague = [];
    if (json['colleague'] != null) {
      if (json['colleague'] is List) {
        parsedColleague = (json['colleague'] as List)
            .map((e) => (e as Map<String, dynamic>)['@id'] as String)
            .toList();
      } else if (json['colleague'] is Map) {
        parsedColleague = [json['colleague']['@id'] as String];
      }
    }

    return Person(
      id: json['@id'] as String,
      givenName: json['givenName'] as String?,
      familyName: json['familyName'] as String?,
      jobTitle: json['jobTitle'] as String?,
      birthDate: json['birthDate'] as String?,
      worksFor: parsedWorksFor,
      colleague: parsedColleague,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '@type': type,
      '@id': id,
      if (givenName != null && givenName!.isNotEmpty) 'givenName': givenName,
      if (familyName != null && familyName!.isNotEmpty)
        'familyName': familyName,
      if (jobTitle != null && jobTitle!.isNotEmpty) 'jobTitle': jobTitle,
      if (birthDate != null && birthDate!.isNotEmpty) 'birthDate': birthDate,
      if (worksFor.isNotEmpty)
        'worksFor': worksFor.map((id) => {'@id': id}).toList(),
      if (colleague.isNotEmpty)
        'colleague': colleague.map((id) => {'@id': id}).toList(),
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
