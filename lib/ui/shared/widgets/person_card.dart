import 'package:flutter/material.dart';
import 'package:knowledge_graph/domain/models/person.dart';

class PersonCard extends StatelessWidget {
  final Person person;
  final VoidCallback? onTap;

  const PersonCard({super.key, required this.person, this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = '${person.givenName ?? ''} ${person.familyName ?? ''}'.trim();
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: Text(name.isEmpty ? 'Unknown Person' : name),
        subtitle: person.jobTitle != null && person.jobTitle!.isNotEmpty 
            ? Text(person.jobTitle!) 
            : null,
        trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
        onTap: onTap,
      ),
    );
  }
}
