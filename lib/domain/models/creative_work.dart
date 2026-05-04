import 'package:data_layer/data_layer.dart';
import 'package:uuid/uuid.dart';
import 'thing.dart';

enum CreativeWorkType {
  creativeWork,
  website,
  webPage,
  webPageElement,
  book,
  article;

  String toSchemaString() {
    switch (this) {
      case CreativeWorkType.creativeWork:
        return 'CreativeWork';
      case CreativeWorkType.website:
        return 'WebSite';
      case CreativeWorkType.webPage:
        return 'WebPage';
      case CreativeWorkType.webPageElement:
        return 'WebPageElement';
      case CreativeWorkType.book:
        return 'Book';
      case CreativeWorkType.article:
        return 'Article';
    }
  }

  static CreativeWorkType fromSchemaString(String type) {
    switch (type) {
      case 'WebSite':
        return CreativeWorkType.website;
      case 'WebPage':
        return CreativeWorkType.webPage;
      case 'WebPageElement':
        return CreativeWorkType.webPageElement;
      case 'Book':
        return CreativeWorkType.book;
      case 'Article':
        return CreativeWorkType.article;
      case 'CreativeWork':
      default:
        return CreativeWorkType.creativeWork;
    }
  }
}

class CreativeWork implements Thing {
  @override
  final String id;

  final CreativeWorkType workType;

  @override
  String get type => workType.toSchemaString();

  final String name;
  final String? description;
  final String? url;
  final List<String> author;

  CreativeWork({
    required this.id,
    this.workType = CreativeWorkType.creativeWork,
    required this.name,
    this.description,
    this.url,
    List<String>? author,
  }) : author = author ?? [] {
    if (name.trim().isEmpty) {
      throw ArgumentError('A CreativeWork must have a name.');
    }
    if ((workType == CreativeWorkType.website || workType == CreativeWorkType.webPage) &&
        (url == null || url!.trim().isEmpty)) {
      throw ArgumentError('A ${workType.toSchemaString()} must have a url.');
    }
  }

  CreativeWork copyWith({
    String? id,
    CreativeWorkType? workType,
    String? name,
    String? description,
    String? url,
    List<String>? author,
    bool clearDescription = false,
    bool clearUrl = false,
  }) {
    return CreativeWork(
      id: id ?? this.id,
      workType: workType ?? this.workType,
      name: name ?? this.name,
      description: clearDescription ? null : (description ?? this.description),
      url: clearUrl ? null : (url ?? this.url),
      author: author ?? List.from(this.author),
    );
  }

  factory CreativeWork.fromJson(Map<String, dynamic> json) {
    List<String> parsedAuthor = [];
    if (json['author'] != null) {
      if (json['author'] is List) {
        parsedAuthor = (json['author'] as List)
            .map((e) => (e as Map<String, dynamic>)['@id'] as String)
            .toList();
      } else if (json['author'] is Map) {
        parsedAuthor = [json['author']['@id'] as String];
      }
    }

    return CreativeWork(
      id: json['@id'] as String,
      workType: CreativeWorkType.fromSchemaString(
        json['@type'] as String? ?? 'CreativeWork',
      ),
      name: json['name'] as String,
      description: json['description'] as String?,
      url: json['url'] as String?,
      author: parsedAuthor,
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
      if (author.isNotEmpty)
        'author': author.map((id) => {'@id': id}).toList(),
    };
  }

  static final bindings = CreationBindings<CreativeWork>(
    fromJson: CreativeWork.fromJson,
    toJson: (work) => work.toJson(),
    getId: (work) => work.id.isEmpty ? null : work.id,
    save: (work) => work.copyWith(
      id: work.id.isEmpty ? 'urn:uuid:${const Uuid().v4()}' : work.id,
    ),
  );
}
