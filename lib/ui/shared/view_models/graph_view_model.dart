import 'package:flutter/foundation.dart';
import 'package:knowledge_graph/domain/models/thing.dart';

/// A central cache that maintains a flat graph of all resources loaded by the application.
class GraphViewModel extends ChangeNotifier {
  final Map<String, Thing> _resources = {};

  /// Merges a list of items into the central graph.
  /// Notifies listeners if any new items are added or existing items are updated.
  void merge(List<Thing> items) {
    bool changed = false;
    for (final item in items) {
      if (_resources[item.id] != item) {
        _resources[item.id] = item;
        changed = true;
      }
    }

    if (changed) {
      notifyListeners();
    }
  }

  /// Resolves an ID to its underlying Thing, if it exists in the graph.
  /// Can optionally cast to a specific type [T].
  T? resolve<T extends Thing>(String id) {
    final item = _resources[id];
    if (item is T) {
      return item;
    }
    return null;
  }

  /// Returns a list of all resources of a specific type [T].
  List<T> getItems<T extends Thing>() {
    return _resources.values.whereType<T>().toList();
  }

  /// Helper to clear the graph if needed
  void clear() {
    if (_resources.isNotEmpty) {
      _resources.clear();
      notifyListeners();
    }
  }
}
