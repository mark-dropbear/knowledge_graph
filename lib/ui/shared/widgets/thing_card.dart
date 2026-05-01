import 'package:flutter/material.dart';
import 'package:knowledge_graph/domain/models/thing_instance.dart';

class ThingCard extends StatelessWidget {
  final ThingInstance thing;
  final VoidCallback? onTap;

  const ThingCard({super.key, required this.thing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.tertiaryContainer,
                foregroundColor: Theme.of(
                  context,
                ).colorScheme.onTertiaryContainer,
                child: const Icon(Icons.category),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      thing.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (thing.description != null &&
                        thing.description!.isNotEmpty)
                      Text(
                        thing.description!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
