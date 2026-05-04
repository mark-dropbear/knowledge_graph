import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge_graph/ui/features/home/view_models/home_view_model.dart';

class HomeView extends StatelessWidget {
  final HomeViewModel viewModel;

  const HomeView({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Browse',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.0,
              children: [
                _buildBrowseCard(
                  context,
                  title: 'Tasks',
                  icon: Icons.task,
                  route: '/tasks',
                  color: Colors.blue,
                ),
                _buildBrowseCard(
                  context,
                  title: 'People',
                  icon: Icons.people,
                  route: '/people',
                  color: Colors.orange,
                ),
                _buildBrowseCard(
                  context,
                  title: 'Organizations',
                  icon: Icons.business,
                  route: '/organizations',
                  color: Colors.purple,
                ),
                _buildBrowseCard(
                  context,
                  title: 'Creative Works',
                  icon: Icons.book,
                  route: '/creative-works',
                  color: Colors.redAccent,
                ),
                _buildBrowseCard(
                  context,
                  title: 'Things',
                  icon: Icons.category,
                  route: '/things',
                  color: Colors.green,
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Key Actions',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.download),
              ),
              title: const Text('Export Knowledge Graph'),
              subtitle: const Text('Export all data to JSON-LD format'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final jsonString = await viewModel.exportJsonLd();
                Clipboard.setData(ClipboardData(text: jsonString));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('JSON-LD copied to clipboard'),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.upload),
              ),
              title: const Text('Import Knowledge Graph'),
              subtitle: const Text('Import JSON-LD data from clipboard'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
                final jsonLd = clipboardData?.text;
                if (jsonLd == null || jsonLd.isEmpty) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Clipboard is empty'),
                      ),
                    );
                  }
                  return;
                }
                
                try {
                  await viewModel.importJsonLd(jsonLd);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Successfully imported dataset!'),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to import: $e'),
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrowseCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String route,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => context.go(route),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
