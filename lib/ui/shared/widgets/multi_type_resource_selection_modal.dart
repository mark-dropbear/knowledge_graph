import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

class ResourceTab {
  final String label;
  final Future<Map<String, String>> Function() fetchItems;

  const ResourceTab({required this.label, required this.fetchItems});
}

class MultiTypeResourceSelectionModal extends StatefulWidget {
  final String title;
  final List<String> initialSelectedIds;
  final List<ResourceTab> tabs;
  final void Function(List<String>) onSelectionSaved;

  const MultiTypeResourceSelectionModal({
    super.key,
    required this.title,
    required this.initialSelectedIds,
    required this.tabs,
    required this.onSelectionSaved,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required List<String> initialSelectedIds,
    required List<ResourceTab> tabs,
    required void Function(List<String>) onSelectionSaved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => MultiTypeResourceSelectionModal(
        title: title,
        initialSelectedIds: initialSelectedIds,
        tabs: tabs,
        onSelectionSaved: onSelectionSaved,
      ),
    );
  }

  @override
  State<MultiTypeResourceSelectionModal> createState() =>
      _MultiTypeResourceSelectionModalState();
}

class _MultiTypeResourceSelectionModalState
    extends State<MultiTypeResourceSelectionModal> {
  late Set<String> _selectedIds;
  late List<Map<String, String>?> _itemsPerTab;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedIds = Set.from(widget.initialSelectedIds);
    _itemsPerTab = List.filled(widget.tabs.length, null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadAllItems();
      }
    });
  }

  Future<void> _loadAllItems() async {
    final results = await Future.wait(
      widget.tabs.map((tab) => tab.fetchItems()),
    );

    if (!mounted) return;

    setState(() {
      _itemsPerTab = results;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.tabs.length,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (context, scrollController) {
          return Container(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          // Handle closing either via popping navigator or just visually in preview
                          if (Navigator.canPop(context)) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                TabBar(
                  tabs: widget.tabs.map((tab) => Tab(text: tab.label)).toList(),
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant,
                  tabAlignment: TabAlignment.fill,
                ),
                const Divider(height: 1),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : TabBarView(
                          children: List.generate(widget.tabs.length, (index) {
                            final items = _itemsPerTab[index]!;
                            if (items.isEmpty) {
                              return const Center(
                                child: Text('No items available.'),
                              );
                            }
                            return ListView.builder(
                              controller: scrollController,
                              itemCount: items.length,
                              itemBuilder: (context, itemIndex) {
                                final id = items.keys.elementAt(itemIndex);
                                final name = items.values.elementAt(itemIndex);
                                final isSelected = _selectedIds.contains(id);

                                return CheckboxListTile(
                                  title: Text(name),
                                  value: isSelected,
                                  onChanged: (bool? checked) {
                                    setState(() {
                                      if (checked == true) {
                                        _selectedIds.add(id);
                                      } else {
                                        _selectedIds.remove(id);
                                      }
                                    });
                                  },
                                );
                              },
                            );
                          }),
                        ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        widget.onSelectionSaved(_selectedIds.toList());
                        if (Navigator.canPop(context)) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Save Selection'),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Previews
// -----------------------------------------------------------------------------

@Preview(name: 'Multi-Type Selection Modal', size: Size(400, 600))
Widget multiTypeSelectionPreview() {
  return Material(
    child: MultiTypeResourceSelectionModal(
      title: 'Select Assignees',
      initialSelectedIds: const ['urn:uuid:p1', 'urn:uuid:o2'],
      tabs: [
        ResourceTab(
          label: 'People',
          fetchItems: () async => {
            'urn:uuid:p1': 'Alice Smith',
            'urn:uuid:p2': 'Bob Johnson',
            'urn:uuid:p3': 'Charlie Brown',
          },
        ),
        ResourceTab(
          label: 'Organizations',
          fetchItems: () async => {
            'urn:uuid:o1': 'Acme Corp',
            'urn:uuid:o2': 'Globex Inc',
          },
        ),
      ],
      onSelectionSaved: (ids) {
        debugPrint('Saved IDs: $ids');
      },
    ),
  );
}

@Preview(name: 'Multi-Type Selection Modal (Loading)', size: Size(400, 600))
Widget multiTypeSelectionLoadingPreview() {
  return Material(
    child: MultiTypeResourceSelectionModal(
      title: 'Select Assignees',
      initialSelectedIds: const [],
      tabs: [
        ResourceTab(
          label: 'People',
          fetchItems: () async {
            await Future.delayed(const Duration(seconds: 10));
            return {};
          },
        ),
        ResourceTab(
          label: 'Organizations',
          fetchItems: () async {
            await Future.delayed(const Duration(seconds: 10));
            return {};
          },
        ),
      ],
      onSelectionSaved: (_) {},
    ),
  );
}
