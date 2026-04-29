class ListItem {
  final String type = 'ListItem';
  final int position;
  final String item; // The @id reference to a Task

  ListItem({
    required this.position,
    required this.item,
  });

  factory ListItem.fromJson(Map<String, dynamic> json) {
    // Handle the case where the JSON-LD example had the item inline vs just the ID.
    // The example had the item inline, but we agreed to store references.
    // If it's a map, grab the '@id'. If it's a string, use it directly.
    String itemId;
    if (json['item'] is Map) {
      itemId = json['item']['@id'] as String;
    } else {
      itemId = json['item'] as String;
    }

    return ListItem(
      position: json['position'] as int,
      item: itemId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '@type': type,
      'position': position,
      // We store the reference. In strict JSON-LD, this might be an object `{"@id": item}`
      // but for our internal persistence, we can output the string, or the object.
      // Let's use the object format `{"@id": item}` to be closer to proper linked data.
      'item': {'@id': item},
    };
  }
}
