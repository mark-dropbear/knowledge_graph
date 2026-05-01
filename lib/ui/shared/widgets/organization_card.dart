import 'package:flutter/material.dart';
import 'package:knowledge_graph/domain/models/organization.dart';

class OrganizationCard extends StatelessWidget {
  final Organization organization;
  final VoidCallback? onTap;

  const OrganizationCard({super.key, required this.organization, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.business)),
        title: Text(organization.name),
        subtitle: Text(organization.orgType.toSchemaString()),
        trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
        onTap: onTap,
      ),
    );
  }
}
