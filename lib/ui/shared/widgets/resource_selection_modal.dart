import 'package:flutter/material.dart';

class ResourceSelectionModal extends StatefulWidget {
  final String title;
  final List<String> initialSelectedIds;
  final Future<Map<String, String>> Function() fetchItems;
  final void Function(List<String>) onSelectionSaved;

  const ResourceSelectionModal({
    super.key,
    required this.title,
    required this.initialSelectedIds,
    required this.fetchItems,
    required this.onSelectionSaved,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required List<String> initialSelectedIds,
    required Future<Map<String, String>> Function() fetchItems,
    required void Function(List<String>) onSelectionSaved,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => ResourceSelectionModal(
        title: title,
        initialSelectedIds: initialSelectedIds,
        fetchItems: fetchItems,
        onSelectionSaved: onSelectionSaved,
      ),
    );
  }

  @override
  State<ResourceSelectionModal> createState() => _ResourceSelectionModalState();
}

class _ResourceSelectionModalState extends State<ResourceSelectionModal> {
  late List<String> _selectedIds;
  Map<String, String>? _items;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedIds = List.from(widget.initialSelectedIds);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadItems();
      }
    });
  }

  Future<void> _loadItems() async {
    final items = await widget.fetchItems();
    if (!mounted) return;
    setState(() {
      _items = items;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Column(
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
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _items!.isEmpty
                  ? const Center(child: Text('No items available.'))
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: _items!.length,
                      itemBuilder: (context, index) {
                        final id = _items!.keys.elementAt(index);
                        final name = _items!.values.elementAt(index);
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
                    ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    widget.onSelectionSaved(_selectedIds);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save Selection'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
